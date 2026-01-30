function writeyaml(data, filename, options)
%WRITEYAML Write data to YAML file
%   WRITEYAML(DATA) writes the MATLAB data to 'untitled.yaml'.
%
%   WRITEYAML(DATA, FILENAME) writes to the specified file.
%
%   DATA can be a YAMLData object, ConfigurationData, struct, dictionary,
%   containers.Map, cell array, or other MATLAB data type.
%
%   WRITEYAML(..., Name, Value) specifies additional options using
%   name-value pairs:
%
%   'ArrayStyle' - Style for arrays/lists (default: 'block')
%                  'block' - Use block style with - items
%                  'flow'  - Use inline style as [1, 2, 3]
%
%   'NumIndentationSpaces' - Number of spaces for indentation (default: 2)
%                            Must be a positive integer
%
%   'SectionSpacing' - Spacing between top-level sections (default: 'loose')
%                      'loose'   - Blank line between each top-level key
%                      'compact' - No blank lines
%
%   'Precision' - Number of decimal places for numeric values (default: 6)
%                 Must be a positive integer
%
%   Examples:
%       % Write to default filename
%       writeyaml(data);  % Creates untitled.yaml
%
%       % Write to specific file
%       writeyaml(data, 'output.yaml');
%
%       % Compact format with 4-space indentation
%       writeyaml(myData, 'data.yml', ...
%           'NumIndentationSpaces', 4, ...
%           'SectionSpacing', 'compact');
%
%       % Flow style for compact arrays
%       writeyaml(data, 'list.yaml', 'ArrayStyle', 'flow');
%
%   See also READYAML, YAMLData

%   Copyright 2025 The MathWorks, Inc.

    arguments
        data
        filename {mustBeTextScalar, mustBeNonzeroLengthText} = "untitled.yaml"
        options.ArrayStyle {mustBeMember(options.ArrayStyle, {'block', 'flow'})} = 'block'
        options.NumIndentationSpaces (1,1) {mustBeInteger, mustBePositive} = 2
        options.SectionSpacing {mustBeMember(options.SectionSpacing, {'compact', 'loose'})} = 'loose'
        options.Precision (1,1) {mustBeInteger, mustBePositive} = 6
    end

    % Convert dictionary to YAMLData for consistent processing
    if isa(data, 'dictionary')
        data = YAMLData(data);
    end

    % Convert ArrayStyle to boolean for internal use
    flowStyle = options.ArrayStyle == "flow";

    % Convert SectionSpacing to boolean for internal use
    addSectionSpacing = options.SectionSpacing == "loose";

    % Generate YAML text
    try
        yamlText = generateYAML(data, 0, options.NumIndentationSpaces, flowStyle, options.Precision, addSectionSpacing);
    catch ME
        error('yamlToolbox:yamlwrite:GenerateError', ...
            'Error generating YAML content: %s', ME.message);
    end

    % Write to file
    try
        writelines(yamlText, filename, WriteMode="overwrite");
    catch ME
        error('yamlToolbox:yamlwrite:FileWriteError', ...
            'Unable to write to file "%s": %s', filename, ME.message);
    end
end

function yamlText = generateYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing)
    %GENERATEYAML Generate YAML text from MATLAB data

    if isempty(data)
        yamlText = 'null';
        return;
    end

    % Handle different data types
    if isa(data, 'ConfigurationData')
        % Check if it's an array
        if numel(data) > 1
            % Object array - convert to cell array and process
            dataCell = arrayfun(@(x) x, data, 'UniformOutput', false);
            yamlText = cellToYAML(dataCell, depth, indentSize, flowStyle, precision, addSectionSpacing);
        else
            % Single ConfigurationData object
            yamlText = configDataToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing);
        end
    elseif isstruct(data)
        yamlText = structToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing);
    elseif isa(data, 'containers.Map')
        yamlText = mapToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing);
    elseif iscell(data)
        yamlText = cellToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing);
    elseif isstring(data) && numel(data) > 1
        % String array with multiple elements
        yamlText = stringArrayToYAML(data, depth, indentSize, flowStyle);
    elseif isnumeric(data) || islogical(data)
        yamlText = numericToYAML(data, depth, indentSize, flowStyle, precision);
    elseif ischar(data) || (isstring(data) && isscalar(data))
        % Scalar string or char
        yamlText = stringToYAML(data);
    else
        % Try to convert to string
        yamlText = stringToYAML(string(data));
    end
