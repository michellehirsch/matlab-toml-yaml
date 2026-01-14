classdef ConfigurationData < handle & ...
                             matlab.mixin.indexing.RedefinesDot & ...
                             matlab.mixin.CustomDisplay
    %CONFIGURATIONDATA Base class for structured configuration data
    %   Handle class with dot notation access to configuration data.
    %   Supports keys with special characters like hyphens.
    %   
    %   Note: This is a handle class. To create an independent copy,
    %   use the copy method: newData = copy(data)
    
    properties (Access = public, Hidden = true)
        Data containers.Map
        KeyAliases containers.Map
        OriginalKeys string
    end
    
    properties (SetAccess = protected)
        SourceFormat string = "unknown"
    end
    
    methods
        function obj = ConfigurationData
            obj.Data = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.KeyAliases = containers.Map('KeyType', 'char', 'ValueType', 'char');
            obj.OriginalKeys = string.empty;
        end
        
        function newObj = copy(obj)
            %COPY Create a deep copy of the ConfigurationData object
            newObj = ConfigurationData;
            newObj.SourceFormat = obj.SourceFormat;
            
            % Deep copy the Data map
            for i = 1:length(obj.OriginalKeys)
                key = obj.OriginalKeys(i);
                value = obj.Data(char(key));
                
                % Recursively copy ConfigurationData objects
                if isa(value, 'ConfigurationData')
                    value = copy(value);
                elseif isa(value, 'containers.Map')
                    value = obj.copyMap(value);
                end
                
                newObj.Data(char(key)) = value;
            end
            
            % Copy aliases
            aliasKeys = keys(obj.KeyAliases);
            for i = 1:length(aliasKeys)
                key = aliasKeys{i};
                newObj.KeyAliases(key) = obj.KeyAliases(key);
            end
            
            % Copy order
            newObj.OriginalKeys = obj.OriginalKeys;
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
                value = obj.Data(char(key));
                
                if isa(value, 'ConfigurationData')
                    value = struct(value);
                elseif isa(value, 'containers.Map')
                    % Recursively convert Map to struct
                    value = obj.mapToStruct(value);
                end
                
                fieldName = matlab.lang.makeValidName(char(key));
                s.(fieldName) = value;
            end
        end
        
        function m = map(obj)
            m = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for i = 1:length(obj.OriginalKeys)
                key = obj.OriginalKeys(i);
                value = obj.Data(char(key));
                
                if isa(value, 'ConfigurationData')
                    value = map(value);
                end
                
                m(char(key)) = value;
            end
        end
        
        function p = properties(obj)
            %PROPERTIES Return list of dynamic properties (keys)
            p = cellstr(obj.OriginalKeys);
        end
        
        function names = fieldnames(obj)
            %FIELDNAMES Get field names (alias for keys)
            names = obj.keys;
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
            
            % Remove from data
            remove(obj.Data, resolvedKey);
            
            % Remove from order tracking
            obj.OriginalKeys(obj.OriginalKeys == resolvedKey) = [];
            
            % Remove alias if exists
            validKey = matlab.lang.makeValidName(char(key));
            if isKey(obj.KeyAliases, validKey)
                remove(obj.KeyAliases, validKey);
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
                value = obj.Data(char(obj.OriginalKeys(i)));
                if isa(value, 'ConfigurationData') || isa(value, 'containers.Map')
                    hasHierarchy = true;
                    break;
                end
            end
            
            % Display each field
            for i = 1:length(obj.OriginalKeys)
                key = obj.OriginalKeys(i);
                value = obj.Data(char(key));
                
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
            elseif isa(value, 'containers.Map')
                nKeys = value.Count;
                str = sprintf('[1×1 ConfigurationData with %d %s]', nKeys, ConfigurationData.pluralize("key", nKeys));
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
            % Handle both dot notation (.) and array indexing

            % Check for unsupported array dot-reference: arr.field where arr is non-scalar
            if ~isscalar(obj)
                fieldName = indexOp(1).Name;
                error('ConfigurationData:ArrayDotReference', ...
                    ['Cannot access field ''%s'' on a %s array of %s objects.\n' ...
                     'Index into the array first, e.g., obj(1).%s or use:\n' ...
                     '  arrayfun(@(x) x.%s, obj)'], ...
                    fieldName, mat2str(size(obj)), class(obj), fieldName, fieldName);
            end

            if strcmp(indexOp(1).Type, 'Dot')
                % Dot notation: obj.key
                key = indexOp(1).Name;
                resolvedKey = obj.resolveKey(key);
                
                if isempty(resolvedKey)
                    error('ConfigurationData:InvalidKey', ...
                        'Key "%s" does not exist.', key);
                end
                
                value = obj.Data(resolvedKey);
                
                % Wrap nested Maps in ConfigurationData (legacy support)
                if isa(value, 'containers.Map')
                    value = obj.wrapNested(value);
                end
                
                % Handle chained indexing: obj.key(1).field or obj.key.field
                if length(indexOp) > 1
                    if strcmp(indexOp(2).Type, 'Paren')
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
                    elseif strcmp(indexOp(2).Type, 'Dot')
                        % Nested dot: obj.key.field
                        if isa(value, 'ConfigurationData')
                            value = dotReference(value, indexOp(2:end));
                        else
                            error('ConfigurationData:InvalidChain', ...
                                'Cannot chain into non-ConfigurationData value');
                        end
                    end
                end
                
            elseif strcmp(indexOp(1).Type, 'Paren')
                % Direct array indexing on obj: should not happen
                error('ConfigurationData:UnsupportedIndexing', ...
                    'Direct parenthesis indexing not supported');
            else
                error('ConfigurationData:UnsupportedIndexing', ...
                    'Unsupported indexing type: %s', indexOp(1).Type);
            end
            
            varargout{1} = value;
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
                    arr = obj.Data(key);

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
                    obj.Data(key) = arr;
                else
                    % Pattern: obj.field.subfield = value (next op is Dot)
                    % Get or create the nested object
                    if isKey(obj.Data, key)
                        nested = obj.Data(key);
                        % Wrap if it's a Map
                        if isa(nested, 'containers.Map')
                            nested = obj.wrapNested(nested);
                        elseif ~isa(nested, 'ConfigurationData')
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
                    obj.Data(key) = nested;
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
                
                % Unwrap ConfigurationData to Map (but keep OriginalKeys order)
                if isa(value, 'ConfigurationData')
                    % Store the ConfigurationData directly to preserve order
                    % value = value.map;  % DON'T convert to map - loses order!
                    % Just store the ConfigurationData object
                end
                
                % Store
                obj.Data(key) = value;
                
                % Track order
                if ~any(obj.OriginalKeys == key)
                    obj.OriginalKeys(end+1) = key;
                end
            end
        end

        function resolvedKey = resolveKey(obj, key)
            key = char(key);
            
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
        
        function nested = wrapNested(obj, mapData)
            nested = ConfigurationData;
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
        
        function s = mapToStruct(obj, m)
            %MAPTOSTRUCT Convert containers.Map to struct recursively (private helper)
            s = struct;
            mapKeys = keys(m);
            for i = 1:length(mapKeys)
                key = mapKeys{i};
                value = m(key);
                
                % Recursively handle nested Maps
                if isa(value, 'containers.Map')
                    value = obj.mapToStruct(value);
                end
                
                fieldName = matlab.lang.makeValidName(key);
                s.(fieldName) = value;
            end
        end
        
        function newMap = copyMap(~, oldMap)
            %COPYMAP Create a deep copy of a containers.Map (private helper)
            newMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            mapKeys = keys(oldMap);
            for i = 1:length(mapKeys)
                key = mapKeys{i};
                value = oldMap(key);

                % Recursively handle nested Maps
                if isa(value, 'containers.Map')
                    value = copyMap([], value);
                elseif isa(value, 'ConfigurationData')
                    value = copy(value);
                end

                newMap(key) = value;
            end
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
