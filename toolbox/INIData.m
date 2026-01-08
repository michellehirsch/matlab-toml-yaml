classdef INIData < ConfigurationData
    %INIDATA INI configuration data container
    %   INIData represents structured configuration data from INI files
    %   with dot notation access and support for special characters in field names.
    %   Follows Windows INI dialect with sections and key=value pairs.
    %
    %   This class extends ConfigurationData and provides INI-specific behavior.
    %
    %   Example:
    %       % Create INI data
    %       config = INIData();
    %       config.database.host = 'localhost';
    %       config.database.port = '5432';
    %
    %       % Write to file
    %       writeini(config, 'config.ini');
    %
    %       % Read from file
    %       config = readini('config.ini');
    
    methods
        function obj = INIData()
            %INIDATA Create an empty INI data object
            obj = obj@ConfigurationData();
            obj.SourceFormat = "ini";
        end
        
        function newObj = copy(obj)
            %COPY Create a deep copy of the INIData object
            newObj = copy@ConfigurationData(obj);
            newObj.SourceFormat = obj.SourceFormat;
        end
        
        function yamlText = show(obj)
            %SHOW Display INI content as formatted text
            %   Displays the INI structure without writing to file.
            
            iniText = generateINI(obj);
            if nargout == 0
                disp(iniText);
            else
                yamlText = iniText;
            end
        end
    end
    
    methods (Access = protected)
        function nested = wrapNested(obj, mapData)
            %WRAPNESTED Wrap containers.Map as INIData (override for INI type)
            nested = INIData();
            nested.Data = mapData;
            nested.OriginalKeys = string(keys(mapData));
            
            % Create aliases for all keys
            for i = 1:length(nested.OriginalKeys)
                key = nested.OriginalKeys(i);
                validKey = matlab.lang.makeValidName(char(key));
                if ~strcmp(validKey, key)
                    nested.KeyAliases(validKey) = char(key);
                end
            end
        end
    end
end

function iniText = generateINI(obj)
    %GENERATEINI Generate INI text from IniData object
    lines = {};
    
    for i = 1:length(obj.OriginalKeys)
        key = obj.OriginalKeys(i);
        value = obj.Data(char(key));
        
        if isa(value, 'ConfigurationData')
            % Section header
            lines{end+1} = sprintf('[%s]', key);
            
            % Section contents
            for j = 1:length(value.OriginalKeys)
                subkey = value.OriginalKeys(j);
                subvalue = value.Data(char(subkey));
                
                if isa(subvalue, 'ConfigurationData')
                    % Skip nested ConfigurationData (INI doesn't support deep nesting)
                    continue;
                end
                
                % Convert value to string
                valueStr = valueToString(subvalue);
                lines{end+1} = sprintf('%s=%s', subkey, valueStr);
            end
            lines{end+1} = '';  % Blank line between sections
        end
    end
    
    iniText = strjoin(lines, newline);
end

function valueStr = valueToString(value)
    %VALUETOSTRING Convert MATLAB value to INI string representation
    if isstring(value) && isscalar(value)
        valueStr = char(value);
    elseif ischar(value)
        valueStr = value;
    elseif isscalar(value)
        if islogical(value)
            valueStr = iif(value, 'true', 'false');
        else
            valueStr = num2str(value);
        end
    elseif isnumeric(value) || isstring(value)
        % Array: convert to comma-separated list
        if isstring(value)
            items = arrayfun(@char, value, 'UniformOutput', false);
        else
            items = arrayfun(@num2str, value, 'UniformOutput', false);
        end
        valueStr = strjoin(items, ',');
    else
        valueStr = '';
    end
end
