classdef ConfigurationData < matlab.mixin.indexing.RedefinesDot & ...
                             matlab.mixin.indexing.OverridesPublicDotMethodCall & ...
                             matlab.mixin.CustomDisplay
    %CONFIGURATIONDATA Base class for structured configuration data
    %   Value class with dot notation access to configuration data.
    %   Supports keys with special characters like hyphens.
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
        Data dictionary = configureDictionary("string", "cell")
        KeyAliases dictionary = configureDictionary("string", "string")
        OriginalKeys string = string.empty
    end

    properties (SetAccess = protected)
        SourceFormat string = "unknown"
    end

    methods
        function obj = ConfigurationData(inputData)
            %CONFIGURATIONDATA Create ConfigurationData object
            %   obj = ConfigurationData() creates an empty object
            %   obj = ConfigurationData(s) converts struct s
            %   obj = ConfigurationData(d) converts dictionary d
            %   obj = ConfigurationData(m) converts containers.Map m
            %
            %   Nested structs, dictionaries, and Maps are recursively
            %   converted to ConfigurationData objects of the same class.
            %
            %   Example:
            %       s = struct('name', 'test', 'nested', struct('value', 42));
            %       config = YAMLData(s);
            %       config.name  % returns 'test'
            %
            %   See also STRUCT, DICTIONARY, MAP

            obj.Data = configureDictionary("string", "cell");
            obj.KeyAliases = configureDictionary("string", "string");
            obj.OriginalKeys = string.empty;

            if nargin > 0 && ~isempty(inputData)
                obj = obj.importFrom(inputData);
            end
        end

        function newObj = copy(obj)
            %COPY Create an independent copy of the ConfigurationData object
            %   With value semantics, assignment already creates a copy.
            %   This method is retained for backwards compatibility.
            newObj = obj;
        end

        function k = keys(obj)
            k = obj.OriginalKeys;
        end

        function tf = isfield(obj, key)
            % Handle arrays - check first element only
            if numel(obj) > 1
                tf = isfield(obj(1), key);
                return;
            end
            resolvedKey = obj.resolveKey(key);
            tf = ~isempty(resolvedKey);
        end

        function s = struct(obj)
            s = struct;
            for i = 1:length(obj.OriginalKeys)
                key = obj.OriginalKeys(i);
                value = obj.getData(key);

                if isa(value, 'ConfigurationData')
                    if isscalar(value)
                        value = struct(value);
                    else
                        % Handle array of ConfigurationData objects
                        structArray = arrayfun(@struct, value);
                        value = structArray;
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
            for i = 1:length(obj.OriginalKeys)
                key = obj.OriginalKeys(i);
                value = obj.getData(key);

                if isa(value, 'ConfigurationData')
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
            for i = 1:length(obj.OriginalKeys)
                key = obj.OriginalKeys(i);
                value = obj.getData(key);

                if isa(value, 'ConfigurationData')
                    if isscalar(value)
                        value = dictionary(value);  % Recursive
                    else
                        % Array of ConfigurationData -> cell array of dictionaries
                        value = arrayfun(@dictionary, value, 'UniformOutput', false);
                    end
                end

                d(key) = {value};
            end
        end

        function p = properties(obj)
            %PROPERTIES Return list of dynamic properties (keys)
            p = obj.OriginalKeys;
        end

        function names = fieldnames(obj)
            %FIELDNAMES Get field names (alias for keys)
            names = keys(obj);
        end

        function tf = iskey(obj, key)
            %ISKEY Check if key exists (alias for isfield)
            tf = obj.isfield(key);
        end

        function obj = rmfield(obj, key)
            %RMFIELD Remove a field
            resolvedKey = obj.resolveKey(key);
            if isempty(resolvedKey)
                error('ConfigurationData:InvalidKey', ...
                    'Key "%s" does not exist.', key);
            end

            % Remove from data (dictionary requires capturing return)
            obj.Data = remove(obj.Data, resolvedKey);

            % Remove from order tracking
            obj.OriginalKeys(obj.OriginalKeys == resolvedKey) = [];

            % Remove alias if exists
            validKey = matlab.lang.makeValidName(key);
            if isKey(obj.KeyAliases, validKey)
                obj.KeyAliases = remove(obj.KeyAliases, validKey);
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
                nKeys = length(obj.OriginalKeys);
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

            if length(obj.OriginalKeys) == 0
                return;
            end

            % Check if there's nested hierarchy
            hasHierarchy = false;
            for i = 1:length(obj.OriginalKeys)
                value = obj.getData(obj.OriginalKeys(i));
                if isa(value, 'ConfigurationData') || isa(value, 'dictionary')
                    hasHierarchy = true;
                    break;
                end
            end

            % Display each field
            for i = 1:length(obj.OriginalKeys)
                key = obj.OriginalKeys(i);
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
                keySets{i} = obj(i).OriginalKeys; % Already a string array
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
            fprintf('  %s <a href="matlab:helpPopup %s">%s</a> array with keys:\n\n', ...
                dimStr, class(obj), class(obj));

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
            if isa(value, 'ConfigurationData')
                if numel(value) > 1
                    % Array of ConfigurationData
                    sizeStr = sprintf('%dx', size(value));
                    sizeStr = sizeStr(1:end-1);
                    str = sprintf('[%s %s]', sizeStr, class(value));
                else
                    % Scalar ConfigurationData - show actual subclass name
                    nFields = length(value.OriginalKeys);
                    className = class(value);
                    str = sprintf('[1×1 %s with %d %s]', className, nFields, ConfigurationData.pluralize("key", nFields));
                end
            elseif isa(value, 'dictionary')
                nKeys = numEntries(value);
                str = sprintf('[1×1 dictionary with %d %s]', nKeys, ConfigurationData.pluralize("entry", nKeys));
            elseif ischar(value)
                if length(value) > 50
                    str = sprintf('''%s...'' [1×%d char]', value(1:50), length(value));
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

            % Check for unsupported array dot-reference: arr.field where arr is non-scalar
            if ~isscalar(obj)
                fieldName = indexOp(1).Name;
                error('ConfigurationData:ArrayDotReference', ...
                    ['Cannot access field ''%s'' on a %s array of %s objects.\n' ...
                     'Index into the array first, e.g., obj(1).%s or use:\n' ...
                     '  arrayfun(@(x) x.%s, obj)'], ...
                    fieldName, mat2str(size(obj)), class(obj), fieldName, fieldName);
            end

            if indexOp(1).Type == "Dot"
                % Dot notation: obj.key
                key = indexOp(1).Name;

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
                                if isa(value, 'ConfigurationData')
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
                                if isa(value, 'ConfigurationData')
                                    value = dotReference(value, indexOp(3:end));
                                else
                                    error('ConfigurationData:InvalidChain', ...
                                        'Cannot chain into non-ConfigurationData value');
                                end
                            end
                        elseif indexOp(2).Type == "Dot"
                            % Nested dot: obj.key.field
                            if isa(value, 'ConfigurationData')
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

                % PRIORITY 2: Check if accessing a real class property
                % (OriginalKeys, Data, KeyAliases, SourceFormat)
                if isprop(obj, key)
                    value = obj.(key);
                    if length(indexOp) > 1
                        value = subsref(value, indexOp(2:end));
                    end
                    varargout{1} = value;
                    return;
                end

                % PRIORITY 3: Key doesn't exist - error
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

            % Handle chained assignment: obj.a.b.c = value or obj.a(idx).b = value
            if length(indexOp) > 1
                % Check if next operation is Paren (array indexing)
                if indexOp(2).Type == matlab.indexing.IndexingOperationType.Paren
                    % Pattern: obj.field(idx)... = value
                    % Get the array
                    if ~isKey(obj.Data, key)
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
                    if isKey(obj.Data, key)
                        nested = obj.getData(key);
                        if ~isa(nested, 'ConfigurationData')
                            % Scalar value exists - replace with same class as parent
                            nested = feval(class(obj));
                            nested.SourceFormat = obj.SourceFormat;
                        end
                    else
                        % Create new nested object of same class as parent
                        nested = feval(class(obj));
                        nested.SourceFormat = obj.SourceFormat;
                    end

                    % Recursively assign to nested object
                    nested = dotAssign(nested, indexOp(2:end), varargin{:});

                    % Store the nested ConfigurationData directly (preserve order)
                    obj = obj.setData(key, nested);
                end

                % Track order
                if ~any(obj.OriginalKeys == key)
                    obj.OriginalKeys(end+1) = key;
                end

                % Create alias if needed
                validKey = matlab.lang.makeValidName(key);
                if ~strcmp(validKey, key)
                    obj.KeyAliases(validKey) = key;
                end
            else
                % Simple assignment: obj.key = value
                value = varargin{end};

                % Create alias if needed
                validKey = matlab.lang.makeValidName(key);
                if ~strcmp(validKey, key)
                    obj.KeyAliases(validKey) = key;
                end

                % Store
                obj = obj.setData(key, value);

                % Track order
                if ~any(obj.OriginalKeys == key)
                    obj.OriginalKeys(end+1) = key;
                end
            end
        end

        function obj = parenDotAssign(obj, indexOp, varargin)
            % Handle method name conflicts (e.g., obj.empty = value)
            % When a key matches a method name, MATLAB calls this instead of dotAssign
            % because it interprets obj.methodName as a method call

            key = indexOp(1).Name;
            value = varargin{end};

            % Store directly using setData to bypass method resolution
            obj = obj.setData(key, value);

            % Track order
            if ~any(obj.OriginalKeys == key)
                obj.OriginalKeys(end+1) = key;
            end

            % Create alias if needed
            validKey = matlab.lang.makeValidName(key);
            if ~strcmp(validKey, key)
                obj.KeyAliases(validKey) = key;
            end
        end

        function n = parenDotListLength(~, ~, ~)
            n = 1;
        end

        function resolvedKey = resolveKey(obj, key)
            key = string(key);

            if isKey(obj.Data, key)
                resolvedKey = key;
                return;
            end

            if isKey(obj.KeyAliases, key)
                resolvedKey = obj.KeyAliases(key);
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

        function obj = importFrom(obj, inputData)
            %IMPORTFROM Import data from struct, dictionary, or containers.Map
            %   This protected method handles the conversion logic for the
            %   constructor. It preserves the class type for nested objects.

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
            elseif isa(inputData, 'containers.Map')
                keyList = keys(inputData);
                for i = 1:numel(keyList)
                    key = keyList{i};
                    value = inputData(key);
                    value = obj.convertImportValue(value);
                    obj.(key) = value;
                end
            else
                error('ConfigurationData:InvalidInput', ...
                    'Input must be struct, dictionary, or containers.Map. Got %s.', class(inputData));
            end
        end

        function value = convertImportValue(obj, value)
            %CONVERTIMPORTVALUE Recursively convert nested structs/dicts to ConfigurationData
            %   This preserves the class type (YAMLData stays YAMLData, etc.)

            if isstruct(value)
                if isscalar(value)
                    % Scalar struct -> ConfigurationData of same class
                    nested = feval(class(obj));
                    nested = nested.importFrom(value);
                    value = nested;
                else
                    % Struct array -> array of ConfigurationData
                    arr = arrayfun(@(v) obj.convertImportValue(v), value);
                    value = arr;
                end
            elseif isa(value, 'dictionary')
                % Dictionary -> ConfigurationData of same class
                nested = feval(class(obj));
                nested = nested.importFrom(value);
                value = nested;
            elseif isa(value, 'containers.Map')
                % Map -> ConfigurationData of same class
                nested = feval(class(obj));
                nested = nested.importFrom(value);
                value = nested;
            end
            % Other types (numeric, string, etc.) pass through unchanged
            % They will be validated by setData when assigned
        end
    end

    methods (Hidden)
        % Helper methods for dictionary access (encapsulate cell wrapping)
        % Public but hidden - needed for workarounds when key names conflict with methods
        function value = getData(obj, key)
            %GETDATA Get value from Data dictionary (unwraps cell)
            key = string(key);
            val = obj.Data(key);
            value = val{1};
        end

        function obj = setData(obj, key, value)
            %SETDATA Set value in Data dictionary (wraps in cell)
            %   Validates the value type before storing.
            key = string(key);
            value = obj.validateAndConvertValue(value, key);
            obj.Data(key) = {value};
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

            % Allowed base types
            if isnumeric(value) || islogical(value) || ischar(value) || isstring(value)
                return;  % OK
            end

            % ConfigurationData is always allowed
            if isa(value, 'ConfigurationData')
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

            if ~isreal(value)
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

    methods (Static, Access = private)
        function word = pluralize(singular, count)
            %PLURALIZE Return singular or plural form based on count
            if count == 1
                word = singular;
            else
                word = singular + "s";
            end
        end
    end
end
