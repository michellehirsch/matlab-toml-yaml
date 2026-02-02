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
%   Example:
%       % Write JSONData to file
%       config = jsondata();
%       config.name = 'my-package';
%       config.version = '1.0.0';
%       writejson(config, 'package.json');
%
%       % Write struct to file
%       s.name = 'test';
%       s.enabled = true;
%       writejson(s, 'config.json');
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

    % Convert input to struct
    structData = convertToStruct(data, options.EmptyValue);

    % Encode to JSON using built-in jsonencode
    if options.PrettyPrint
        jsonText = jsonencode(structData, 'PrettyPrint', true);
    else
        jsonText = jsonencode(structData);
    end

    % Post-process: replace empty array placeholders with null if EmptyValue='null'
    if options.EmptyValue == "null"
        % Replace ": []" with ": null" for empty arrays that represent null values
        % This handles the common case where [] from reading null should write back as null
        % Use regex to handle both pretty-printed and compact JSON
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

function result = convertToStruct(data, emptyValueOption)
%CONVERTTOSTRUCT Convert various data types to struct for JSON encoding

    if isa(data, 'matlab.io.config.ConfigurationData')
        % ConfigurationData -> struct using keys() to preserve original names
        result = struct();
        allKeys = keys(data);
        for i = 1:numel(allKeys)
            key = allKeys(i);
            value = data.(key);
            % Make valid field name for struct
            validKey = matlab.lang.makeValidName(key);
            % Recursively convert nested values
            convertedValue = convertToStruct(value, emptyValueOption);
            % Handle empty values
            if isempty(convertedValue) && ~isstruct(convertedValue) && ~iscell(convertedValue)
                if emptyValueOption == "omit"
                    continue;  % Skip this key
                end
                % For "null", empty arrays will become null in JSON
            end
            result.(validKey) = convertedValue;
        end
    elseif isa(data, 'dictionary')
        % Dictionary -> struct
        result = struct();
        allKeys = keys(data);
        for i = 1:numel(allKeys)
            key = allKeys(i);
            value = data(key);
            if iscell(value)
                value = value{1};
            end
            validKey = matlab.lang.makeValidName(key);
            convertedValue = convertToStruct(value, emptyValueOption);
            if isempty(convertedValue) && ~isstruct(convertedValue) && ~iscell(convertedValue)
                if emptyValueOption == "omit"
                    continue;
                end
            end
            result.(validKey) = convertedValue;
        end
    elseif isa(data, 'containers.Map')
        % containers.Map -> struct
        result = struct();
        allKeys = keys(data);
        for i = 1:numel(allKeys)
            key = allKeys{i};
            value = data(key);
            validKey = matlab.lang.makeValidName(key);
            convertedValue = convertToStruct(value, emptyValueOption);
            if isempty(convertedValue) && ~isstruct(convertedValue) && ~iscell(convertedValue)
                if emptyValueOption == "omit"
                    continue;
                end
            end
            result.(validKey) = convertedValue;
        end
    elseif isstruct(data)
        % Struct - recursively convert fields
        if isscalar(data)
            result = struct();
            fields = fieldnames(data);
            for i = 1:numel(fields)
                fieldName = fields{i};
                value = data.(fieldName);
                convertedValue = convertToStruct(value, emptyValueOption);
                if isempty(convertedValue) && ~isstruct(convertedValue) && ~iscell(convertedValue)
                    if emptyValueOption == "omit"
                        continue;
                    end
                end
                result.(fieldName) = convertedValue;
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
            result{i} = convertToStruct(data{i}, emptyValueOption);
        end
    else
        % Scalars and arrays - pass through
        result = data;
    end
end