end

function yamlText = configDataToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing)
    %CONFIGDATATOYAML Convert ConfigurationData or YAMLData to YAML
    %   Uses the original keys (including special characters like hyphens)
    
    keyList = keys(data);
    yamlLines = cell(length(keyList), 1);
    
    for i = 1:length(keyList)
        key = keyList(i);
        value = data.(key);
        
        indent = repmat(' ', 1, depth * indentSize);
        valueYAML = generateYAML(value, depth + 1, indentSize, flowStyle, precision, false);
        
        % Check if value should be on new line
        % Nested objects (ConfigurationData, struct, Map) are ALWAYS on new line
        % Multi-line values (arrays in block style) are on new line
        % Simple scalars and flow arrays can be on same line
        isNestedObject = isa(value, 'ConfigurationData') || isstruct(value) || isa(value, 'containers.Map');
        
        if isNestedObject || contains(valueYAML, newline)
            yamlLines{i} = sprintf('%s%s:\n%s', indent, key, valueYAML);
        else
            yamlLines{i} = sprintf('%s%s: %s', indent, key, valueYAML);
        end
    end
    
    % Add section spacing for top-level keys (depth == 0)
    if depth == 0 && addSectionSpacing && length(yamlLines) > 1
        % Add blank line between sections
        separator = [newline newline];
    else
        separator = newline;
    end
    
    yamlText = strjoin(yamlLines, separator);
end

function yamlText = structToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing)
    %STRUCTTOYAML Convert structure to YAML

    if isscalar(data)
        % Single structure
        fields = fieldnames(data);
        yamlLines = cell(length(fields), 1);

        for i = 1:length(fields)
            fieldName = fields{i};
            fieldValue = data.(fieldName);

            indent = repmat(' ', 1, depth * indentSize);
            valueYAML = generateYAML(fieldValue, depth + 1, indentSize, flowStyle, precision, false);

            % Check if value should be on new line
            isNestedObject = isa(fieldValue, 'ConfigurationData') || isstruct(fieldValue) || isa(fieldValue, 'containers.Map');
            
            if isNestedObject || contains(valueYAML, newline)
                yamlLines{i} = sprintf('%s%s:\n%s', indent, fieldName, valueYAML);
            else
                yamlLines{i} = sprintf('%s%s: %s', indent, fieldName, valueYAML);
            end
        end

        % Add section spacing for top-level keys (depth == 0)
        if depth == 0 && addSectionSpacing && length(yamlLines) > 1
            separator = [newline newline];
        else
            separator = newline;
        end
        
        yamlText = strjoin(yamlLines, separator);
    else
        % Array of structures
        yamlText = structArrayToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing);
    end
end

function yamlText = structArrayToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing)
    %STRUCTARRAYTOYAML Convert structure array to YAML

    yamlLines = cell(length(data), 1);

    for i = 1:length(data)
        indent = repmat(' ', 1, depth * indentSize);
        itemYAML = generateYAML(data(i), depth + 1, indentSize, flowStyle, precision, false);

        % Remove first level indent from item
        itemLines = splitlines(itemYAML);
        itemLines = cellfun(@(x) x((indentSize+1):end), itemLines, 'UniformOutput', false);
        itemYAML = strjoin(itemLines, newline);

        yamlLines{i} = sprintf('%s- %s', indent, itemYAML);
    end

    yamlText = strjoin(yamlLines, newline);
end

