classdef DebugDot < handle & matlab.mixin.indexing.RedefinesDot
    properties (Hidden)
        Data containers.Map
    end

    methods
        function obj = DebugDot()
            obj.Data = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end
    end

    methods (Access = protected)
        function n = dotListLength(~, ~, ~)
            n = 1;
        end

        function varargout = dotReference(obj, indexOp, ~)
            fprintf('dotReference called with %d indexOp(s)\n', length(indexOp));
            for i = 1:length(indexOp)
                fprintf('  indexOp(%d): Type=%s', i, string(indexOp(i).Type));
                if indexOp(i).Type == matlab.indexing.IndexingOperationType.Dot
                    fprintf(', Name=%s', indexOp(i).Name);
                elseif indexOp(i).Type == matlab.indexing.IndexingOperationType.Paren
                    fprintf(', Indices=%s', mat2str(cell2mat(indexOp(i).Indices)));
                end
                fprintf('\n');
            end
            varargout{1} = [];
        end

        function obj = dotAssign(obj, indexOp, varargin)
            fprintf('dotAssign called with %d indexOp(s)\n', length(indexOp));
            for i = 1:length(indexOp)
                fprintf('  indexOp(%d): Type=%s', i, string(indexOp(i).Type));
                if indexOp(i).Type == matlab.indexing.IndexingOperationType.Dot
                    fprintf(', Name=%s', indexOp(i).Name);
                elseif indexOp(i).Type == matlab.indexing.IndexingOperationType.Paren
                    fprintf(', Indices=%s', mat2str(cell2mat(indexOp(i).Indices)));
                end
                fprintf('\n');
            end
        end
    end
end
