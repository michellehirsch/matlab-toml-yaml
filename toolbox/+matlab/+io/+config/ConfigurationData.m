classdef (Abstract) ConfigurationData < matlab.mixin.indexing.RedefinesDot & ...
                            matlab.mixin.indexing.OverridesPublicDotMethodCall & ...
                            matlab.mixin.CustomDisplay
    %CONFIGURATIONDATA Abstract base class for structured configuration data
    %   Use YAMLData, TOMLData, or INIData instead of this class directly.
    %   Provides dot notation access and support for special characters in keys.
    %
    %   This is a value class. Assignment creates an independent copy:
    %       newData = data;  % newData is independent of data
    %
    %   The copy() method is provided for compatibility but is equivalent
    %   to assignment for value classes.
    %
    %   NOTE: This class uses OverridesPublicDotMethodCall to avoid reserved
    %   name collisions. Users can have keys named "keys", "isfield", etc.
    %   To call methods, use function syntax: keys(obj), isfield(obj, key)

    properties (Access = public, Hidden = true)
        % Consolidated internal state in a single property to minimize
        % reserved key names while preserving tab completion.
        % See Claude/TAB_COMPLETION_DESIGN.md for rationale.
        xInternal__ struct = struct(...
            'Data', configureDictionary("string", "cell"), ...
            'KeyAliases', configureDictionary("string", "string"), ...
            'OriginalKeys', string.empty, ...
            'SourceFormat', "unknown")
    end

    methods
        function obj = ConfigurationData()
            %CONFIGURATIONDATA Constructor for subclasses
            %   This is an abstract class. Use YAMLData, TOMLData, or INIData.
            %
            %   Subclass constructors create empty objects. To create from
            %   existing data, use the informal wrapper functions:
            %       config = tomldata(myStruct);   % from struct
            %       config = yamldata(myDict);     % from dictionary
            %
            %   See also TOMLDATA, YAMLDATA, INIDATA

            obj.xInternal__.Data = configureDictionary("string", "cell");
            obj.xInternal__.KeyAliases = configureDictionary("string", "string");
            obj.xInternal__.OriginalKeys = string.empty;
        end

        function newObj = copy(obj)
            %COPY Create an independent copy of the ConfigurationData object
            %   With value semantics, assignment already creates a copy.
            %   This method is retained for backwards compatibility.
            newObj = obj;
        end

        function k = keys(obj)
            k = obj.xInternal__.OriginalKeys;
        end

        function tf = isfield(obj, key)
            %ISFIELD Check if key exists (delegates to iskey)
            tf = iskey(obj, key);
        end

        function s = struct(obj)
            s = struct;
            for i = 1:length(obj.xInternal__.OriginalKeys)
                key = obj.xInternal__.OriginalKeys(i);
                value = obj.getData(key);

                if isa(value, 'matlab.io.config.ConfigurationData')
                    if isscalar(value)
                        value = struct(value);
                    else
                        % Handle array of ConfigurationData objects
                        structCell = cell(1, numel(value));
                        for iVal = 1:numel(value)
                            structCell{iVal} = struct(value(iVal));
                        end
                        value = [structCell{:}];
                    end
                elseif isa(value, 'dictionary')
                    % Recursively convert dictionary to struct
                    value = obj.dictToStruct(value);
                end

                fieldName = matlab.lang.makeValidName(key);
                s.(fieldName) = value;
            end
        end

        function m = map(obj)
            %MAP Convert to containers.Map (for compatibility)
            m = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for i = 1:length(obj.xInternal__.OriginalKeys)
                key = obj.xInternal__.OriginalKeys(i);
                value = obj.getData(key);

                if isa(value, 'matlab.io.config.ConfigurationData')
                    value = map(value);
                end

                m(char(key)) = value;
            end
        end

        function d = dictionary(obj)
            %DICTIONARY Convert to MATLAB dictionary
            %   d = dictionary(obj) converts the ConfigurationData to a
            %   dictionary with string keys and cell values.
            %
            %   Nested ConfigurationData objects are recursively converted
            %   to nested dictionaries.
            %
            %   Example:
            %       config = readyaml('config.yaml');
            %       d = dictionary(config);
            %       value = d{"keyName"};
            %
            %   See also STRUCT, MAP

            d = configureDictionary("string", "cell");
            for i = 1:length(obj.xInternal__.OriginalKeys)
                key = obj.xInternal__.OriginalKeys(i);
                value = obj.getData(key);

                if isa(value, 'matlab.io.config.ConfigurationData')
                    if isscalar(value)
                        value = dictionary(value);  % Recursive
                    else
                        % Array of ConfigurationData -> cell array of dictionaries
                        tmpCell = cell(1, numel(value));
                        for iVal = 1:numel(value)
                            tmpCell{iVal} = dictionary(value(iVal));
                        end
                        value = tmpCell;
                    end
                end

                d(key) = {value};
            end
        end

        function p = properties(obj)
            %PROPERTIES Return list of dynamic properties (keys)
            %   Returns cell array of char for MATLAB IDE tab completion.
            p = cellstr(obj.xInternal__.OriginalKeys);
        end

        function names = fieldnames(obj)
            %FIELDNAMES Get field names (alias for keys)
            names = keys(obj);
        end

        function tf = iskey(obj, key)
            %ISKEY Check if key exists in each element of the array
            %   tf = iskey(obj, key) returns a logical array the same size as obj.
            %   tf(i) is true if obj(i) contains the key.
            %
            %   For scalar objects, returns a scalar logical.
            %   For array objects, returns a logical array allowing filtering:
            %       hasEmail = iskey(data.users, "email");
            %       emailUsers = data.users(hasEmail);
            %
            %   To check if ALL elements have a key: all(iskey(obj, key))
            %
            %   See also ISFIELD, KEYS

            tf = false(size(obj));
            for i = 1:numel(obj)
                resolvedKey = obj(i).resolveKey(key);
                tf(i) = ~isempty(resolvedKey);
            end
        end

        function obj = rmfield(obj, key)
            %RMFIELD Remove a field
            resolvedKey = obj.resolveKey(key);
            if isempty(resolvedKey)
                error('ConfigurationData:InvalidKey', ...
                    'Key "%s" does not exist.', key);
            end

            % Remove from data (dictionary requires capturing return)
            obj.xInternal__.Data = remove(obj.xInternal__.Data, resolvedKey);

            % Remove from order tracking
            obj.xInternal__.OriginalKeys(obj.xInternal__.OriginalKeys == resolvedKey) = [];

            % Remove alias if exists
            validKey = matlab.lang.makeValidName(key);
            if isKey(obj.xInternal__.KeyAliases, validKey)
                obj.xInternal__.KeyAliases = remove(obj.xInternal__.KeyAliases, validKey);
            end
        end

        function obj = remove(obj, key)
            %REMOVE Remove a key (alias for rmfield)
            obj = obj.rmfield(key);
        end

    end

    methods (Access = protected)
        % CustomDisplay implementation
        function header = getHeader(obj)
            %GETHEADER Customize header to use "keys" instead of "properties"
            if isscalar(obj)
                className = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                nKeys = length(obj.xInternal__.OriginalKeys);
                if nKeys == 0
                    header = sprintf('  %s with no keys\n', className);
                elseif nKeys == 1
                    header = sprintf('  %s with keys:\n', className);
                else
                    header = sprintf('  %s with keys:\n', className);
                end
            else
                % Non-scalar handled by displayNonScalarObject
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            end
        end

        function displayScalarObject(obj)
            header = getHeader(obj);
            disp(header);

            if length(obj.xInternal__.OriginalKeys) == 0
                return;
            end

            % Check if there's nested hierarchy
            hasHierarchy = false;
            for i = 1:length(obj.xInternal__.OriginalKeys)
                value = obj.getData(obj.xInternal__.OriginalKeys(i));
                if isa(value, 'matlab.io.config.ConfigurationData') || isa(value, 'dictionary')
                    hasHierarchy = true;
                    break;
                end
            end

            % Display each field
            for i = 1:length(obj.xInternal__.OriginalKeys)
                key = obj.xInternal__.OriginalKeys(i);
                value = obj.getData(key);

                % Format the value for display
                valueStr = obj.formatValue(value);

                fprintf('    %s: %s\n', key, valueStr);
            end

            % Add footer with show link if there's hierarchy
            if hasHierarchy
                fprintf('\n    <a href="matlab:show(%s)">Show all values</a>\n', inputname(1));
            end

            fprintf('\n');
        end

        function displayNonScalarObject(obj)
            % Display for object arrays
            dims = size(obj);
            dimStr = sprintf('%dx', dims);
            dimStr = dimStr(1:end-1); % Remove trailing 'x'

            % Collect all keys from array elements
            allKeys = string.empty(0,1); % String array to hold all unique keys
            keySets = cell(numel(obj), 1);

            for i = 1:numel(obj)
                keySets{i} = keys(obj(i)); % Use keys() method
                % Ensure column vector for concatenation
                allKeys = [allKeys; reshape(keySets{i}, [], 1)];
            end

            % Get unique keys while preserving order from first occurrence
            [uniqueKeys, ~] = unique(allKeys, 'stable');

            % Check if all elements have identical keys
            isHomogeneous = true;
            if numel(obj) > 1
                firstKeySet = keySets{1};
                for i = 2:numel(obj)
                    if ~isequal(sort(firstKeySet), sort(keySets{i}))
                        isHomogeneous = false;
                        break;
                    end
                end
            end

            % Display header
            shortName = matlab.io.config.ConfigurationData.shortClassName(class(obj));
            fprintf('  %s <a href="matlab:helpPopup %s">%s</a> array with keys:\n\n', ...
                dimStr, class(obj), shortName);

            % Display keys
            for i = 1:length(uniqueKeys)
                fprintf('    %s\n', uniqueKeys(i));
            end

            % Add heterogeneous note if needed
            if ~isHomogeneous && numel(obj) > 1
                fprintf('\n    (keys vary by element)\n');
            end

            % Add show link for arrays (they always have potential hierarchy)
            fprintf('\n    <a href="matlab:show(%s)">Show all values</a>\n\n', inputname(1));
        end

        function str = formatValue(~, value)
            % Format a value for display (similar to struct)
            if isa(value, 'matlab.io.config.ConfigurationData')
                if numel(value) > 1
                    % Array of ConfigurationData
                    sizeStr = sprintf('%dx', size(value));
                    sizeStr = sizeStr(1:end-1);
                    shortName = matlab.io.config.ConfigurationData.shortClassName(class(value));
                    str = sprintf('[%s %s]', sizeStr, shortName);
                else
                    % Scalar ConfigurationData - show actual subclass name
                    nFields = length(value.xInternal__.OriginalKeys);
                    shortName = matlab.io.config.ConfigurationData.shortClassName(class(value));
                    str = sprintf('[1x1 %s with %d %s]', shortName, nFields, matlab.io.config.ConfigurationData.pluralize("key", nFields));
                end
            elseif isa(value, 'dictionary')
                nKeys = numEntries(value);
                str = sprintf('[1x1 dictionary with %d %s]', nKeys, matlab.io.config.ConfigurationData.pluralize("entry", nKeys));
            elseif ischar(value)
                if length(value) > 50
                    str = sprintf('''%s...'' [1x%d char]', value(1:50), length(value));
                else
                    str = sprintf('''%s''', value);
                end
            elseif isstring(value) && isscalar(value)
                if strlength(value) > 50
                    str = sprintf('"%s..."', extractBefore(value, 51));
                else
                    str = sprintf('"%s"', value);
                end
            elseif isnumeric(value)
                if isscalar(value)
                    str = sprintf('%g', value);
                elseif numel(value) <= 5
                    % Show small arrays inline
                    numStr = sprintf('%g ', value);
                    str = sprintf('[%s]', strtrim(numStr));
                else
                    % Show size and type for large arrays
                    sizeStr = sprintf('%dx', size(value));
                    sizeStr = sizeStr(1:end-1); % Remove trailing 'x'
                    str = sprintf('[%s %s]', sizeStr, class(value));
                end
            elseif islogical(value)
                if isscalar(value)
                    if value
                        str = 'true';
                    else
                        str = 'false';
                    end
                else
                    sizeStr = sprintf('%dx', size(value));
                    sizeStr = sizeStr(1:end-1);
                    str = sprintf('[%s logical]', sizeStr);
                end
            else
                % Generic handling
                sizeStr = sprintf('%dx', size(value));
                sizeStr = sizeStr(1:end-1);
                str = sprintf('[%s %s]', sizeStr, class(value));
            end
        end

    end

    methods (Access = protected)
        function n = dotListLength(~, ~, ~)
            n = 1;
        end

        function varargout = dotReference(obj, indexOp, ~)
            % Handle dot notation (.) for data key access
            %
            % With OverridesPublicDotMethodCall, ALL dot notation from outside
            % the class comes here first. We prioritize data keys over methods,
            % so users can have keys named "keys", "isfield", etc.
            % To call methods, use function syntax: keys(obj), isfield(obj, key)

            % Handle array dot reference: arr.field returns concatenated values
            if ~isscalar(obj)
                fieldName = indexOp(1).Name;

                % Block reserved key
                if fieldName == "xInternal__"
                    error('ConfigurationData:ReservedKey', ...
                        'Key "xInternal__" is reserved for internal use.');
                end

                % Check if next operation is Paren with logical indices matching array size
                % This enables pattern: arr.field(logicalMask) where logicalMask = iskey(arr, "field")
                remainingIndexOp = indexOp(2:end);
                if numel(indexOp) > 1 && indexOp(2).Type == matlab.indexing.IndexingOperationType.Paren
                    indices = indexOp(2).Indices;
                    if numel(indices) == 1
                        idx = indices{1};
                        if islogical(idx) && isequal(size(idx), size(obj))
                            % Pre-filter the array by logical indices
                            obj = obj(idx);
                            remainingIndexOp = indexOp(3:end);  % Skip the Paren we just consumed
                        end
                    end
                end

                % Check which elements have the key (on potentially pre-filtered array)
                hasKey = iskey(obj, fieldName);
                if ~all(hasKey)
                    missingIndices = find(~hasKey);
                    error('ConfigurationData:MissingKey', ...
                        ['Key "%s" is missing in elements %s.\n' ...
                         'Use iskey(arr, ''%s'') to check which elements have this key.'], ...
                        fieldName, mat2str(missingIndices(:)'), fieldName);
                end

                % Collect values from all elements
                values = cell(size(obj));
                for i = 1:numel(obj)
                    resolvedKey = obj(i).resolveKey(fieldName);
                    values{i} = obj(i).getData(resolvedKey);
                end

                % Try to concatenate homogeneously
                result = obj.tryConcatenate(values, fieldName);

                % Handle chained indexing on the result
                if ~isempty(remainingIndexOp)
                    if isa(result, 'matlab.io.config.ConfigurationData') && ~isscalar(result)
                        % Recursive array dot reference
                        result = dotReference(result, remainingIndexOp);
                    elseif isa(result, 'matlab.io.config.ConfigurationData') && isscalar(result)
                        result = dotReference(result, remainingIndexOp);
                    else
                        % Can't chain into non-ConfigurationData
                        error('ConfigurationData:InvalidChain', ...
                            'Cannot chain into non-ConfigurationData value');
                    end
                end

                varargout{1} = result;
                return;
            end

            if indexOp(1).Type == "Dot"
                % Dot notation: obj.key
                key = indexOp(1).Name;

                % Block access to reserved internal property name
                if key == "xInternal__"
                    error('ConfigurationData:ReservedKey', ...
                        'Key "xInternal__" is reserved for internal use.');
                end

                % PRIORITY 1: Check if key exists in data (allows "keys", "isfield", etc.)
                resolvedKey = obj.resolveKey(key);
                if ~isempty(resolvedKey)
                    value = obj.getData(resolvedKey);

                    % Handle chained indexing
                    if length(indexOp) > 1
                        if indexOp(2).Type == "Paren"
                            % Array indexing: obj.key(indices)
                            indices = indexOp(2).Indices{:};
                            value = value(indices);

                            % Handle further chaining: obj.key(1).field
                            if length(indexOp) > 2
                                if isa(value, 'matlab.io.config.ConfigurationData')
                                    value = dotReference(value, indexOp(3:end));
                                else
                                    error('ConfigurationData:InvalidChain', ...
                                        'Cannot chain into non-ConfigurationData value');
                                end
                            end
                        elseif indexOp(2).Type == "Brace"
                            % Cell array indexing: obj.key{indices}
                            indices = indexOp(2).Indices{:};
                            value = value{indices};

                            % Handle further chaining: obj.key{1}.field
                            if length(indexOp) > 2
                                if isa(value, 'matlab.io.config.ConfigurationData')
                                    value = dotReference(value, indexOp(3:end));
                                else
                                    error('ConfigurationData:InvalidChain', ...
                                        'Cannot chain into non-ConfigurationData value');
                                end
                            end
                        elseif indexOp(2).Type == "Dot"
                            % Nested dot: obj.key.field
                            if isa(value, 'matlab.io.config.ConfigurationData')
                                value = dotReference(value, indexOp(2:end));
                            else
                                error('ConfigurationData:InvalidChain', ...
                                    'Cannot chain into non-ConfigurationData value');
                            end
                        end
                    end

                    varargout{1} = value;
                    return;
                end

                % Key doesn't exist - error
                error('ConfigurationData:InvalidKey', ...
                    'Key "%s" does not exist.', key);

            elseif indexOp(1).Type == "Paren"
                % Direct array indexing on obj: should not happen
                error('ConfigurationData:UnsupportedIndexing', ...
                    'Direct parenthesis indexing not supported');
            else
                error('ConfigurationData:UnsupportedIndexing', ...
                    'Unsupported indexing type: %s', indexOp(1).Type);
            end
        end

        function obj = dotAssign(obj, indexOp, varargin)
            key = indexOp(1).Name;

            % Block assignment to reserved internal property name
            if key == "xInternal__"
                error('ConfigurationData:ReservedKey', ...
                    'Key "xInternal__" is reserved for internal use.');
            end

            % Handle chained assignment: obj.a.b.c = value or obj.a(idx).b = value
            if length(indexOp) > 1
                % Check if next operation is Paren (array indexing)
                if indexOp(2).Type == matlab.indexing.IndexingOperationType.Paren
                    % Pattern: obj.field(idx)... = value
                    % Get the array
                    if ~isKey(obj.xInternal__.Data, key)
                        error('ConfigurationData:InvalidIndex', ...
                            'Cannot index into non-existent field ''%s''', key);
                    end
                    arr = obj.getData(key);

                    % Extract index
                    idx = indexOp(2).Indices{:};

                    % Get the element
                    elem = arr(idx);

                    % Apply remaining chain to element
                    if length(indexOp) > 2
                        % More operations after the paren: obj.field(idx).subfield = value
                        elem = dotAssign(elem, indexOp(3:end), varargin{:});
                    else
                        % Direct element replacement: obj.field(idx) = value
                        elem = varargin{end};
                    end

                    % Write element back to array
                    arr(idx) = elem;

                    % Store array back
                    obj = obj.setData(key, arr);
                else
                    % Pattern: obj.field.subfield = value (next op is Dot)
                    % Get or create the nested object
                    if isKey(obj.xInternal__.Data, key)
                        nested = obj.getData(key);
                        if ~isa(nested, 'matlab.io.config.ConfigurationData')
                            % Scalar value exists - replace with same class as parent
                            nested = feval(class(obj));
                            nested = copySourceFormat(obj, nested);
                        end
                    else
                        % Create new nested object of same class as parent
                        nested = feval(class(obj));
                        nested = copySourceFormat(obj, nested);
                    end

                    % Recursively assign to nested object
                    nested = dotAssign(nested, indexOp(2:end), varargin{:});

                    % Store the nested ConfigurationData directly (preserve order)
                    obj = obj.setData(key, nested);
                end

                % Track order
                if ~any(obj.xInternal__.OriginalKeys == key)
                    obj.xInternal__.OriginalKeys(end+1) = key;
                end

                % Create alias if needed
                validKey = matlab.lang.makeValidName(key);
                if ~strcmp(validKey, key)
                    obj.xInternal__.KeyAliases(validKey) = key;
                end
            else
                % Simple assignment: obj.key = value
                value = varargin{end};

                % Create alias if needed
                validKey = matlab.lang.makeValidName(key);
                if ~strcmp(validKey, key)
                    obj.xInternal__.KeyAliases(validKey) = key;
                end

                % Store
                obj = obj.setData(key, value);

                % Track order
                if ~any(obj.xInternal__.OriginalKeys == key)
                    obj.xInternal__.OriginalKeys(end+1) = key;
                end
            end
        end

        function obj = parenDotAssign(obj, indexOp, varargin)
            % Handle patterns:
            %   1. obj(idx).field = value  (array element assignment)
            %   2. obj.methodName = value  (method name conflicts)
            %
            % For pattern 1, indexOp(1) is Paren, indexOp(2) is Dot
            % For pattern 2, indexOp(1) is Dot (method name)

            value = varargin{end};

            if indexOp(1).Type == matlab.indexing.IndexingOperationType.Paren
                % Pattern: obj(idx).field = value (or obj(idx).field.subfield = ...)
                idx = indexOp(1).Indices{:};

                % Get the indexed element
                elem = obj(idx);

                % Apply the remaining dot operations
                if length(indexOp) > 1
                    elem = dotAssign(elem, indexOp(2:end), varargin{:});
                else
                    % Shouldn't happen for parenDot, but handle it
                    elem = value;
                end

                % Write element back
                obj(idx) = elem;
            else
                % Pattern: obj.methodName = value (method name conflict)
                key = indexOp(1).Name;

                % Block assignment to reserved internal property name
                if key == "xInternal__"
                    error('ConfigurationData:ReservedKey', ...
                        'Key "xInternal__" is reserved for internal use.');
                end

                % Store directly using setData to bypass method resolution
                obj = obj.setData(key, value);

                % Track order
                if ~any(obj.xInternal__.OriginalKeys == key)
                    obj.xInternal__.OriginalKeys(end+1) = key;
                end

                % Create alias if needed
                validKey = matlab.lang.makeValidName(key);
                if ~strcmp(validKey, key)
                    obj.xInternal__.KeyAliases(validKey) = key;
                end
            end
        end

        function n = parenDotListLength(~, ~, ~)
            n = 1;
        end

        function resolvedKey = resolveKey(obj, key)
            key = string(key);

            if isKey(obj.xInternal__.Data, key)
                resolvedKey = key;
                return;
            end

            if isKey(obj.xInternal__.KeyAliases, key)
                resolvedKey = obj.xInternal__.KeyAliases(key);
                return;
            end

            resolvedKey = '';
        end

        function s = dictToStruct(obj, d)
            %DICTTOSTRUCT Convert dictionary to struct recursively (private helper)
            s = struct;
            dictKeys = keys(d);
            for i = 1:length(dictKeys)
                key = dictKeys(i);
                val = d(key);
                value = val{1};  % Unwrap from cell

                % Recursively handle nested dictionaries
                if isa(value, 'dictionary')
                    value = obj.dictToStruct(value);
                end

                fieldName = matlab.lang.makeValidName(key);
                s.(fieldName) = value;
            end
        end

        function value = convertImportValue(obj, value)
            %CONVERTIMPORTVALUE Recursively convert nested structs/dicts to ConfigurationData
            %   This preserves the class type (YAMLData stays YAMLData, etc.)

            if isstruct(value)
                if isscalar(value)
                    % Scalar struct -> ConfigurationData of same class
                    nested = feval(class(obj));
                    nested = importFrom(nested, value);
                    value = nested;
                else
                    % Struct array -> array of ConfigurationData
                    arr(numel(value)) = feval(class(obj));
                    for iVal = 1:numel(value)
                        arr(iVal) = obj.convertImportValue(value(iVal));
                    end
                    value = arr;
                end
            elseif isa(value, 'dictionary')
                % Dictionary -> ConfigurationData of same class
                nested = feval(class(obj));
                nested = importFrom(nested, value);
                value = nested;
            end
            % Other types (numeric, string, etc.) pass through unchanged
            % They will be validated by setData when assigned
        end

        function result = tryConcatenate(~, values, fieldName)
            %TRYCONCATENATE Attempt to concatenate cell array of values into typed array
            %   Returns typed array if all values have same type, otherwise errors.
            %   This implements the "strict homogeneous" policy: no surprise cells.

            if isempty(values)
                result = {};
                return;
            end

            % Get types of all values
            types = cellfun(@class, values, 'UniformOutput', false);
            uniqueTypes = unique(types);

            if numel(uniqueTypes) > 1
                % Find first mismatch to report helpful error
                firstType = types{1};
                for i = 2:numel(types)
                    if ~strcmp(types{i}, firstType)
                        error('ConfigurationData:TypeMismatch', ...
                            ['Cannot concatenate values for key "%s": types differ.\n' ...
                             'Element 1 is %s, element %d is %s.\n' ...
                             'Use arrayfun(@(x) x.%s, arr, ''UniformOutput'', false) for heterogeneous values.'], ...
                            fieldName, firstType, i, types{i}, fieldName);
                    end
                end
            end

            % All same type - try to concatenate
            theType = uniqueTypes{1};

            % Handle different types appropriately
            if strcmp(theType, 'char')
                % char arrays -> convert to string array
                result = string(values);
            elseif contains(theType, 'ConfigurationData') || ...
                   startsWith(theType, 'matlab.io.config.')
                % ConfigurationData objects -> concatenate into array
                try
                    result = [values{:}];
                catch
                    % Different sizes or incompatible - error
                    error('ConfigurationData:ConcatenationFailed', ...
                        ['Cannot concatenate ConfigurationData values for key "%s".\n' ...
                         'Use arrayfun(@(x) x.%s, arr, ''UniformOutput'', false) for cell output.'], ...
                        fieldName, fieldName);
                end
            elseif isnumeric(values{1}) || islogical(values{1}) || isstring(values{1})
                % Numeric, logical, string - try direct concatenation
                try
                    % Check if all values are scalars
                    allScalars = all(cellfun(@isscalar, values));
                    if allScalars
                        result = [values{:}];
                    else
                        % Non-scalar values - need to verify compatibility
                        % Check all have same size
                        sizes = cellfun(@size, values, 'UniformOutput', false);
                        if all(cellfun(@(s) isequal(s, sizes{1}), sizes))
                            % Same size - can concatenate
                            result = cat(1, values{:});
                        else
                            error('ConfigurationData:SizeMismatch', ...
                                ['Cannot concatenate values for key "%s": sizes differ.\n' ...
                                 'Use arrayfun(@(x) x.%s, arr, ''UniformOutput'', false) for cell output.'], ...
                                fieldName, fieldName);
                        end
                    end
                catch ME
                    if contains(ME.identifier, 'ConfigurationData:')
                        rethrow(ME);
                    end
                    error('ConfigurationData:ConcatenationFailed', ...
                        ['Cannot concatenate values for key "%s".\n' ...
                         'Use arrayfun(@(x) x.%s, arr, ''UniformOutput'', false) for cell output.'], ...
                        fieldName, fieldName);
                end
            else
                % Other types - try generic concatenation
                try
                    result = [values{:}];
                catch
                    error('ConfigurationData:ConcatenationFailed', ...
                        ['Cannot concatenate values for key "%s" of type %s.\n' ...
                         'Use arrayfun(@(x) x.%s, arr, ''UniformOutput'', false) for cell output.'], ...
                        fieldName, theType, fieldName);
                end
            end
        end
    end

    methods (Hidden)
        % Helper methods for dictionary access (encapsulate cell wrapping)
        % Public but hidden - needed for workarounds when key names conflict with methods
        function value = getData(obj, key)
            %GETDATA Get value from Data dictionary (unwraps cell)
            key = string(key);
            val = obj.xInternal__.Data(key);
            value = val{1};
        end

        function obj = setData(obj, key, value)
            %SETDATA Set value in Data dictionary (wraps in cell)
            %   Validates the value type before storing.
            key = string(key);
            value = obj.validateAndConvertValue(value, key);
            obj.xInternal__.Data(key) = {value};
        end

        function obj = addKey(obj, key)
            %ADDKEY Add a key to the key order tracking if not already present
            %   Used by parsers when directly manipulating data.
            key = string(key);
            if ~any(obj.xInternal__.OriginalKeys == key)
                obj.xInternal__.OriginalKeys(end+1) = key;
            end
        end

        function obj = setKeyAlias(obj, alias, originalKey)
            %SETKEYALIAS Set a key alias mapping
            %   Used by parsers when key names need valid MATLAB identifiers.
            alias = string(alias);
            originalKey = string(originalKey);
            obj.xInternal__.KeyAliases(alias) = originalKey;
        end

        function obj = importFrom(obj, inputData)
            %IMPORTFROM Import data from struct or dictionary
            %   This method handles conversion from external data types.
            %   It preserves the class type for nested objects.
            %
            %   Example:
            %       obj = tomldata();
            %       obj = importFrom(obj, myStruct);

            if isstruct(inputData)
                fields = fieldnames(inputData);
                for i = 1:numel(fields)
                    key = fields{i};
                    value = inputData.(key);
                    value = obj.convertImportValue(value);
                    obj.(key) = value;
                end
            elseif isa(inputData, 'dictionary')
                keyList = keys(inputData);
                for i = 1:numel(keyList)
                    key = keyList(i);
                    val = inputData(key);
                    value = val{1};  % Unwrap from cell
                    value = obj.convertImportValue(value);
                    obj.(key) = value;
                end
            else
                error('ConfigurationData:InvalidInput', ...
                    'Input must be struct or dictionary. Got %s.', class(inputData));
            end
        end
    end

    methods (Access = protected)
        function value = validateAndConvertValue(obj, value, key)
            %VALIDATEANDCONVERTVALUE Validate and optionally convert a value
            %   Subclasses can override to add format-specific type handling.
            %   Returns the (possibly converted) value, or throws an error.

            % Handle cell arrays recursively
            if iscell(value)
                for i = 1:numel(value)
                    value{i} = obj.validateAndConvertValue(value{i}, key);
                end
                return;
            end

            % Handle struct recursively
            if isstruct(value)
                fields = fieldnames(value);
                for i = 1:numel(value)
                    for j = 1:numel(fields)
                        value(i).(fields{j}) = obj.validateAndConvertValue(value(i).(fields{j}), key);
                    end
                end
                return;
            end

            % Allowed base types (numeric must be real - complex checked separately below)
            if (isnumeric(value) && isreal(value)) || islogical(value) || ischar(value) || isstring(value)
                return;  % OK
            end

            % ConfigurationData is always allowed
            if isa(value, 'matlab.io.config.ConfigurationData')
                return;  % OK
            end

            % missing represents JSON/config null
            if isa(value, 'missing')
                return;  % OK
            end

            % Empty values
            if isempty(value)
                return;  % OK (will revisit serialization)
            end

            % Datetime - base class converts to ISO 8601 string
            % Subclasses (like TOMLData) can override to keep native datetime
            if isa(value, 'datetime')
                value = string(value, 'yyyy-MM-dd''T''HH:mm:ss');
                return;
            end

            % Duration - convert to ISO 8601 duration or seconds
            if isa(value, 'duration')
                value = seconds(value);  % Convert to numeric seconds
                return;
            end

            % Disallowed types with helpful messages
            if isa(value, 'function_handle')
                error('ConfigurationData:InvalidType', ...
                    ['Cannot assign function_handle to key "%s".\n' ...
                     'Function handles cannot be serialized to configuration files.'], key);
            end

            if isa(value, 'table') || isa(value, 'timetable')
                error('ConfigurationData:InvalidType', ...
                    ['Cannot assign %s to key "%s".\n' ...
                     'Convert to struct first: struct(yourTable)'], class(value), key);
            end

            if isa(value, 'categorical')
                error('ConfigurationData:InvalidType', ...
                    ['Cannot assign categorical to key "%s".\n' ...
                     'Convert to string first: string(yourCategorical)'], key);
            end

            if isnumeric(value) && ~isreal(value)
                error('ConfigurationData:InvalidType', ...
                    ['Cannot assign complex numbers to key "%s".\n' ...
                     'Configuration files do not support imaginary numbers.'], key);
            end

            % Generic unsupported type
            error('ConfigurationData:InvalidType', ...
                ['Cannot assign %s to key "%s".\n' ...
                 'Supported types: numeric, logical, char, string, cell, struct, ' ...
                 'datetime, duration, and ConfigurationData objects.'], class(value), key);
        end
    end

    methods (Access = private)
        function target = copySourceFormat(obj, target)
            %COPYSOURCEFORMAT Copy SourceFormat to another ConfigurationData object
            %   Uses builtin to bypass overloaded dot methods, preventing
            %   SourceFormat from being added as a user data key.
            s = substruct('.', 'xInternal__');
            internal = builtin('subsref', target, s);
            internal.SourceFormat = obj.xInternal__.SourceFormat;
            target = builtin('subsasgn', target, s, internal);
        end
    end

    methods (Static, Access = private)
        function word = pluralize(singular, count)
            %PLURALIZE Return singular or plural form based on count
            if count == 1
                word = singular;
            else
                word = singular + "s";
            end
        end

        function shortName = shortClassName(fullName)
            %SHORTCLASSNAME Strip namespace prefix from class name for cleaner display
            %   'matlab.io.config.TOMLData' -> 'TOMLData'
            shortName = regexprep(fullName, '^matlab\.io\.config\.', '');
        end
    end
end
