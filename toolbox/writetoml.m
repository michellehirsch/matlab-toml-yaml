function writetoml(data, filename, options)
% WRITETOML Write data to TOML file
%
%   WRITETOML(DATA) writes DATA to 'untitled.toml' in the current directory.
%   DATA can be a TOMLData object, ConfigurationData object, or struct.
%
%   WRITETOML(DATA, FILENAME) writes DATA to the specified TOML file.
%
%   WRITETOML(..., Name, Value) specifies additional options using
%   name-value pairs:
%
%   'ArrayStyle' - Style for arrays (default: 'flow')
%                  'flow'  - Use inline style as [1, 2, 3]
%                  'block' - Use multi-line style with one item per line
%
%   'NumIndentationSpaces' - Number of spaces for indentation (default: 2)
%                            Must be a positive integer
%
%   'SectionSpacing' - Spacing between top-level tables (default: 'loose')
%                      'loose'   - Blank line between each top-level table
%                      'compact' - No blank lines
%
%   'Precision' - Number of significant digits for numeric values (default: 6)
%                 Must be a positive integer
%
%   'TableStyle' - Style for nested tables (default: 'auto')
%                  'auto'     - Use heuristics based on table size/complexity
%                  'inline'   - Always use inline tables {x = 1, y = 2}
%                  'expanded' - Always use expanded [table] headers
%
%   'TableArrayStyle' - Style for arrays of tables (default: 'expanded')
%                       'expanded' - Use [[table]] syntax (most common, readable)
%                       'inline'   - Use inline array syntax [{x=1}, {x=2}]
%                       'auto'     - Choose based on array size/complexity
%
%   'StringEscapeStyle' - String escape processing (default: 'auto')
%                         'auto'     - Choose escaped or literal automatically
%                         'escaped'  - Use escape-processing (TOML basic strings)
%                         'literal'  - Use literal strings (no escape processing)
%
%   'StringLayout' - String layout style (default: 'auto')
%                    'auto'       - Choose single-line or multiline automatically
%                    'singleline' - Always use single-line strings
%                    'multiline'  - Always use multiline delimiters
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
%   Compact format with flow arrays
%       writetoml(data, 'config.toml', ...
%           'ArrayStyle', 'flow', ...
%           'SectionSpacing', 'compact');
%
%   Expanded format with block arrays
%       writetoml(data, 'pyproject.toml', ...
%           'ArrayStyle', 'block', ...
%           'NumIndentationSpaces', 4);
%
%   Compact inline tables
%       writetoml(data, 'config.toml', ...
%           'TableStyle', 'inline');
%
%   Inline arrays of tables
%       writetoml(data, 'config.toml', ...
%           'TableArrayStyle', 'inline');
%
%   Literal strings for paths
%       writetoml(data, 'config.toml', ...
%           'StringEscapeStyle', 'literal');
%
%   Multiline strings
%       writetoml(data, 'config.toml', ...
%           'StringLayout', 'multiline');
%
% See also READTOML, TOMLData, ConfigurationData

%   Copyright 2025 The MathWorks, Inc.

    arguments
        data {mustBeA(data, ["TOMLData", "ConfigurationData", "struct"])}
        filename (1,1) string = "untitled.toml"
        options.ArrayStyle {mustBeMember(options.ArrayStyle, {'flow', 'block'})} = 'flow'
        options.NumIndentationSpaces (1,1) {mustBeInteger, mustBePositive} = 2
        options.SectionSpacing {mustBeMember(options.SectionSpacing, {'compact', 'loose'})} = 'loose'
        options.Precision (1,1) {mustBeInteger, mustBePositive} = 6
        options.TableStyle {mustBeMember(options.TableStyle, {'auto', 'inline', 'expanded'})} = 'auto'
        options.TableArrayStyle {mustBeMember(options.TableArrayStyle, {'auto', 'inline', 'expanded'})} = 'expanded'
        options.StringEscapeStyle {mustBeMember(options.StringEscapeStyle, {'auto', 'escaped', 'literal'})} = 'auto'
        options.StringLayout {mustBeMember(options.StringLayout, {'auto', 'singleline', 'multiline'})} = 'auto'
    end

    % Convert options for internal use
    useFlowArrays = strcmp(options.ArrayStyle, 'flow');
    addSectionSpacing = strcmp(options.SectionSpacing, 'loose');

    % Create options struct for passing to serialization functions
    serializeOpts = struct();
    serializeOpts.useFlowArrays = useFlowArrays;
    serializeOpts.indentSize = options.NumIndentationSpaces;
    serializeOpts.addSectionSpacing = addSectionSpacing;
    serializeOpts.precision = options.Precision;
    serializeOpts.tableStyle = options.TableStyle;
    serializeOpts.tableArrayStyle = options.TableArrayStyle;
    serializeOpts.stringEscapeStyle = options.StringEscapeStyle;
    serializeOpts.stringLayout = options.StringLayout;

    % Generate TOML content
    tomlContent = serializeToml(data, serializeOpts);

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

