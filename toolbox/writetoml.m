function writetoml(data, filename)
% WRITETOML Write data to TOML file
%
%   WRITETOML(DATA) writes DATA to 'untitled.toml' in the current directory.
%   DATA can be a TOMLData object, ConfigurationData object, or struct.
%
%   WRITETOML(DATA, FILENAME) writes DATA to the specified TOML file.
%
% Examples:
%   Write TOMLData to file
%       config = TOMLData();
%       config.project.name = "my-package";
%       config.project.version = "1.0.0";
%       writetoml(config, 'pyproject.toml');
%
%   Write with default filename
%       writetoml(config);  % Creates untitled.toml
%
%   Write struct
%       s.title = "Config";
%       s.database.host = "localhost";
%       writetoml(s, 'config.toml');
%
% See also READTOML, TOMLData, ConfigurationData

    arguments
        data {mustBeA(data, ["TOMLData", "ConfigurationData", "struct"])}
        filename (1,1) string = "untitled.toml"
    end

    % Convert ConfigurationData/TOMLData if needed - write directly from it
    % No conversion needed, just pass through
    dataToWrite = data;

    % Generate TOML content
    tomlContent = serializeToml(dataToWrite);

    % Write to file
    fid = fopen(filename, 'w', 'n', 'UTF-8');
    if fid == -1
        error('tomlToolbox:writetoml:FileOpenError', ...
            'Cannot open file for writing: %s', filename);
    end

    try
        fprintf(fid, '%s', tomlContent);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    fclose(fid);
end

