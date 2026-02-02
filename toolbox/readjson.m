function data = readjson(filename, options)
%READJSON Read JSON file into a JSONData object
%   data = READJSON(filename) reads the JSON file and returns a JSONData
%   object with dot notation access to the configuration values.
%
%   data = READJSON(filename, Name, Value) specifies additional options:
%
%       'SequenceRule' - How to convert JSON arrays to MATLAB types
%           'auto'  - (default) Numeric arrays stay numeric, string arrays
%                     stay string, mixed arrays become cell arrays
%           'cell'  - All arrays are returned as cell arrays
%
%   JSON null values are converted to empty double arrays ([]).
%
%   Example:
%       % Read a package.json file
%       pkg = readjson('package.json');
%       disp(pkg.name)
%       disp(pkg.version)
%
%       % Access nested values
%       disp(pkg.scripts.test)
%
%       % Force all arrays to cells
%       pkg = readjson('package.json', 'SequenceRule', 'cell');
%
%   See also: writejson, jsondata, matlab.io.config.JSONData, jsondecode

    arguments
        filename {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFile}
        options.SequenceRule {mustBeMember(options.SequenceRule, ["auto", "cell"])} = "auto"
    end

    % Read file content
    fileContent = fileread(filename);

    % Parse JSON using built-in jsondecode
    try
        rawData = jsondecode(fileContent);
    catch ME
        error('readjson:ParseError', 'Failed to parse JSON file: %s\n%s', filename, ME.message);
    end

    % Convert to JSONData hierarchy
    data = convertToJSONData(rawData, options.SequenceRule);
end

function result = convertToJSONData(value, sequenceRule)
%CONVERTTOJSONDATA Recursively convert parsed JSON to JSONData objects
%   Converts struct hierarchies from jsondecode to JSONData objects.
%   Handles arrays according to SequenceRule option.

    if isstruct(value)
        if isscalar(value)
            % Scalar struct -> JSONData object
            result = matlab.io.config.JSONData();
            fields = fieldnames(value);
            for i = 1:numel(fields)
                fieldName = fields{i};
                fieldValue = value.(fieldName);
                % Recursively convert nested values
                convertedValue = convertToJSONData(fieldValue, sequenceRule);
                % Use dot assignment which handles key aliasing
                result.(fieldName) = convertedValue;
            end
        else
            % Struct array (from JSON array of objects)
            % Convert each element to JSONData
            result = cell(size(value));
            for i = 1:numel(value)
                result{i} = convertToJSONData(value(i), sequenceRule);
            end
            % Convert to JSONData array if all elements are JSONData
            if all(cellfun(@(x) isa(x, 'matlab.io.config.JSONData'), result))
                result = [result{:}];
                result = reshape(result, size(value));
            end
            % Apply SequenceRule
            if sequenceRule == "cell" && ~iscell(result)
                result = num2cell(result);
            end
        end
    elseif iscell(value)
        % Cell array (from JSON mixed-type array or string array)
        result = cell(size(value));
        for i = 1:numel(value)
            result{i} = convertToJSONData(value{i}, sequenceRule);
        end
        % For SequenceRule='auto', try to consolidate homogeneous cell arrays
        if sequenceRule == "auto" && ~isempty(result)
            result = consolidateArray(result);
        end
    elseif isnumeric(value) || islogical(value)
        % Numeric or logical array (including empty [] from null)
        if sequenceRule == "cell" && ~isscalar(value) && ~isempty(value)
            % Convert to cell array for SequenceRule='cell'
            result = num2cell(value);
        else
            result = value;
        end
    elseif ischar(value) || isstring(value)
        % String value
        result = string(value);
        if sequenceRule == "cell" && ~isscalar(result)
            % Convert string array to cell for SequenceRule='cell'
            result = cellstr(result);
        end
    else
        % Other types - pass through
        result = value;
    end
end

function result = consolidateArray(cellArray)
%CONSOLIDATEARRAY Try to convert cell array to homogeneous array
%   If all elements are the same type (numeric, string, logical, char),
%   consolidate into a native array. Otherwise keep as cell.

    if isempty(cellArray)
        result = cellArray;
        return;
    end

    % Check if all elements are strings (scalar string)
    if all(cellfun(@(x) isstring(x) && isscalar(x), cellArray))
        result = vertcat(cellArray{:});
        return;
    end

    % Check if all elements are char vectors (from jsondecode string arrays)
    if all(cellfun(@(x) ischar(x) && (isrow(x) || isempty(x)), cellArray))
        % Convert char vectors to string array
        result = string(cellArray);
        result = result(:);  % Make column vector
        return;
    end

    % Check if all elements are numeric scalars
    if all(cellfun(@(x) isnumeric(x) && isscalar(x), cellArray))
        result = vertcat(cellArray{:});
        return;
    end

    % Check if all elements are logical scalars
    if all(cellfun(@(x) islogical(x) && isscalar(x), cellArray))
        result = vertcat(cellArray{:});
        return;
    end

    % Keep as cell array for mixed types
    result = cellArray;
end
