classdef Null
    %NULL Represents a JSON null value
    %   matlab.io.config.Null explicitly represents JSON null values,
    %   distinguishing them from empty arrays ([]).
    %
    %   When reading JSON files with readjson, null values are returned as
    %   matlab.io.config.Null objects instead of empty arrays. This allows
    %   you to distinguish between:
    %       - JSON null  -> matlab.io.config.Null
    %       - JSON []    -> empty double array ([])
    %
    %   Example:
    %       % Read JSON with null value
    %       data = readjson('file.json');  % {"value": null, "empty": []}
    %
    %       % Check for null using isa()
    %       if isa(data.value, 'matlab.io.config.Null')
    %           disp('Value is null')
    %       end
    %
    %       % isempty returns true for backward compatibility
    %       isempty(data.value)  % true
    %
    %       % Create null values for writing
    %       config = jsondata();
    %       config.nullable = matlab.io.config.Null();
    %       writejson(config, 'output.json');  % writes "nullable": null
    %
    %   See also: readjson, writejson, jsondata

    methods
        function obj = Null()
            %NULL Construct a Null object representing JSON null
        end

        function tf = isempty(~)
            %ISEMPTY Returns true for null values
            %   For backward compatibility, isempty returns true.
            %   Use isa(x, 'matlab.io.config.Null') for precise null detection.
            tf = true;
        end

        function tf = eq(~, other)
            %EQ Check equality - two Nulls are equal
            tf = isa(other, 'matlab.io.config.Null');
        end

        function tf = ne(obj, other)
            %NE Check inequality
            tf = ~eq(obj, other);
        end

        function tf = isequal(~, other)
            %ISEQUAL Check equality - two Nulls are equal
            tf = isa(other, 'matlab.io.config.Null');
        end

        function tf = isequaln(obj, other)
            %ISEQUALN Check equality treating NaN as equal
            tf = isequal(obj, other);
        end
    end

    methods (Access = protected)
        function displayScalarObject(~)
            %DISPLAYSCALAROBJECT Custom display for scalar Null
            fprintf('  null\n');
        end

        function displayNonScalarObject(obj)
            %DISPLAYNONSCALAROBJECT Custom display for arrays of Null
            sz = size(obj);
            dimStr = sprintf('%dx', sz);
            dimStr = dimStr(1:end-1);  % Remove trailing 'x'
            fprintf('  %s matlab.io.config.Null array\n', dimStr);
        end

        function displayEmptyObject(obj)
            %DISPLAYEMPTYOBJECT Custom display for empty Null arrays
            sz = size(obj);
            dimStr = sprintf('%dx', sz);
            dimStr = dimStr(1:end-1);
            fprintf('  %s empty matlab.io.config.Null array\n', dimStr);
        end
    end
end