function tomlStr = serializeToml(data, opts)
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
        tomlStr = tomlStr + serializeKeyValue(key, value, opts) + newline;
    end

    if numel(rootPairs) > 0 && numel(tables) > 0
        tomlStr = tomlStr + newline;
    end

    % Write tables
    for i = 1:numel(tables)
        key = tables(i);
        value = getValue(data, key);
        tomlStr = tomlStr + serializeTable(key, value, "", opts);

        if i < numel(tables)
            if opts.addSectionSpacing
                tomlStr = tomlStr + newline;
            end
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

function tomlStr = serializeTable(tableName, tableData, prefix, opts)
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
        % Array of tables - check TableArrayStyle
        useInlineArray = shouldUseInlineTableArray(tableData, opts.tableArrayStyle);

        % Nested arrays of tables cannot be written inline (TOML limitation)
        % They must use [[table.subtable]] expanded syntax
        if useInlineArray && strlength(prefix) > 0
            useInlineArray = false;
        end

        if useInlineArray
            % Write as inline array of inline tables: key = [{x=1}, {x=2}]
            % Only valid at root level
            tomlStr = tableName + " = " + serializeArrayOfTables(tableData, opts) + newline;
        else
            % Write as expanded array of tables using [[table]] syntax
            for i = 1:numel(tableData)
                tomlStr = tomlStr + "[[" + fullName + "]]" + newline;
                tomlStr = tomlStr + serializeStructContent(tableData(i), fullName, opts);
                if i < numel(tableData)
                    tomlStr = tomlStr + newline;
                end
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
                tomlStr = tomlStr + serializeKeyValue(key, value, opts) + newline;
            end

            if numel(subtables) > 0
                tomlStr = tomlStr + newline;
            end
        end

        % Write subtables
        for i = 1:numel(subtables)
            key = subtables(i);
            value = getValue(tableData, key);
            tomlStr = tomlStr + serializeTable(key, value, fullName, opts);

            if i < numel(subtables)
                tomlStr = tomlStr + newline;
            end
        end
    end
end

function tomlStr = serializeStructContent(data, ~, opts)
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
            tomlStr = tomlStr + serializeKeyValue(key, value, opts) + newline;
        end
    end

    % Handle nested tables
    for i = 1:numel(allKeys)
        key = allKeys(i);
        value = getValue(data, key);

        if isstruct(value) || isa(value, 'ConfigurationData')
            tomlStr = tomlStr + serializeTable(key, value, "", opts);
        end
    end
end

function str = serializeKeyValue(key, value, opts)
    % Serialize a single key-value pair

    % Quote key if necessary
    if needsQuoting(key)
        keyStr = '"' + key + '"';
    else
        keyStr = key;
    end

    valueStr = serializeValue(value, opts, 0);
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

function str = serializeValue(value, opts, depth)
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
        str = formatTomlString(string(value), opts);

    elseif (isstring(value)) && isscalar(value)
        % Scalar string
        str = formatTomlString(value, opts);

    elseif isstring(value) && ~isscalar(value)
        % String array
        str = serializeArray(value, opts, depth);

    elseif isdatetime(value)
        % DateTime
        str = string(value, 'yyyy-MM-dd''T''HH:mm:ssXXX');

    elseif isnumeric(value) && isscalar(value)
        % Number - use precision parameter
        if value == floor(value) && abs(value) < 2^53
            str = sprintf('%d', value);
        else
            str = sprintf(['%.', num2str(opts.precision), 'g'], value);
        end

    elseif isnumeric(value) && ~isscalar(value)
        % Numeric array
        str = serializeArray(value, opts, depth);

    elseif isstruct(value) && isscalar(value)
        % Inline table
        str = serializeInlineTable(value, opts);

    elseif isa(value, 'ConfigurationData') && isscalar(value)
        % ConfigurationData as inline table
        str = serializeInlineTable(value, opts);

    else
        error('tomlToolbox:writetoml:UnsupportedType', ...
            'Cannot serialize value of type: %s', class(value));
    end
end