function s = configDataToStruct(data)
    % Convert ConfigurationData to struct, preserving key order
    s = struct();
    
    if isa(data, 'ConfigurationData')
        keys = data.keys();
        for i = 1:length(keys)
            key = char(keys(i));
            value = data.(key);
            
            % Recursively convert nested ConfigurationData
            if isa(value, 'ConfigurationData')
                if numel(value) > 1
                    % Array of ConfigurationData - convert each element
                    valueArray = struct([]);
                    for j = 1:numel(value)
                        valueArray(j) = configDataToStruct(value(j));
                    end
                    value = valueArray;
                else
                    value = configDataToStruct(value);
                end
            end
            
            % Use original key (may have hyphens, etc.)
            fieldName = matlab.lang.makeValidName(key);
            s.(fieldName) = value;
            
            % Store original key name as metadata (we'll use this for writing)
            if ~strcmp(fieldName, key)
                % Key was modified - we need to track this
                % For now, just use the valid fieldname
                % TODO: Consider adding metadata field
            end
        end
    else
        s = struct(data);
    end
end

function tomlStr = serializeToml(data)
    % Serialize struct or ConfigurationData to TOML string
    
    tomlStr = "";
    
    % Get keys based on type
    if isa(data, 'ConfigurationData')
        allKeys = data.keys();
    else
        allKeys = string(fieldnames(data));
    end
    
    % Separate root key-values from tables
    rootPairs = string.empty;
    tables = string.empty;
    
    for i = 1:numel(allKeys)
        key = allKeys(i);
        value = getValue(data, key);
        
        if (isstruct(value) && numel(value) == 1) || ...
           (isa(value, 'ConfigurationData') && numel(value) == 1) || ...
           (isstruct(value) && numel(value) > 1) || ...
           (isa(value, 'ConfigurationData') && numel(value) > 1)
            tables = [tables, key]; %#ok<AGROW>
        else
            rootPairs = [rootPairs, key]; %#ok<AGROW>
        end
    end
    
    % Write root key-value pairs first
    for i = 1:numel(rootPairs)
        key = rootPairs(i);
        value = getValue(data, key);
        tomlStr = tomlStr + serializeKeyValue(key, value) + newline;
    end
    
    if numel(rootPairs) > 0 && numel(tables) > 0
        tomlStr = tomlStr + newline;
    end
    
    % Write tables
    for i = 1:numel(tables)
        key = tables(i);
        value = getValue(data, key);
        tomlStr = tomlStr + serializeTable(key, value, "");
        
        if i < numel(tables)
            tomlStr = tomlStr + newline;
        end
    end
end

function value = getValue(data, key)
    % Get value from struct or ConfigurationData
    if isa(data, 'ConfigurationData')
        value = data.(char(key));
    else
        value = data.(key);
    end
end

function tomlStr = serializeTable(tableName, tableData, prefix)
    % Serialize table with given prefix
    
    tomlStr = "";
    
    % Build full table name
    if strlength(prefix) > 0
        fullName = prefix + "." + tableName;
    else
        fullName = tableName;
    end
    
    % Check if this is an array (array of tables)
    if (isstruct(tableData) && numel(tableData) > 1) || ...
       (isa(tableData, 'ConfigurationData') && numel(tableData) > 1)
        % Array of tables
        for i = 1:numel(tableData)
            tomlStr = tomlStr + "[[" + fullName + "]]" + newline;
            tomlStr = tomlStr + serializeStructContent(tableData(i), fullName);
            if i < numel(tableData)
                tomlStr = tomlStr + newline;
            end
        end
    elseif isstruct(tableData) || isa(tableData, 'ConfigurationData')
        % Regular table - get keys
        if isa(tableData, 'ConfigurationData')
            allKeys = tableData.keys();
        else
            allKeys = string(fieldnames(tableData));
        end
        
        % Separate key-values from subtables
        pairs = string.empty;
        subtables = string.empty;
        
        for i = 1:numel(allKeys)
            key = allKeys(i);
            value = getValue(tableData, key);
            
            if isstruct(value) || isa(value, 'ConfigurationData')
                subtables = [subtables, key]; %#ok<AGROW>
            else
                pairs = [pairs, key]; %#ok<AGROW>
            end
        end
        
        % Only write table header if there are key-value pairs
        if numel(pairs) > 0
            tomlStr = tomlStr + "[" + fullName + "]" + newline;
            
            for i = 1:numel(pairs)
                key = pairs(i);
                value = getValue(tableData, key);
                tomlStr = tomlStr + serializeKeyValue(key, value) + newline;
            end
            
            if numel(subtables) > 0
                tomlStr = tomlStr + newline;
            end
        end
        
        % Write subtables
        for i = 1:numel(subtables)
            key = subtables(i);
            value = getValue(tableData, key);
            tomlStr = tomlStr + serializeTable(key, value, fullName);
            
            if i < numel(subtables)
                tomlStr = tomlStr + newline;
            end
        end
    end
end

function tomlStr = serializeStructContent(data, ~)
    % Serialize struct or ConfigurationData content without table header
    
    tomlStr = "";
    
    % Get keys
    if isa(data, 'ConfigurationData')
        allKeys = data.keys();
    else
        allKeys = string(fieldnames(data));
    end
    
    for i = 1:numel(allKeys)
        key = allKeys(i);
        value = getValue(data, key);
        
        if ~isstruct(value) && ~isa(value, 'ConfigurationData')
            tomlStr = tomlStr + serializeKeyValue(key, value) + newline;
        end
    end
    
    % Handle nested tables
    for i = 1:numel(allKeys)
        key = allKeys(i);
        value = getValue(data, key);
        
        if isstruct(value) || isa(value, 'ConfigurationData')
            tomlStr = tomlStr + serializeTable(key, value, "");
        end
    end
end

function str = serializeKeyValue(key, value)
    % Serialize a single key-value pair
    
    % Quote key if necessary
    if needsQuoting(key)
        keyStr = '"' + key + '"';
    else
        keyStr = key;
    end
    
    valueStr = serializeValue(value);
    str = keyStr + " = " + valueStr;
end

function tf = needsQuoting(key)
    % Check if key needs quoting
    % Per TOML spec, bare keys may only contain:
    %   A-Z, a-z, 0-9, -, _
    % All other characters require quoting

    % Check if key contains only valid bare key characters
    if isempty(regexp(char(key), '^[A-Za-z0-9_-]+$', 'once'))
        tf = true;
    else
        tf = false;
    end
end

function str = serializeValue(value)
    % Serialize a value to TOML format
    
    if islogical(value)
        % Boolean
        if value
            str = "true";
        else
            str = "false";
        end
        
    elseif ischar(value)
        % Char array - treat as string
        str = '"' + escapeString(string(value)) + '"';
        
    elseif (isstring(value)) && isscalar(value)
        % Scalar string
        str = '"' + escapeString(value) + '"';
        
    elseif isstring(value) && ~isscalar(value)
        % String array
        str = serializeArray(value);
        
    elseif isdatetime(value)
        % DateTime
        str = string(value, 'yyyy-MM-dd''T''HH:mm:ssXXX');
        
    elseif isnumeric(value) && isscalar(value)
        % Number - use heuristic for integer vs float
        if value == floor(value) && abs(value) < 2^53
            str = sprintf('%d', value);
        else
            str = sprintf('%.15g', value);
        end
        
    elseif isnumeric(value) && ~isscalar(value)
        % Numeric array
        str = serializeArray(value);
        
    elseif isstruct(value) && isscalar(value)
        % Inline table
        str = serializeInlineTable(value);
        
    elseif isa(value, 'ConfigurationData') && isscalar(value)
        % ConfigurationData as inline table
        str = serializeInlineTable(value);
        
    else
        error('tomlToolbox:writetoml:UnsupportedType', ...
            'Cannot serialize value of type: %s', class(value));
    end
end

function str = serializeArray(arr)
    % Serialize array to TOML format
    
    str = "[";
    
    for i = 1:numel(arr)
        str = str + serializeValue(arr(i));
        
        if i < numel(arr)
            str = str + ", ";
        end
    end
    
    str = str + "]";
end

function str = serializeInlineTable(tbl)
    % Serialize inline table (struct or ConfigurationData)
    
    str = "{";
    
    % Get keys
    if isa(tbl, 'ConfigurationData')
        tableKeys = tbl.keys();
    else
        tableKeys = string(fieldnames(tbl));
    end
    
    for i = 1:numel(tableKeys)
        fieldName = tableKeys(i);
        value = getValue(tbl, fieldName);
        
        if needsQuoting(fieldName)
            str = str + '"' + fieldName + '"';
        else
            str = str + fieldName;
        end
        
        str = str + " = " + serializeValue(value);
        
        if i < numel(tableKeys)
            str = str + ", ";
        end
    end
    
    str = str + "}";
end

function str = escapeString(str)
    % Escape special characters in string
    
    str = strrep(str, '\', '\\');
    str = strrep(str, '"', '\"');
    str = strrep(str, newline, '\n');
    str = strrep(str, sprintf('\t'), '\t');
    str = strrep(str, sprintf('\r'), '\r');
end
