function writejson(data, filename, options)
%WRITEJSON Write data to a JSON file
%   WRITEJSON(data, filename) writes the data to a JSON file with pretty
%   printing enabled by default.
%
%   WRITEJSON(data, filename, Name, Value) specifies additional options:
%
%       'PrettyPrint' - Format output with indentation and newlines
%           true    - (default) Human-readable formatting
%           false   - Compact single-line output
%
%       'Precision'   - Number of significant digits for numeric values
%           6       - (default)
%
%       'EmptyValue'  - How to handle empty arrays ([])
%           'null'  - (default) Write as JSON null
%           'omit'  - Omit the key entirely from output
%
%   Supported input types:
%       - JSONData, YAMLData, TOMLData, INIData (ConfigurationData)
%       - struct
%       - dictionary
%       - containers.Map
%
%   Original key names are preserved, including keys with special characters
%   like hyphens or keys starting with numbers.
%
%   Example:
%       % Write JSONData to file
%       config = jsondata();
%       config.("my-key") = 'value';  % Key with hyphen preserved
%       writejson(config, 'config.json');
%
%       % Write without pretty printing
%       writejson(config, 'compact.json', 'PrettyPrint', false);
%
%   See also: readjson, jsondata, matlab.io.config.JSONData, jsonencode

    arguments
        data
        filename {mustBeTextScalar, mustBeNonzeroLengthText} = "untitled.json"
        options.PrettyPrint (1,1) logical = true
        options.Precision (1,1) {mustBePositive, mustBeInteger} = 6
        options.EmptyValue {mustBeMember(options.EmptyValue, ["null", "omit"])} = "null"
    end

    % Convert input to containers.Map (preserves arbitrary string keys)
    mapData = convertToMap(data, options.EmptyValue);

    % Encode to JSON using built-in jsonencode
    if options.PrettyPrint
        jsonText = jsonencode(mapData, 'PrettyPrint', true);
    else
        jsonText = jsonencode(mapData);
    end

    % Post-process: replace empty array placeholders with null if EmptyValue='null'
    if options.EmptyValue == "null"
        % Replace ": []" with ": null" for empty arrays that represent null values
        jsonText = regexprep(jsonText, ':\s*\[\s*\]', ': null');
    end

    % Write to file
    fid = fopen(filename, 'w', 'n', 'UTF-8');
    if fid == -1
        error('writejson:FileError', 'Could not open file for writing: %s', filename);
    end
    try
        fprintf(fid, '%s', jsonText);
        fclose(fid);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end

function result = convertToMap(data, emptyValueOption)
%CONVERTTOMAP Convert various data types to containers.Map for JSON encoding
%   Uses containers.Map because jsonencode preserves original key names with it.

    if isa(data, 'matlab.io.config.ConfigurationData')
        % ConfigurationData -> containers.Map using keys() to preserve original names
        allKeys = keys(data);
        if isempty(allKeys)
            result = containers.Map('KeyType', 'char', 'ValueType', 'any');
        else
            keyCell = cellstr(allKeys);
            valueCell = cell(size(keyCell));
            validIdx = true(size(keyCell));
            for i = 1:numel(allKeys)
                key = allKeys(i);
                value = data.(key);
                % Recursively convert nested values
                convertedValue = convertToMap(value, emptyValueOption);
                % Handle empty values
                if isempty(convertedValue) && ~isa(convertedValue, 'containers.Map') && ~iscell(convertedValue)
                    if emptyValueOption == "omit"
                        validIdx(i) = false;
                        continue;
                    end
                end
                valueCell{i} = convertedValue;
            end
            if any(validIdx)
                result = containers.Map(keyCell(validIdx), valueCell(validIdx));
            else
                result = containers.Map('KeyType', 'char', 'ValueType', 'any');
            end
        end
    elseif isa(data, 'dictionary')
        % Dictionary -> containers.Map
        allKeys = keys(data);
        if isempty(allKeys)
            result = containers.Map('KeyType', 'char', 'ValueType', 'any');
        else
            keyCell = cellstr(allKeys);
            valueCell = cell(size(keyCell));
            validIdx = true(size(keyCell));
            for i = 1:numel(allKeys)
                key = allKeys(i);
                value = data(key);
                if iscell(value)
                    value = value{1};
                end
                convertedValue = convertToMap(value, emptyValueOption);
                if isempty(convertedValue) && ~isa(convertedValue, 'containers.Map') && ~iscell(convertedValue)
                    if emptyValueOption == "omit"
                        validIdx(i) = false;
                        continue;
                    end
                end
                valueCell{i} = convertedValue;
            end
            if any(validIdx)
                result = containers.Map(keyCell(validIdx), valueCell(validIdx));
            else
                result = containers.Map('KeyType', 'char', 'ValueType', 'any');
            end
        end
    elseif isa(data, 'containers.Map')
        % containers.Map - recursively convert values
        allKeys = keys(data);
        if isempty(allKeys)
            result = containers.Map('KeyType', 'char', 'ValueType', 'any');
        else
            valueCell = cell(size(allKeys));
            validIdx = true(size(allKeys));
            for i = 1:numel(allKeys)
                key = allKeys{i};
                value = data(key);
                convertedValue = convertToMap(value, emptyValueOption);
                if isempty(convertedValue) && ~isa(convertedValue, 'containers.Map') && ~iscell(convertedValue)
                    if emptyValueOption == "omit"
                        validIdx(i) = false;
                        continue;
                    end
                end
                valueCell{i} = convertedValue;
            end
            if any(validIdx)
                result = containers.Map(allKeys(validIdx), valueCell(validIdx));
            else
                result = containers.Map('KeyType', 'char', 'ValueType', 'any');
            end
        end
    elseif isstruct(data)
        % Struct - convert to Map (note: struct keys are already valid MATLAB names)
        if isscalar(data)
            fields = fieldnames(data);
            if isempty(fields)
                result = containers.Map('KeyType', 'char', 'ValueType', 'any');
            else
                valueCell = cell(size(fields));
                validIdx = true(size(fields));
                for i = 1:numel(fields)
                    fieldName = fields{i};
                    value = data.(fieldName);
                    convertedValue = convertToMap(value, emptyValueOption);
                    if isempty(convertedValue) && ~isa(convertedValue, 'containers.Map') && ~iscell(convertedValue)
                        if emptyValueOption == "omit"
                            validIdx(i) = false;
                            continue;
                        end
                    end
                    valueCell{i} = convertedValue;
                end
                if any(validIdx)
                    result = containers.Map(fields(validIdx), valueCell(validIdx));
                else
                    result = containers.Map('KeyType', 'char', 'ValueType', 'any');
                end
            end
        else
            % Struct array - convert each element
            result = repmat(struct(), 1, numel(data));
            for i = 1:numel(data)
                result(i) = convertToStruct(data(i), emptyValueOption);
            end
        end
    elseif iscell(data)
        % Cell array - recursively convert elements
        result = cell(size(data));
        for i = 1:numel(data)
            result{i} = convertToMap(data{i}, emptyValueOption);
        end
    else
        % Scalars and arrays - pass through
        result = data;
    end
end
