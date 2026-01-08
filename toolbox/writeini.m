function writeini(data, filename, options)
    %WRITEINI Write data to INI file
    %   WRITEINI(data, filename) writes MATLAB data to an INI file.
    %
    %   The function generates Windows INI format with sections and key=value pairs.
    %
    %   Input:
    %       data - IniData object, struct, or containers.Map
    %       filename - Output file path (char or string)
    %       options - Optional name-value pairs:
    %           'SectionSpacing': 'compact' (default) or 'loose'
    %           'Precision': Number of decimal places for floats (default: 6)
    %
    %   Example:
    %       % Create INI data
    %       config = IniData();
    %       config.database.host = 'localhost';
    %       config.database.port = 5432;
    %       config.database.ssl = true;
    %
    %       % Write to file
    %       writeini(config, 'config.ini');
    %
    %   Output Format (Windows INI):
    %       [section1]
    %       key1=value1
    %       key2=value2
    %
    %       [section2]
    %       key3=value3
    %
    %   See also: readini, IniData, writeyaml, writetoml
    
    arguments
        data
        filename {mustBeTextScalar}
        options.SectionSpacing {mustBeMember(options.SectionSpacing, {'compact', 'loose'})} = 'compact'
        options.Precision {mustBeInteger, mustBeNonnegative} = 6
    end
    
    % Convert to INIData if needed
    if isstruct(data)
        iniData = struct2ini(data);
    elseif isa(data, 'containers.Map')
        iniData = map2ini(data);
    elseif isa(data, 'INIData')
        iniData = data;
    else
        error('writeini:UnsupportedType', ...
            'Input must be INIData, struct, or containers.Map.');
    end
    
    % Generate INI content
    iniText = configDataToINI(iniData, options.SectionSpacing, options.Precision);
    
    % Write to file
    fileID = fopen(filename, 'w', 'n', 'UTF-8');
    if fileID == -1
        error('writeini:OpenFailed', 'Cannot open file "%s" for writing.', filename);
    end
    
    try
        fprintf(fileID, '%s', iniText);
    catch ME
        fclose(fileID);
        rethrow(ME);
    end
    fclose(fileID);
end

function iniText = configDataToINI(data, sectionSpacing, precision)
    %CONFIGDATATOINI Convert IniData to INI text format
    
    lines = {};
    
    for i = 1:length(data.OriginalKeys)
        key = data.OriginalKeys(i);
        value = data.Data(char(key));
        
        if isa(value, 'ConfigurationData')
            % Section header
            lines{end+1} = sprintf('[%s]', key);
            
            % Section key-value pairs
            for j = 1:length(value.OriginalKeys)
                subkey = value.OriginalKeys(j);
                subvalue = value.Data(char(subkey));
                
                if isa(subvalue, 'ConfigurationData')
                    % Skip nested ConfigurationData (INI doesn't support deep nesting)
                    continue;
                end
                
                % Format value
                valueStr = formatValue(subvalue, precision);
                lines{end+1} = sprintf('%s=%s', subkey, valueStr);
            end
            
            % Section spacing
            if strcmpi(sectionSpacing, 'loose')
                lines{end+1} = '';  % Blank line between sections
            end
        end
    end
    
    % Remove trailing empty lines
    while ~isempty(lines) && isempty(lines{end})
        lines(end) = [];
    end
    
    iniText = strjoin(lines, newline);
end

function valueStr = formatValue(value, precision)
    %FORMATVALUE Format MATLAB value as INI string
    
    if isstring(value) && isscalar(value)
        valueStr = char(value);
    elseif ischar(value)
        valueStr = value;
    elseif isscalar(value)
        if islogical(value)
            if value
                valueStr = 'true';
            else
                valueStr = 'false';
            end
        elseif isinteger(value) || (value == round(value))
            valueStr = num2str(value, '%d');
        else
            formatStr = sprintf('%%.%dg', precision);
            valueStr = num2str(value, formatStr);
        end
    elseif isnumeric(value) || isstring(value)
        % Array: convert to comma-separated list
        if isstring(value)
            items = arrayfun(@char, value, 'UniformOutput', false);
        else
            items = cell(size(value));
            for k = 1:numel(value)
                if isinteger(value(k)) || value(k) == round(value(k))
                    items{k} = num2str(value(k), '%d');
                else
                    formatStr = sprintf('%%.%dg', precision);
                    items{k} = num2str(value(k), formatStr);
                end
            end
        end
        valueStr = strjoin(items, ',');
    else
        valueStr = '';
    end
end

function iniData = struct2ini(s)
    %STRUCT2INI Convert struct to INIData
    iniData = INIData();
    
    if isscalar(s)
        fields = fieldnames(s);
        for i = 1:length(fields)
            field = fields{i};
            value = s.(field);
            
            if isstruct(value) && isscalar(value)
                % Nested struct -> section
                iniData.(field) = struct2ini(value);
            else
                iniData.(field) = value;
            end
        end
    end
end

function iniData = map2ini(m)
    %MAP2INI Convert containers.Map to INIData
    iniData = INIData();
    
    mapKeys = keys(m);
    for i = 1:length(mapKeys)
        key = mapKeys{i};
        value = m(key);
        
        if isa(value, 'containers.Map')
            % Nested map -> section
            iniData.(key) = map2ini(value);
        else
            iniData.(key) = value;
        end
    end
end
