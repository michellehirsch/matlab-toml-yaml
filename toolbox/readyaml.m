function data = readyaml(filename, options)
%READYAML Read data from YAML file
%   DATA = READYAML(FILENAME) reads the YAML file specified by FILENAME and
%   returns the data as a YAMLData object with dot notation access and support
%   for special characters in field names.
%
%   DATA = READYAML(FILENAME, 'SequenceRule', RULE) controls how YAML
%   flow-style sequences [item1, item2, ...] are converted to MATLAB:
%
%   'auto' (default) - Automatically use specialized arrays when possible:
%                      [1, 2, 3]        → numeric array [1, 2, 3]
%                      [a, b, c]        → string array ["a", "b", "c"]
%                      [1, "two", true] → cell array {1, "two", true}
%
%   'cell'           - Always return cell arrays for consistency:
%                      [1, 2, 3]        → cell array {1, 2, 3}
%                      [a, b, c]        → cell array {"a", "b", "c"}
%
%   The returned YAMLData object can be converted to a standard struct using:
%       s = struct(data);
%
%   Examples:
%       % Read a YAML configuration file
%       config = readyaml('config.yaml');
%       config.ports  % [8080, 8443] - numeric array
%
%       % Force cell arrays for consistency
%       config = readyaml('config.yaml', 'SequenceRule', 'cell');
%       config.ports  % {8080, 8443} - cell array
%
%   See also WRITEYAML, YAMLData, struct

%   Copyright 2025 The MathWorks, Inc.

    arguments
        filename {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFile}
        options.SequenceRule {mustBeMember(options.SequenceRule, ["auto", "cell"])} = "auto"
    end

    % Read file contents
    try
        fileContent = fileread(filename);
    catch ME
        error('yamlToolbox:readyaml:FileReadError', ...
            'Unable to read file "%s": %s', filename, ME.message);
    end

    % Parse YAML content
    try
        data = parseYAML(fileContent, options.SequenceRule);
    catch ME
        error('yamlToolbox:readyaml:ParseError', ...
            'Error parsing YAML file "%s": %s', filename, ME.message);
    end
end

function data = parseYAML(yamlText, arrayFormat)
    %PARSEYAML Parse YAML text into MATLAB data structures

    % Remove BOM if present
    if ~isempty(yamlText) && uint8(yamlText(1)) == 239
        if length(yamlText) >= 3 && all(uint8(yamlText(1:3)) == [239 187 191])
            yamlText = yamlText(4:end);
        end
    end

    % Split into lines
    lines = splitlines(yamlText);

    % Remove empty lines and comments
    lines = lines(~cellfun(@isempty, strtrim(lines)));
    lines = removeComments(lines);

    % Parse the YAML structure
    [data, ~] = parseBlock(lines, 1, 0, arrayFormat);
end