function yamlText = stringArrayToYAML(data, depth, indentSize, flowStyle)
    %STRINGARRAYTOYAML Convert string array to YAML
    %   Note: Single-element arrays are always written as arrays (not scalars)
    %   This preserves the semantic difference between:
    %     branches: main        (scalar string)
    %     branches: [main]      (array with one element)
    
    if flowStyle && (isvector(data) || isscalar(data))
        % Flow style: [item1, item2, item3] or [item]
        items = cell(1, length(data));
        for i = 1:length(data)
            items{i} = stringToYAML(data(i));
        end
        yamlText = sprintf('[%s]', strjoin(items, ', '));
    else
        % Block style
        yamlLines = cell(length(data), 1);
        indent = repmat(' ', 1, depth * indentSize);
        
        for i = 1:length(data)
            itemYAML = stringToYAML(data(i));
            yamlLines{i} = sprintf('%s- %s', indent, itemYAML);
        end
        
        yamlText = strjoin(yamlLines, newline);
    end
end

function yamlText = mapToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing)
    %MAPTOYAML Convert containers.Map to YAML

    keys = data.keys;
    yamlLines = cell(length(keys), 1);

    for i = 1:length(keys)
        key = keys{i};
        value = data(key);

        indent = repmat(' ', 1, depth * indentSize);
        valueYAML = generateYAML(value, depth + 1, indentSize, flowStyle, precision, false);

        % Check if value should be on new line
        isNestedObject = isa(value, 'ConfigurationData') || isstruct(value) || isa(value, 'containers.Map');
        
        if isNestedObject || contains(valueYAML, newline)
            yamlLines{i} = sprintf('%s%s:\n%s', indent, key, valueYAML);
        else
            yamlLines{i} = sprintf('%s%s: %s', indent, key, valueYAML);
        end
    end

    % Add section spacing for top-level keys (depth == 0)
    if depth == 0 && addSectionSpacing && length(yamlLines) > 1
        separator = [newline newline];
    else
        separator = newline;
    end
    
    yamlText = strjoin(yamlLines, separator);
end

function yamlText = cellToYAML(data, depth, indentSize, flowStyle, precision, addSectionSpacing)
    %CELLTOYAML Convert cell array to YAML

    if flowStyle && isvector(data)
        % Flow style: [item1, item2, item3]
        items = cell(1, length(data));
        for i = 1:length(data)
            items{i} = generateYAML(data{i}, 0, indentSize, flowStyle, precision, false);
        end
        yamlText = sprintf('[%s]', strjoin(items, ', '));
    else
        % Block style
        yamlLines = cell(length(data), 1);
        indent = repmat(' ', 1, depth * indentSize);

        for i = 1:length(data)
            itemYAML = generateYAML(data{i}, depth + 1, indentSize, flowStyle, precision, false);

            if contains(itemYAML, newline)
                % Multiline item - put first line on same line as dash
                itemLines = splitlines(itemYAML);
                % First line goes after the dash (strip its indentation)
                firstLine = strtrim(itemLines{1});
                yamlLines{i} = sprintf('%s- %s', indent, firstLine);
                % Remaining lines keep their indentation
                if length(itemLines) > 1
                    for j = 2:length(itemLines)
                        yamlLines{i} = sprintf('%s\n%s', yamlLines{i}, itemLines{j});
                    end
                end
            else
                % Single line item (strip indentation)
                yamlLines{i} = sprintf('%s- %s', indent, strtrim(itemYAML));
            end
        end

        yamlText = strjoin(yamlLines, newline);
    end
end

