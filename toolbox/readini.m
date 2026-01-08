function data = readini(filename, options)
    %READINI Read INI file
    %   data = READINI(filename) reads the INI file and returns an IniData object.
    %
    %   The function parses Windows INI format with sections [SectionName] and
    %   key=value pairs. Comments start with ; or # on a separate line.
    %
    %   Input:
    %       filename - Path to INI file (char or string)
    %
    %   Output:
    %       data - IniData object with configuration data
    %
    %   Example:
    %       config = readini('config.ini');
    %       host = config.database.host;
    %       port = config.database.port;
    %
    %   Supported Windows INI Features:
    %       - Sections: [SectionName]
    %       - Key-value pairs: key=value or key:value
    %       - Comments: ; or # at line start
    %       - Whitespace: trimmed around keys/values
    %       - No multiline values (each line is separate)
    %
    %   See also: writeini, IniData, readyaml, readtoml
    
    arguments
        filename {mustBeTextScalar}
        options.SequenceRule {mustBeMember(options.SequenceRule, {'auto', 'cell'})} = 'auto'
    end
    
    % Read file contents
    if ~isfile(filename)
        error('readini:FileNotFound', 'File "%s" not found.', filename);
    end
    
    fileID = fopen(filename, 'r', 'n', 'UTF-8');
    if fileID == -1
        error('readini:OpenFailed', 'Cannot open file "%s".', filename);
    end
    
    try
        lines = readlines(fileID);
    catch ME
        fclose(fileID);
        rethrow(ME);
    end
    fclose(fileID);
    
    % Parse INI format
    data = INIData();
    currentSection = data;
    currentSectionName = '';
    
    for i = 1:length(lines)
        line = strtrim(lines(i));
        lineChar = char(line);  % Convert to char for operations
        
        % Skip empty lines and comments
        if isempty(line) || startsWith(line, ';') || startsWith(line, '#')
            continue;
        end
        
        % Section header: [SectionName]
        if startsWith(line, '[') && endsWith(line, ']')
            sectionName = extractBetween(line, '[', ']');
            sectionName = strtrim(sectionName);
            
            % Create or get section
            if ~isfield(data, sectionName)
                newSection = INIData();
                % Initialize OriginalKeys for the section
                newSection.OriginalKeys = string.empty(1, 0);
                data.Data(char(sectionName)) = newSection;
                % Track the key
                if ~any(data.OriginalKeys == sectionName)
                    data.OriginalKeys(end+1) = sectionName;
                end
                % Create alias if needed
                validKey = matlab.lang.makeValidName(char(sectionName));
                if ~strcmp(validKey, char(sectionName))
                    data.KeyAliases(validKey) = char(sectionName);
                end
            end
            currentSection = data.Data(char(sectionName));
            currentSectionName = sectionName;
            continue;
        end
        
        % Key-value pair: key=value or key:value
        if contains(line, '=') || contains(line, ':')
            % Find delimiter (using char version for find function)
            eqIdx = find(lineChar == '=', 1);
            colonIdx = find(lineChar == ':', 1);
            
            if isempty(eqIdx) && isempty(colonIdx)
                continue;
            end
            
            if isempty(eqIdx)
                delimIdx = colonIdx;
            elseif isempty(colonIdx)
                delimIdx = eqIdx;
            else
                delimIdx = min(eqIdx, colonIdx);
            end
            
            key = strtrim(extractBefore(line, delimIdx));
            value = strtrim(extractAfter(line, delimIdx));
            
            % Parse value: detect type
            parsedValue = parseValue(value);
            
            % Store in current section (or root if no section)
            if ~isempty(currentSectionName)
                currentSection.Data(char(key)) = parsedValue;
                % Track the key in the section
                if ~any(currentSection.OriginalKeys == key)
                    currentSection.OriginalKeys(end+1) = key;
                end
                % Create alias if needed
                validKey = matlab.lang.makeValidName(char(key));
                if ~strcmp(validKey, char(key))
                    currentSection.KeyAliases(validKey) = char(key);
                end
            else
                data.Data(char(key)) = parsedValue;
                % Track the key in root
                if ~any(data.OriginalKeys == key)
                    data.OriginalKeys(end+1) = key;
                end
                % Create alias if needed
                validKey = matlab.lang.makeValidName(char(key));
                if ~strcmp(validKey, char(key))
                    data.KeyAliases(validKey) = char(key);
                end
            end
        end
    end
end

function value = parseValue(valueStr)
    %PARSEVALUE Parse INI value string to MATLAB type
    
    % Convert to string for consistent handling
    valueStr = string(valueStr);
    valueChar = lower(char(valueStr));
    
    % Try logical (only explicit true/false/yes/no)
    if strcmp(valueChar, 'true') || strcmp(valueChar, 'yes')
        value = true;
        return;
    elseif strcmp(valueChar, 'false') || strcmp(valueChar, 'no')
        value = false;
        return;
    end
    
    % Try comma-separated array BEFORE numeric check
    % (because str2double('1,2,3') returns 123)
    if contains(valueStr, ',')
        parts = split(valueStr, ',');
        parts = strtrim(parts);
        
        % Try parsing as numeric array
        numArray = str2double(parts);
        if ~any(isnan(numArray))
            value = numArray';  % Transpose to row vector
            return;
        end
        
        % Otherwise as string array (row vector)
        value = parts';
        return;
    end
    
    % Try numeric
    numVal = str2double(valueStr);
    if ~isnan(numVal)
        value = numVal;
        return;
    end
    
    % Default to char
    value = char(valueStr);
end

function lines = readlines(fileID)
    %READLINES Read all lines from file handle
    lines = string.empty;
    while ~feof(fileID)
        line = fgetl(fileID);
        if ischar(line)
            lines(end+1) = string(line);
        end
    end
end