function lines = removeComments(lines)
    %REMOVECOMMENTS Remove comments from YAML lines
    for i = 1:length(lines)
        line = lines{i};
        % Find comment symbol not in quotes
        inQuotes = false;
        quoteChar = '';
        for j = 1:length(line)
            if ~inQuotes && (line(j) == '"' || line(j) == '''')
                inQuotes = true;
                quoteChar = line(j);
            elseif inQuotes && line(j) == quoteChar
                inQuotes = false;
            elseif ~inQuotes && line(j) == '#'
                lines{i} = strtrim(line(1:j-1));
                break;
            end
        end
    end
end

function [data, nextLine] = parseBlock(lines, startLine, baseIndent, arrayFormat)
    %PARSEBLOCK Parse a block of YAML lines

    data = struct();
    fields = {};
    values = {};
    nextLine = startLine;

    while nextLine <= length(lines)
        line = lines{nextLine};

        % Get indentation
        indent = getIndentation(line);

        % If indentation is less than base, we're done with this block
        if indent < baseIndent && ~isempty(strtrim(line))
            break;
        end

        trimmedLine = strtrim(line);

        % Skip empty lines
        if isempty(trimmedLine)
            nextLine = nextLine + 1;
            continue;
        end

        % Check if this is a list item
        if startsWith(trimmedLine, '-')
            % This is a sequence (array)
            itemContent = strtrim(trimmedLine(2:end));
            
            % Check if there's content on the same line as the dash
            if ~isempty(itemContent)
                % Check if it's a mapping item: "- key: value"
                colonIdx = find(itemContent == ':', 1);
                if ~isempty(colonIdx) && colonIdx > 1
                    % It's a mapping - parse this item and any continuation
                    [itemData, nextLine] = parseListItemMapping(lines, nextLine, indent, arrayFormat);
                    values{end+1} = itemData; %#ok<AGROW>
                else
                    % It's a simple scalar value
                    value = parseValue(itemContent, arrayFormat);
                    values{end+1} = value; %#ok<AGROW>
                    nextLine = nextLine + 1;
                end
            else
                % Empty dash - content on next lines
                nextLine = nextLine + 1;
                if nextLine <= length(lines)
                    nextIndent = getIndentation(lines{nextLine});
                    if nextIndent > indent
                        [itemValue, nextLine] = parseBlock(lines, nextLine, nextIndent, arrayFormat);
                        values{end+1} = itemValue; %#ok<AGROW>
                    end
                end
            end
        else
            % This is a mapping (key: value)
            colonIdx = find(trimmedLine == ':', 1);
            if ~isempty(colonIdx)
                key = strtrim(trimmedLine(1:colonIdx-1));
                valueStr = strtrim(trimmedLine(colonIdx+1:end));

                if isempty(valueStr)
                    % Value is on next line(s)
                    nextLine = nextLine + 1;
                    if nextLine <= length(lines)
                        nextIndent = getIndentation(lines{nextLine});
                        if nextIndent > indent
                            [value, nextLine] = parseBlock(lines, nextLine, nextIndent, arrayFormat);
                            fields{end+1} = key; %#ok<AGROW>
                            values{end+1} = value; %#ok<AGROW>
                        else
                            fields{end+1} = key; %#ok<AGROW>
                            values{end+1} = []; %#ok<AGROW>
                        end
                    else
                        fields{end+1} = key; %#ok<AGROW>
                        values{end+1} = []; %#ok<AGROW>
                    end
                else
                    % Value is on same line
                    value = parseValue(valueStr, arrayFormat);
                    fields{end+1} = key; %#ok<AGROW>
                    values{end+1} = value; %#ok<AGROW>
                    nextLine = nextLine + 1;
                end
            else
                % Not a key-value pair, skip
                nextLine = nextLine + 1;
            end
        end
    end

    % Convert to appropriate return type
    if isempty(fields)
        if ~isempty(values)
            % This is a sequence
            % If all values are YAMLData or ConfigurationData, return as object array
            if all(cellfun(@(x) isa(x, 'ConfigurationData'), values))
                % Convert cell array to object array
                data = [values{:}];
            else
                % Apply arrayFormat consolidation (same logic as flow-style arrays)
                data = consolidateArray(values, arrayFormat);
            end
        else
            data = YAMLData();
        end
    else
        % This is a mapping - return as YAMLData
        data = YAMLData();
        for i = 1:length(fields)
            data.(fields{i}) = values{i};
        end
    end
end

function [itemData, nextLine] = parseListItemMapping(lines, startLine, dashIndent, arrayFormat)
    %PARSELISTITEMMAPPING Parse a list item that is a mapping
    %   Handles:
    %     - name: Checkout
    %       uses: actions/checkout@v4
    %       with:
    %         ref: main
    
    line = lines{startLine};
    trimmedLine = strtrim(line);
    
    % Get the first key-value from the dash line
    itemContent = strtrim(trimmedLine(2:end)); % Remove the '-'
    colonIdx = find(itemContent == ':', 1);
    
    firstKey = strtrim(itemContent(1:colonIdx-1));
    firstValueStr = strtrim(itemContent(colonIdx+1:end));
    
    % Start building the mapping
    itemFields = {firstKey};
    itemValues = {parseValue(firstValueStr, arrayFormat)};
    
    nextLine = startLine + 1;
    
    % Continue reading keys at the proper indentation level
    % Keys that belong to this list item will be indented MORE than the dash
    % but won't start with another dash
    while nextLine <= length(lines)
        line = lines{nextLine};
        lineIndent = getIndentation(line);
        trimmedLine = strtrim(line);
        
        % Stop if we've dedented to or past the dash level
        if lineIndent <= dashIndent && ~isempty(trimmedLine)
            break;
        end
        
        % Skip empty lines
        if isempty(trimmedLine)
            nextLine = nextLine + 1;
            continue;
        end
        
        % Stop if we hit another list item
        if startsWith(trimmedLine, '-')
            break;
        end
        
        % This should be another key for this mapping
        colonIdx = find(trimmedLine == ':', 1);
        if ~isempty(colonIdx)
            key = strtrim(trimmedLine(1:colonIdx-1));
            valueStr = strtrim(trimmedLine(colonIdx+1:end));
            
            if isempty(valueStr)
                % Value on next line(s) - nested structure
                nextLine = nextLine + 1;
                if nextLine <= length(lines)
                    nextIndent = getIndentation(lines{nextLine});
                    if nextIndent > lineIndent
                        [value, nextLine] = parseBlock(lines, nextLine, nextIndent, arrayFormat);
                        itemFields{end+1} = key; %#ok<AGROW>
                        itemValues{end+1} = value; %#ok<AGROW>
                    else
                        itemFields{end+1} = key; %#ok<AGROW>
                        itemValues{end+1} = []; %#ok<AGROW>
                    end
                else
                    itemFields{end+1} = key; %#ok<AGROW>
                    itemValues{end+1} = []; %#ok<AGROW>
                end
            else
                % Value on same line
                value = parseValue(valueStr, arrayFormat);
                itemFields{end+1} = key; %#ok<AGROW>
                itemValues{end+1} = value; %#ok<AGROW>
                nextLine = nextLine + 1;
            end
        else
            % Not a key-value pair, skip
            nextLine = nextLine + 1;
        end
    end
    
    % Build the mapping for this list item
    itemData = YAMLData();
    for i = 1:length(itemFields)
        itemData.(itemFields{i}) = itemValues{i};
    end
end

function indent = getIndentation(line)
    %GETINDENTATION Get number of leading spaces
    indent = 0;
    for i = 1:length(line)
        if line(i) == ' '
            indent = indent + 1;
        elseif line(i) == char(9) % tab
            indent = indent + 4; % Count tab as 4 spaces
        else
            break;
        end
    end
end

function value = consolidateArray(parsedItems, arrayFormat)
    %CONSOLIDATEARRAY Convert cell array to specialized arrays based on arrayFormat
    %   Shared logic for both flow-style and block-style sequences

    % Ensure parsedItems is a column cell array for consistent output
    if size(parsedItems, 1) == 1 && size(parsedItems, 2) > 1
        parsedItems = parsedItems(:);  % Convert row to column
    end

    if arrayFormat == "auto"
        % Check if all items are same type
        allText = all(cellfun(@(x) ischar(x) || isstring(x), parsedItems));
        allNumeric = all(cellfun(@isnumeric, parsedItems));
        allLogical = all(cellfun(@islogical, parsedItems));

        if allText
            % Convert to string array (column)
            value = string(parsedItems);
        elseif allNumeric
            % Convert to numeric array (column)
            value = cell2mat(parsedItems);
        elseif allLogical
            % Convert to logical array (column)
            value = cell2mat(parsedItems);
        else
            % Mixed types - keep as cell array
            value = parsedItems;
        end
    else  % arrayFormat == "cell"
        % Always return cell array
        value = parsedItems;
    end
end

function value = parseValue(valueStr, arrayFormat)
    %PARSEVALUE Parse a YAML value string

    valueStr = strtrim(valueStr);

    % Check for flow-style array: [item1, item2, item3]
    if startsWith(valueStr, '[') && endsWith(valueStr, ']')
        % Parse flow array
        arrayContent = valueStr(2:end-1); % Remove [ ]
        if isempty(strtrim(arrayContent))
            value = string.empty;
            return;
        end

        % Split by comma (simple parser - doesn't handle nested arrays)
        items = split(arrayContent, ',');
        parsedItems = cell(size(items));
        for i = 1:length(items)
            parsedItems{i} = parseValue(strtrim(items{i}), arrayFormat);
        end

        % Convert to specialized arrays based on arrayFormat
        value = consolidateArray(parsedItems, arrayFormat);
        return;
    end

    % Check for quoted string
    if (startsWith(valueStr, '"') && endsWith(valueStr, '"')) || ...
       (startsWith(valueStr, '''') && endsWith(valueStr, ''''))
        value = string(valueStr(2:end-1));
        return;
    end

    % Check for boolean
    switch lower(valueStr)
        case {'true', 'yes', 'on'}
            value = true;
            return;
        case {'false', 'no', 'off'}
            value = false;
            return;
        case {'null', '~', ''}
            value = [];
            return;
    end

    % Try to parse as number
    numValue = str2double(valueStr);
    if ~isnan(numValue)
        value = numValue;
        return;
    end

    % Default to string
    value = string(valueStr);
end

function mustBeNonzeroLengthText(str)
    %MUSTBENONZEROLENGTHTEXT Validate that text is not empty
    if strlength(str) == 0
        error('Value must be non-empty text');
    end
end
