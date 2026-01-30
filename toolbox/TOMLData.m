classdef TOMLData < ConfigurationData
    %TOMLDATA TOML configuration data with dot notation access
    %   TOMLData extends ConfigurationData to provide TOML-specific functionality
    %   including preservation of key order and support for special characters
    %   in field names (like hyphens).
    %
    %   This is a value class. Assignment creates an independent copy.
    %
    %   Example:
    %       data = readtoml('pyproject.toml');
    %       name = data.project.name;
    %       deps = data.("build-system").requires;
    %       data.show;  % Display as TOML
    %
    %   See also READTOML, WRITETOML, ConfigurationData

    methods
        function obj = TOMLData(inputData)
            %TOMLDATA Construct TOMLData object
            %   obj = TOMLData() creates an empty TOMLData object
            %   obj = TOMLData(s) converts struct s to TOMLData
            %   obj = TOMLData(d) converts dictionary d to TOMLData
            %   obj = TOMLData(m) converts containers.Map m to TOMLData
            %
            %   Example:
            %       s = struct('project', struct('name', 'myapp'));
            %       config = TOMLData(s);
            %       writetoml(config, 'pyproject.toml');

            if nargin < 1
                inputData = [];
            end
            obj@ConfigurationData(inputData);
            obj.xInternal__.SourceFormat = "toml";
        end

        function show(obj)
            %SHOW Display the data in TOML format
            %   data.show writes the TOMLData to a temporary file and
            %   displays the TOML content in the command window.
            %
            %   For arrays, displays each element as an array of tables
            %   using [[item]] syntax.
            %
            %   This is useful for viewing the TOML representation of the data.

            if isscalar(obj)
                % Scalar case - write directly
                try
                    tempFile = tempname;
                    writetoml(obj, tempFile);
                    content = fileread(tempFile);
                    fprintf('%s\n', content);
                    delete(tempFile);
                catch
                    disp(obj);
                end
            else
                % Array case - wrap in container and write as array of tables
                try
                    wrapper = TOMLData;
                    wrapper.item = obj;
                    tempFile = tempname;
                    writetoml(wrapper, tempFile, TableArrayStyle="expanded");
                    content = fileread(tempFile);
                    fprintf('%s\n', content);
                    delete(tempFile);
                catch
                    disp(obj);
                end
            end
        end
    end

    methods (Access = protected)
        function value = validateAndConvertValue(obj, value, key)
            %VALIDATEANDCONVERTVALUE TOML-specific type validation
            %   TOML natively supports datetime, so keep it as-is.

            % TOML supports datetime natively - don't convert
            if isa(value, 'datetime')
                return;  % Keep as datetime
            end

            % For all other types, use base class validation
            value = validateAndConvertValue@ConfigurationData(obj, value, key);
        end
    end
end