function yamlText = numericToYAML(data, depth, indentSize, flowStyle, precision)
    %NUMERICTOYAML Convert numeric array to YAML

    if isscalar(data)
        % Single value
        if islogical(data)
            if data
                yamlText = 'true';
            else
                yamlText = 'false';
            end
        elseif isinteger(data)
            yamlText = sprintf('%d', data);
        else
            yamlText = sprintf(['%.', num2str(precision), 'g'], data);
        end
    elseif isvector(data) && flowStyle
        % Flow style vector
        if islogical(data)
            items = arrayfun(@(x) iif(x, 'true', 'false'), data, 'UniformOutput', false);
        elseif isinteger(data)
            items = arrayfun(@(x) sprintf('%d', x), data, 'UniformOutput', false);
        else
            items = arrayfun(@(x) sprintf(['%.', num2str(precision), 'g'], x), data, 'UniformOutput', false);
        end
        yamlText = sprintf('[%s]', strjoin(items, ', '));
    else
        % Block style array
        yamlLines = cell(numel(data), 1);
        indent = repmat(' ', 1, depth * indentSize);

        for i = 1:numel(data)
            if islogical(data(i))
                value = iif(data(i), 'true', 'false');
            elseif isinteger(data(i))
                value = sprintf('%d', data(i));
            else
                value = sprintf(['%.', num2str(precision), 'g'], data(i));
            end
            yamlLines{i} = sprintf('%s- %s', indent, value);
        end

        yamlText = strjoin(yamlLines, newline);
    end
end

function yamlText = stringToYAML(data)
    %STRINGTOYAML Convert string/char to YAML

    % Convert to char for processing (but maintain string type for output)
    if isstring(data)
        strData = char(data);
    else
        strData = data;
    end

    % Check if quoting is needed
    needsQuoting = isempty(strData) || ...
       any(strData(1) == '!#&*{[|>@`') || ...
       contains(strData, ': ') || ...
       contains(strData, ' #') || ...
       ismember(lower(strData), {'true', 'false', 'null', 'yes', 'no', 'on', 'off', '~'}) || ...
       looksLikeNumber(strData) || ...
       looksLikeDate(strData);

    if needsQuoting
        % Use double quotes and escape special characters
        strData = strrep(strData, '\', '\\');
        strData = strrep(strData, '"', '\"');
        strData = strrep(strData, newline, '\n');
        yamlText = sprintf('"%s"', strData);
    else
        yamlText = strData;
    end
end

function tf = looksLikeNumber(str)
    %LOOKSLIKENUMBER Check if string looks like a number (int, float, hex, octal)
    %   Returns true for strings like '3.8', '123', '0x1A', '0o17', '.5', '1e10'

    if isempty(str)
        tf = false;
        return;
    end

    % Check for various numeric patterns
    % Integer (possibly with sign): 123, -456, +789
    % Float: 3.8, -1.5, .5, 1.
    % Scientific notation: 1e10, 1.5E-3
    % Hex: 0x1A, 0X2B
    % Octal: 0o17, 0O77
    % Infinity and NaN
    numericPatterns = {
        '^[+-]?\d+$', ...                          % Integer
        '^[+-]?\d*\.\d*$', ...                     % Float (including .5 and 1.)
        '^[+-]?\d*\.?\d+[eE][+-]?\d+$', ...        % Scientific notation
        '^0[xX][0-9a-fA-F]+$', ...                 % Hexadecimal
        '^0[oO][0-7]+$', ...                       % Octal
        '^[+-]?(\.inf|\.Inf|\.INF)$', ...          % Infinity
        '^\.nan|\.NaN|\.NAN$'                      % NaN
    };

    tf = false;
    for i = 1:length(numericPatterns)
        if ~isempty(regexp(str, numericPatterns{i}, 'once'))
            tf = true;
            return;
        end
    end
end

function tf = looksLikeDate(str)
    %LOOKSLIKEDATE Check if string looks like an ISO date
    %   Returns true for strings like '2020-01-01', '2020-01-01T12:00:00'

    if isempty(str) || length(str) < 10
        tf = false;
        return;
    end

    % ISO date pattern: YYYY-MM-DD with optional time
    datePattern = '^\d{4}-\d{2}-\d{2}';
    tf = ~isempty(regexp(str, datePattern, 'once'));
end

function result = iif(condition, trueVal, falseVal)
    %IIF Inline if function
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end

function mustBeNonzeroLengthText(str)
    %MUSTBENONZEROLENGTHTEXT Validate that text is not empty
    if strlength(str) == 0
        error('Value must be non-empty text');
    end
end
