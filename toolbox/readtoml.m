function data = readtoml(filename, options)
% READTOML Read TOML file and return TOMLData object
%
%   DATA = READTOML(FILENAME) reads a TOML file and returns a TOMLData object
%   with dot notation access and support for special characters in field names.
%
%   DATA = READTOML(FILENAME, Name, Value) specifies options:
%       DatetimeType - How to represent dates ('datetime' | 'string')
%                      Default: 'datetime'
%
% Examples:
%   Read TOML file
%       config = readtoml('pyproject.toml');
%       name = config.project.name;
%       deps = config.("build-system").requires;
%
%   Access with special characters
%       version = config.("project").("version");
%
%   Display as TOML
%       config.show();
%
%   Convert to struct
%       s = struct(config);
%
% See also WRITETOML, TOMLData, ConfigurationData

    arguments
        filename (1,1) string {mustBeFile}
        options.DatetimeType (1,1) string ...
            {mustBeMember(options.DatetimeType, ["datetime", "string"])} = "datetime"
    end

    % Read file contents
    fileContent = readFileAsString(filename);

    % Parse TOML content
    data = parseToml(fileContent, options.DatetimeType);
end

function content = readFileAsString(filename)
    % Read file and return as string
    fid = fopen(filename, 'r', 'n', 'UTF-8');
    if fid == -1
        error('tomlToolbox:readtoml:FileOpenError', 'Cannot open file: %s', filename);
    end

    try
        content = string(fread(fid, '*char')');
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    fclose(fid);
end

function data = parseToml(content, datetimeType)
    % Parse TOML content string and return TOMLData object
    
    % Initialize root TOMLData
    data = TOMLData();
    currentTable = data;
    currentTablePath = "";
    currentArrayIndex = 0;  % Track if we're in an array of tables

    % Split into lines
    lines = splitlines(content);

    % Track array of tables
    arrayOfTables = containers.Map('KeyType', 'char', 'ValueType', 'double');

    for i = 1:numel(lines)
        line = strtrim(lines(i));

        % Skip empty lines and comments
        if strlength(line) == 0 || startsWith(line, "#")
            continue;
        end

        % Check for table headers
        if startsWith(line, "[[") && endsWith(line, "]]")
            % Array of tables
            tableName = extractBetween(line, 3, strlength(line) - 2);
            tableName = strtrim(tableName);
            [data, currentTable, currentTablePath, currentArrayIndex] = handleArrayOfTables(data, tableName, arrayOfTables);

        elseif startsWith(line, "[") && endsWith(line, "]")
            % Standard table
            tableName = extractBetween(line, 2, strlength(line) - 1);
            tableName = strtrim(tableName);
            [data, currentTable, currentTablePath] = handleTable(data, tableName);
            currentArrayIndex = 0;  % Not in array anymore

        else
            % Key-value pair
            [data, currentTable] = parseKeyValue(data, currentTable, currentTablePath, currentArrayIndex, line, datetimeType);
        end
    end
end

function [rootData, tableRef, tablePath] = handleTable(rootData, tableName)
    % Handle [table] syntax
    
    keys = split(tableName, ".");
    tablePath = tableName;

    % Build the nested structure
    rootData = ensureDataPath(rootData, keys, "");

    % Get reference to the table
    tableRef = getDataPath(rootData, tablePath);
end

function data = ensureDataPath(data, pathKeys, currentPath)
    % Ensure a path exists in TOMLData, creating it if necessary
    if isempty(pathKeys)
        return;
    end

    key = char(strtrim(pathKeys(1)));

    if ~isfield(data, key)
        data.(key) = TOMLData();
    end

    % Recursively ensure rest of path
    if numel(pathKeys) > 1
        nestedData = data.(key);
        data.(key) = ensureDataPath(nestedData, pathKeys(2:end), currentPath);
    end
end

function [rootData, tableRef, tablePath, arrayIndex] = handleArrayOfTables(rootData, tableName, arrayOfTables)
    % Handle [[array.of.tables]] syntax
    
    keys = split(tableName, ".");
    tablePath = char(tableName);

    % Ensure parent path exists
    if numel(keys) > 1
        rootData = ensureDataPath(rootData, keys(1:end-1), "");
    end

    % Handle array element
    lastKey = char(strtrim(keys(end)));

    % Navigate to the parent context
    if numel(keys) > 1
        parentPath = join(keys(1:end-1), ".");
        parent = getDataPath(rootData, parentPath);
    else
        parent = rootData;
    end

    % Create new element
    newElement = TOMLData();
    
    
    if ~isfield(parent, lastKey)
        % First element - just assign
        fprintf('  First element, creating\n');
        parent.(lastKey) = newElement;
        arrayIndex = 1;
        arrayOfTables(tablePath) = arrayIndex;
        fprintf('  After assign, length(parent.%s) = %d\n', lastKey, length(parent.(lastKey)));
    elseif isKey(arrayOfTables, tablePath)
        % Append to existing array
        currentArray = parent.(lastKey);
        fprintf('  Appending, currentArray length = %d\n', length(currentArray));
        if isa(currentArray, 'TOMLData')
            parent.(lastKey) = [currentArray, newElement];
            fprintf('  After append, length(parent.%s) = %d\n', lastKey, length(parent.(lastKey)));
        else
            error('tomlToolbox:readtoml:InvalidArrayOfTables', ...
                'Key "%s" is not a TOMLData array', lastKey);
        end
            arrayIndex = arrayOfTables(tablePath) + 1;
            arrayOfTables(tablePath) = arrayIndex;
    else
        error('tomlToolbox:readtoml:InvalidArrayOfTables', ...
            'Key "%s" already exists and is not an array of tables', lastKey);
    end
    
    % Write parent back to rootData
    fprintf('  Writing back to rootData\n');
    if numel(keys) > 1
        parentPath = keys(1:end-1);
        rootData = setDataPath(rootData, parentPath, parent);
    else
        rootData = parent;
    end
    fprintf('  After writeback, length(rootData.%s) = %d\n', lastKey, length(rootData.(lastKey)));
    
    tableRef = newElement;
end

function [rootData, tableRef] = parseKeyValue(rootData, tableRef, tablePath, arrayIndex, line, datetimeType)
    % Parse key = value line
    
    % Find first '=' not in quotes
    eqPos = findUnquotedChar(line, '=');

    if eqPos == 0
        error('tomlToolbox:readtoml:InvalidSyntax', 'Invalid key-value syntax: %s', line);
    end

    keyPart = strtrim(extractBefore(line, eqPos));
    valuePart = strtrim(extractAfter(line, eqPos));

    % Remove quotes from key if present
    key = cleanKey(keyPart);

    % Parse value
    value = parseValue(valuePart, datetimeType);

    % Handle dotted keys (e.g., a.b.c = value)
    if contains(keyPart, ".")
        keys = split(keyPart, ".");
        currentData = tableRef;

        for i = 1:numel(keys) - 1
            k = char(cleanKey(strtrim(keys(i))));

            if ~isfield(currentData, k)
                currentData.(k) = TOMLData();
            end
            currentData = currentData.(k);
        end

        finalKey = char(cleanKey(strtrim(keys(end))));
        currentData.(finalKey) = value;

        % Update tableRef in rootData
        if strlength(tablePath) == 0
            rootData = updateDataPath(rootData, split(keyPart, "."), currentData, numel(keys) - 1);
        else
            rootData = updateDataPath(rootData, [split(tablePath, "."); split(keyPart, ".")], currentData, numel(keys) - 1);
        end
        tableRef = getDataPath(rootData, tablePath);
    else
        tableRef.(char(key)) = value;
        % Update in rootData
        if arrayIndex > 0
            % Update array element
            pathKeys = split(tablePath, ".");
            currentArray = getDataPath(rootData, tablePath);
            currentArray(arrayIndex).(char(key)) = value;
            rootData = setDataPath(rootData, pathKeys, currentArray);
            tableRef = currentArray(arrayIndex);
        elseif strlength(tablePath) == 0
            rootData = tableRef;
        else
            pathKeys = split(tablePath, ".");
            rootData = setDataPath(rootData, pathKeys, tableRef);
        end
    end
end

function data = setDataPath(data, pathKeys, value)
    % Set a value at a specific path
    if numel(pathKeys) == 1
        data.(char(pathKeys(1))) = value;
    else
        key = char(pathKeys(1));
        if isfield(data, key)
            data.(key) = setDataPath(data.(key), pathKeys(2:end), value);
        else
            data.(key) = setDataPath(TOMLData(), pathKeys(2:end), value);
        end
    end
end

function data = updateDataPath(data, pathKeys, value, levelsFromEnd)
    % Update data at given path
    if levelsFromEnd == 0
        data = value;
        return;
    end

    key = char(pathKeys(1));
    if numel(pathKeys) == 1
        data.(key) = value;
    else
        if isfield(data, key)
            data.(key) = updateDataPath(data.(key), pathKeys(2:end), value, levelsFromEnd - 1);
        else
            data.(key) = updateDataPath(TOMLData(), pathKeys(2:end), value, levelsFromEnd - 1);
        end
    end
end

function tableRef = getDataPath(data, tablePath)
    % Get reference at given path
    if strlength(tablePath) == 0
        tableRef = data;
        return;
    end

    keys = split(tablePath, ".");
    tableRef = data;

    for i = 1:numel(keys)
        tableRef = tableRef.(char(keys(i)));
    end
end

function pos = findUnquotedChar(str, char)
    % Find position of character not inside quotes
    
    inQuotes = false;
    quoteChar = '';

    for i = 1:strlength(str)
        c = extractBetween(str, i, i);

        if (c == '"' || c == "'") && ~inQuotes
            inQuotes = true;
            quoteChar = c;
        elseif c == quoteChar && inQuotes
            inQuotes = false;
        elseif c == char && ~inQuotes
            pos = i;
            return;
        end
    end

    pos = 0;
end

function key = cleanKey(keyStr)
    % Remove quotes from key if present
    
    keyStr = strtrim(keyStr);

    if (startsWith(keyStr, '"') && endsWith(keyStr, '"')) || ...
       (startsWith(keyStr, "'") && endsWith(keyStr, "'"))
        key = extractBetween(keyStr, 2, strlength(keyStr) - 1);
    else
        key = keyStr;
    end
end

function value = parseValue(valueStr, datetimeType)
    % Parse TOML value from string
    
    valueStr = strtrim(valueStr);

    % Remove inline comments
    valueStr = removeInlineComment(valueStr);

    % Arrays
    if startsWith(valueStr, "[")
        value = parseArray(valueStr, datetimeType);

    % Inline tables  
    elseif startsWith(valueStr, "{")
        value = parseInlineTable(valueStr, datetimeType);

    % Strings
    elseif startsWith(valueStr, '"') || startsWith(valueStr, "'")
        value = parseString(valueStr);

    % Booleans
    elseif valueStr == "true"
        value = true;
    elseif valueStr == "false"
        value = false;

    % DateTime
    elseif isDateTime(valueStr)
        if datetimeType == "datetime"
            value = parseDatetime(valueStr);
        else
            value = char(valueStr);
        end

    % Numbers
    else
        value = parseNumber(valueStr);
    end
end

function valueStr = removeInlineComment(valueStr)
    % Remove inline comments from value string
    
    inQuotes = false;
    quoteChar = '';

    for i = 1:strlength(valueStr)
        c = extractBetween(valueStr, i, i);

        if (c == '"' || c == "'") && ~inQuotes
            inQuotes = true;
            quoteChar = c;
        elseif c == quoteChar && inQuotes
            inQuotes = false;
        elseif c == "#" && ~inQuotes
            valueStr = extractBefore(valueStr, i);
            return;
        end
    end
end

function arr = parseArray(arrayStr, datetimeType)
    % Parse TOML array
    
    arrayStr = strtrim(arrayStr);

    if ~startsWith(arrayStr, "[") || ~endsWith(arrayStr, "]")
        error('tomlToolbox:readtoml:InvalidArray', 'Invalid array syntax');
    end

    content = extractBetween(arrayStr, 2, strlength(arrayStr) - 1);
    content = strtrim(content);

    if strlength(content) == 0
        arr = [];
        return;
    end

    % Split by commas (respecting nesting)
    elements = splitArrayElements(content);

    % Parse each element
    parsedElements = cell(size(elements));
    for i = 1:numel(elements)
        parsedElements{i} = parseValue(elements(i), datetimeType);
    end

    % Try to convert to homogeneous array
    if numel(parsedElements) > 0
        % Check if all same type
        firstType = class(parsedElements{1});
        allSame = true;
        for i = 2:numel(parsedElements)
            if ~strcmp(class(parsedElements{i}), firstType)
                allSame = false;
                break;
            end
        end

        if allSame && (isnumeric(parsedElements{1}) || islogical(parsedElements{1}))
            % Convert to numeric/logical array
            arr = [parsedElements{:}];
        elseif allSame && (ischar(parsedElements{1}) || isstring(parsedElements{1}))
            % Convert to string array
            arr = string(parsedElements);
        elseif allSame && isa(parsedElements{1}, 'TOMLData')
            % Object array
            arr = [parsedElements{:}];
        else
            % Keep as cell array for mixed types
            arr = parsedElements;
        end
    else
        arr = [];
    end
end

function elements = splitArrayElements(content)
    % Split array content by commas, respecting nesting
    
    elements = string.empty;
    currentElement = "";
    depth = 0;
    inQuotes = false;
    quoteChar = '';

    for i = 1:strlength(content)
        c = extractBetween(content, i, i);

        if (c == '"' || c == "'") && ~inQuotes
            inQuotes = true;
            quoteChar = c;
            currentElement = currentElement + c;
        elseif c == quoteChar && inQuotes
            inQuotes = false;
            currentElement = currentElement + c;
        elseif ~inQuotes && (c == "[" || c == "{")
            depth = depth + 1;
            currentElement = currentElement + c;
        elseif ~inQuotes && (c == "]" || c == "}")
            depth = depth - 1;
            currentElement = currentElement + c;
        elseif c == "," && depth == 0 && ~inQuotes
            elements = [elements, strtrim(currentElement)]; %#ok<AGROW>
            currentElement = "";
        else
            currentElement = currentElement + c;
        end
    end

    if strlength(currentElement) > 0
        elements = [elements, strtrim(currentElement)];
    end
end

function tbl = parseInlineTable(tableStr, datetimeType)
    % Parse inline table {key = value, ...} - returns TOMLData
    
    tableStr = strtrim(tableStr);

    if ~startsWith(tableStr, "{") || ~endsWith(tableStr, "}")
        error('tomlToolbox:readtoml:InvalidInlineTable', 'Invalid inline table syntax');
    end

    content = extractBetween(tableStr, 2, strlength(tableStr) - 1);
    content = strtrim(content);

    tbl = TOMLData();  % Return TOMLData instead of struct

    if strlength(content) == 0
        return;
    end

    % Split by commas
    pairs = splitArrayElements(content);

    for i = 1:numel(pairs)
        pair = pairs(i);
        eqPos = findUnquotedChar(pair, '=');

        if eqPos == 0
            error('tomlToolbox:readtoml:InvalidInlineTable', 'Invalid key-value pair in inline table');
        end

        key = cleanKey(strtrim(extractBetween(pair, 1, eqPos - 1)));
        valuePart = strtrim(extractAfter(pair, eqPos));
        value = parseValue(valuePart, datetimeType);

        tbl.(char(key)) = value;
    end
end

function str = parseString(strValue)
    % Parse TOML string
    
    strValue = strtrim(strValue);

    % Multi-line strings
    if startsWith(strValue, '"""') || startsWith(strValue, "'''")
        error('tomlToolbox:readtoml:NotImplemented', 'Multi-line strings not yet implemented');
    end

    % Regular strings
    if startsWith(strValue, '"') && endsWith(strValue, '"')
        str = char(extractBetween(strValue, 2, strlength(strValue) - 1));
        str = unescapeString(str);
    elseif startsWith(strValue, "'") && endsWith(strValue, "'")
        % Literal string (no escaping)
        str = char(extractBetween(strValue, 2, strlength(strValue) - 1));
    else
        error('tomlToolbox:readtoml:InvalidString', 'Invalid string syntax');
    end
end

function str = unescapeString(str)
    % Unescape string escape sequences
    
    str = strrep(str, '\"', '"');
    str = strrep(str, '\\', '\');
    str = strrep(str, '\n', newline);
    str = strrep(str, '\t', sprintf('\t'));
    str = strrep(str, '\r', sprintf('\r'));
end

function tf = isDateTime(str)
    % Check if string is a datetime value
    
    % Simple check for ISO 8601 format
    pattern = '\d{4}-\d{2}-\d{2}';
    tf = ~isempty(regexp(char(str), pattern, 'once'));
end

function dt = parseDatetime(str)
    % Parse datetime string
    
    try
        dt = datetime(str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ssXXX', 'TimeZone', 'UTC');
    catch
        try
            dt = datetime(str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
        catch
            try
                dt = datetime(str, 'InputFormat', 'yyyy-MM-dd');
            catch
                try
                    dt = datetime(str, 'InputFormat', 'HH:mm:ss');
                catch
                    error('tomlToolbox:readtoml:InvalidDatetime', 'Cannot parse datetime: %s', str);
                end
            end
        end
    end
end

function num = parseNumber(numStr)
    % Parse TOML number (integer or float)
    
    numStr = char(strtrim(numStr));

    % Remove underscores (TOML allows _ in numbers)
    numStr = strrep(numStr, '_', '');

    % Hex, octal, binary
    if startsWith(numStr, '0x')
        num = hex2dec(extractAfter(numStr, 2));
    elseif startsWith(numStr, '0o')
        num = base2dec(extractAfter(numStr, 2), 8);
    elseif startsWith(numStr, '0b')
        num = bin2dec(extractAfter(numStr, 2));
    else
        % Regular number
        num = str2double(numStr);

        if isnan(num)
            error('tomlToolbox:readtoml:InvalidNumber', 'Invalid number: %s', numStr);
        end
    end
end






