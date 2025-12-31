classdef TOMLData < ConfigurationData
    %TOMLDATA TOML configuration data with dot notation access
    %   TOMLData extends ConfigurationData to provide TOML-specific functionality
    %   including preservation of key order and support for special characters
    %   in field names (like hyphens).
    %
    %   Example:
    %       data = readtoml('pyproject.toml');
    %       name = data.project.name;
    %       deps = data.("build-system").requires;
    %       data.show();  % Display as TOML
    %
    %   See also READTOML, WRITETOML, ConfigurationData
    
    %   Copyright 2025 The MathWorks, Inc.
    
    methods
        function obj = TOMLData()
            %TOMLDATA Construct TOMLData object
            obj@ConfigurationData();
            obj.SourceFormat = "toml";
        end
        
        function show(obj)
            %SHOW Display the data in TOML format
            %   data.show() writes the TOMLData to a temporary file and
            %   displays the TOML content in the command window.
            %
            %   This is useful for viewing the TOML representation of the data.
            
            try
                % Write to temporary file
                tempFile = tempname;
                writetoml(obj, tempFile);
                
                % Read and display
                content = fileread(tempFile);
                fprintf('%s\n', content);
                
                % Clean up
                delete(tempFile);
            catch
                % Fallback to regular display if writetoml fails
                disp(obj);
            end
        end
    end
end
