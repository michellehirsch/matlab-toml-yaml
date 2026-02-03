classdef JSONNull
    %JSONNULL Represents a JSON null value
    %   matlab.io.config.JSONNull explicitly represents JSON null values,
    %   distinguishing them from empty arrays ([]).
    %
    %   When reading JSON files with readjson, null values are returned as
    %   matlab.io.config.JSONNull objects instead of empty arrays. This allows
    %   you to distinguish between:
    %       - JSON null  -> matlab.io.config.JSONNull
    %       - JSON []    -> empty double array ([])
    %
    %   Example:
    %       % Read JSON with null value
    %       data = readjson('file.json');  % {"value": null, "empty": []}
    %
    %       % Check for null using isa()
    %       if isa(data.value, 'matlab.io.config.JSONNull')
    %           disp('Value is null')
    %       end
    %
    %       % isempty returns true for backward compatibility
    %       isempty(data.value)  % true
    %
    %       % Create null values for writing
    %       config = jsondata();
    %       config.nullable = matlab.io.config.JSONNull();
    %       writejson(config, 'output.json');  % writes "nullable": null
    %
    %   See also: readjson, writejson, jsondata

    methods
        function obj = JSONNull()
            %JSONNULL Construct a JSONNull object representing JSON null
        end

        function tf = isempty(~)
            %ISEMPTY Returns true for null values
            %   For backward compatibility, isempty returns true.
            %   Use isa(x, 'matlab.io.config.JSONNull') for precise null detection.
            tf = true;
        end

        function tf = eq(~, other)
            %EQ Check equality - two JSONNulls are equal
            tf = isa(other, 'matlab.io.config.JSONNull');
        end

        function tf = ne(obj, other)
            %NE Check inequality
            tf = ~eq(obj, other);
        end

        function tf = isequal(~, other)
            %ISEQUAL Check equality - two JSONNulls are equal
            tf = isa(other, 'matlab.io.config.JSONNull');
        end

        function tf = isequaln(obj, other)
            %ISEQUALN Check equality treating NaN as equal
            tf = isequal(obj, other);
        end
    end

    methods (Access = protected)
        function displayScalarObject(~)
            %DISPLAYSCALAROBJECT Custom display for scalar JSONNull
            fprintf('  null\n');
        end

        function displayNonScalarObject(obj)
            %DISPLAYNONSCALAROBJECT Custom display for arrays of JSONNull
            sz = size(obj);
            dimStr = sprintf('%dx', sz);
            dimStr = dimStr(1:end-1);  % Remove trailing 'x'
            fprintf('  %s matlab.io.config.JSONNull array\n', dimStr);
        end

        function displayEmptyObject(obj)
            %DISPLAYEMPTYOBJECT Custom display for empty JSONNull arrays
            sz = size(obj);
            dimStr = sprintf('%dx', sz);
            dimStr = dimStr(1:end-1);
            fprintf('  %s empty matlab.io.config.JSONNull array\n', dimStr);
        end
    end
end
