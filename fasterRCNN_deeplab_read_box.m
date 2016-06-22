function [EXP, costs_box_vertices, box_edges, cost_box_edges, boxes] = fasterRCNN_deeplab_read_box(EXP,s_idx)
% Read boxes information -edges, costs, coordinates

%% load info
switch EXP.istest
    case 0
        folder = 'Trainingset02/';
    case 1
        folder = 'Testset02/';
end
box_color_dir = [EXP.BoxDir_color  EXP.label{s_idx} '/'];
box_color_seg_dir = ['/BS/joint-multicut-2/work/FBMS-fasterRCNN/deeplab/' folder EXP.label{s_idx} '/'];
box_flow_dir = [];
box_flow_seg_dir = [];


%% compute box unary cost
% with rank top 5 above 4
EXP = fasterRCNN_deeplab_compute_box_unary_cost(EXP,s_idx,box_color_dir,box_flow_dir,box_color_seg_dir,box_flow_seg_dir);

% compute_color_model(EXP,s_idx);

costs_box_vertices = double(cat(1,EXP.U_cost{:}));
boxes =  double([cat(1,EXP.U{:}) EXP.frame2node]);
%% compute box pairwise cost
EXP = compute_box_pairwise_cost(EXP,s_idx);

[cost_box_edges, box_edges] = cost2pair(EXP);
if EXP.box_pair_choice == 0
    cost_box_edges = zeros(size(cost_box_edges));
end

end