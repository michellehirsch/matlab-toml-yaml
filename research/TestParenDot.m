% Test parenDotAssign behavior with RedefinesDot

% Create a test class that uses RedefinesDot
classdef TestParenDot < handle & matlab.mixin.indexing.RedefinesDot
    properties (Hidden)
        Data containers.Map
    end
    
    methods
        function obj = TestParenDot()
            obj.Data = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end
    end
    
    methods (Access = protected)
        function n = dotListLength(~, ~, ~)
            n = 1;
        end
        
        function varargout = dotReference(obj, indexOp, ~)
            key = indexOp(1).Name;
            if isKey(obj.Data, key)
                value = obj.Data(key);
                if length(indexOp) > 1
                    value = subsref(value, indexOp(2:end));
                end
            else
                error('Key not found: %s', key);
            end
            varargout{1} = value;
        end
        
        function obj = dotAssign(obj, indexOp, varargin)
            key = indexOp(1).Name;
            value = varargin{end};
            
            if length(indexOp) > 1
                % Chained: obj.key.subkey = value
                if isKey(obj.Data, key)
                    nested = obj.Data(key);
                else
                    nested = TestParenDot();
                end
                nested = dotAssign(nested, indexOp(2:end), value);
                obj.Data(key) = nested;
            else
                obj.Data(key) = value;
            end
        end
    end
end