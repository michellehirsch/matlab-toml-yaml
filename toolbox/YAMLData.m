classdef YAMLData < ConfigurationData
    %YAMLDATA YAML-specific configuration data
    %   Subclass of ConfigurationData with YAML-specific features.
    %   
    %   YAMLData provides the same interface as ConfigurationData but is
    %   specifically designed for YAML files. Future versions may include
    %   YAML-specific features such as:
    %   - Preserving comments
    %   - Handling YAML anchors and aliases
    %   - YAML-specific type conversions
    %
    %   See also: ConfigurationData, readyaml, writeyaml
    
    methods
        function obj = YAMLData
            %YAMLDATA Construct YAML configuration data object
            obj@ConfigurationData;
        end
        
        function show(obj)
            %SHOW Display contents as YAML
            %   SHOW(OBJ) displays the YAMLData object as YAML text.
            %   This is useful for viewing deeply nested structures at the
            %   command line.
            %
            %   Example:
            %       data.show
            %
            %   See also writeyaml
            
            % Write to temporary file and read back
            tempFile = [tempname '.yaml'];
            try
                writeyaml(obj, tempFile);
                yamlText = fileread(tempFile);
                fprintf('%s\n', yamlText);
            catch ME
                % If writeyaml fails, fall back to default display
                disp(obj);
            end
            
            % Clean up
            if isfile(tempFile)
                delete(tempFile);
            end
        end
    end
    
    methods (Access = protected)
        function newObj = wrapNested(obj, mapData)
            %WRAPNESTED Wrap nested Map as YAMLData (override)
            newObj = YAMLData;
            newObj.Data = mapData;
            newObj.OriginalKeys = string(keys(mapData));
            
            % Create aliases for all keys
            for i = 1:length(newObj.OriginalKeys)
                key = newObj.OriginalKeys(i);
                validKey = matlab.lang.makeValidName(char(key));
                if ~strcmp(validKey, key)
                    newObj.KeyAliases(validKey) = char(key);
                end
            end
        end
    end
end
