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
    %   This is a value class. Assignment creates an independent copy.
    %
    %   See also: ConfigurationData, readyaml, writeyaml

    methods
        function obj = YAMLData
            %YAMLDATA Construct YAML configuration data object
            obj@ConfigurationData;
            obj.SourceFormat = "yaml";
        end

        function show(obj)
            %SHOW Display contents as YAML
            %   SHOW(OBJ) displays the YAMLData object as YAML text.
            %   This is useful for viewing deeply nested structures at the
            %   command line.
            %
            %   For arrays, displays each element as a YAML list item.
            %
            %   Example:
            %       data.show
            %
            %   See also writeyaml

            tempFile = [tempname '.yaml'];
            try
                if isscalar(obj)
                    % Scalar case - write directly
                    writeyaml(obj, tempFile);
                else
                    % Array case - wrap in container and write as list
                    wrapper = YAMLData;
                    wrapper.item = obj;
                    writeyaml(wrapper, tempFile);
                end
                yamlText = fileread(tempFile);
                fprintf('%s\n', yamlText);
            catch
                % If writeyaml fails, fall back to default display
                disp(obj);
            end

            % Clean up
            if isfile(tempFile)
                delete(tempFile);
            end
        end
    end
end