function str = serializeArray(arr, opts, depth)
    % Serialize array to TOML format

    if opts.useFlowArrays
        % Flow style: [item1, item2, item3]
        str = "[";

        for i = 1:numel(arr)
            str = str + serializeValue(arr(i), opts, depth + 1);

            if i < numel(arr)
                str = str + ", ";
            end
        end

        str = str + "]";
    else
        % Block style: multi-line with indentation
        str = "[" + newline;
        indent = repmat(' ', 1, (depth + 1) * opts.indentSize);

        for i = 1:numel(arr)
            str = str + indent + serializeValue(arr(i), opts, depth + 1);

            if i < numel(arr)
                str = str + "," + newline;
            else
                str = str + newline;
            end
        end

        closeIndent = repmat(' ', 1, depth * opts.indentSize);
        str = str + closeIndent + "]";
    end
end

function str = serializeInlineTable(tbl, opts)
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

        str = str + " = " + serializeValue(value, opts, 0);

        if i < numel(tableKeys)
            str = str + ", ";
        end
    end

    str = str + "}";
end

function str = serializeArrayOfTables(tableArray, opts)
    % Serialize array of tables as inline array: [{x=1}, {x=2}]

    str = "[";

    for i = 1:numel(tableArray)
        str = str + serializeInlineTable(tableArray(i), opts);

        if i < numel(tableArray)
            str = str + ", ";
        end
    end

    str = str + "]";
end

function useInline = shouldUseInlineTableArray(tableArray, style)
    % Determine whether to use inline array of tables based on style setting

    if strcmp(style, 'inline')
        useInline = true;
    elseif strcmp(style, 'expanded')
        useInline = false;
    else % 'auto'
        % Heuristic: use inline if array has ≤2 elements and each has ≤3 simple fields
        if numel(tableArray) > 2
            useInline = false;
            return;
        end

        % Check each element
        for i = 1:numel(tableArray)
            elem = tableArray(i);

            % Get keys
            if isa(elem, 'ConfigurationData')
                keys = elem.keys();
            else
                keys = string(fieldnames(elem));
            end

            % Too many fields?
            if numel(keys) > 3
                useInline = false;
                return;
            end

            % Check if any values are complex (nested tables)
            for j = 1:numel(keys)
                value = getValue(elem, keys(j));
                if isstruct(value) || isa(value, 'ConfigurationData')
                    useInline = false;
                    return;
                end
            end
        end

        useInline = true;
    end
end

function str = formatTomlString(value, opts)
    % Format string value according to StringEscapeStyle and StringLayout options

    % Determine escape style
    if strcmp(opts.stringEscapeStyle, 'literal')
        useLiteral = true;
    elseif strcmp(opts.stringEscapeStyle, 'escaped')
        useLiteral = false;
    else % 'auto'
        % Use literal if string contains backslashes but no actual escape sequences
        useLiteral = shouldUseLiteralString(value);
    end

    % Determine layout
    if strcmp(opts.stringLayout, 'multiline')
        useMultiline = true;
    elseif strcmp(opts.stringLayout, 'singleline')
        useMultiline = false;
    else % 'auto'
        % Use multiline if string contains newlines
        useMultiline = contains(value, newline);
    end

    % Format the string
    if useMultiline
        if useLiteral
            % Multi-line literal string: '''...'''
            str = "'''" + value + "'''";
        else
            % Multi-line basic string: """..."""
            escapedValue = escapeString(value);
            str = '"""' + escapedValue + '"""';
        end
    else
        if useLiteral
            % Single-line literal string: '...'
            str = "'" + value + "'";
        else
            % Single-line basic string: "..."
            str = '"' + escapeString(value) + '"';
        end
    end
end

function useLiteral = shouldUseLiteralString(value)
    % Heuristic: use literal strings for paths and strings with backslashes
    % but no escape sequences that need processing

    % If no backslashes, doesn't matter
    if ~contains(value, '\')
        useLiteral = false;
        return;
    end

    % If contains common escape sequences, use escaped
    if contains(value, '\n') || contains(value, '\t') || contains(value, '\r') || contains(value, '\"')
        useLiteral = false;
        return;
    end

    % Looks like a path or similar - use literal
    useLiteral = true;
end

function str = escapeString(str)
    % Escape special characters in string

    str = strrep(str, '\', '\\');
    str = strrep(str, '"', '\"');
    str = strrep(str, newline, '\n');
    str = strrep(str, sprintf('\t'), '\t');
    str = strrep(str, sprintf('\r'), '\r');
end
