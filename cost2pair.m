function [cost_all, edge_idx_all] = cost2pair(EXP)

node_idx = EXP.node2frame;
temporal_thr = EXP.temporal_thr;
pairwise_cost = EXP.pairwise_cost;

num_frame = length(EXP.U);
edge_idx_all = [];
cost_all = [];

count = 1;
for i = 1:num_frame
    fprintf('cost2pair for frame: %d \n',i);
    node_idx_i = node_idx(i,1):node_idx(i,2);
    list = i+temporal_thr;
    valid = list <= num_frame;
    list = list(valid);
    for k = 1: length(list)
        j = list(k);
        % cost
        %cost = pairwise_cost{i,j}(:);
        cost = pairwise_cost{i,j}';
        cost = cost(:);
        if ~isempty(cost)
            % edge idx
            node_idx_j = node_idx(j,1):node_idx(j,2);
            node_1 = repmat(node_idx_i, [length(node_idx_j), 1]);
            node_2 = repmat(node_idx_j',[1, length(node_idx_i)]);
            edge_idx = [node_1(:),node_2(:)];
            
            if i~=j % different frame
                cost_all{count} = cost;
                assert(size(cost,1)==size(edge_idx,1));
                edge_idx_all{count} = edge_idx;
                count = count+1;
            else % same frame
                valid = logical(triu(ones(length(node_idx_i),length(node_idx_i)),1));
                valid = valid(:);
                
                cur_cost =  cost(valid);
                cur_edge_idx = edge_idx(valid,:);
                
                
                cost_all{count} = cur_cost;
                edge_idx_all{count} = cur_edge_idx;
                assert(size(cost,1)==size(edge_idx,1));
                count = count+1;
                if count == 1556
                    count
                end
            end
        end
    end
end
if size(edge_idx_all,1)>0
    edge_idx_all = uint64(cat(1,edge_idx_all{:}));
    cost_all = cat(1,cost_all{:});
end

% % KL edges use weight not cost
if strcmp(EXP.solver,'KL')
    cost_all = -cost_all;
end

% Just for the bug in KL.
if max(edge_idx_all(:)) ~= (EXP.num_node -1)
    edge_idx_all(end+1,:) = [EXP.num_node-1, EXP.num_node-2];
    cost_all(end+1,:) = 0;
end

end