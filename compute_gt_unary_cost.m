function EXP = compute_gt_unary_cost(EXP,gtInfo,s_idx)


checkdir = '/BS/joint-multicut/work/Tracking_result/UnaryBox/';
switch EXP.istest
    case 1
        T_label = 'Test_';
    case 0
        T_label = 'Train_';
end
checkfolder = [T_label 'score_' int2str(EXP.box_score_min) '_rank_' int2str(EXP.box_rank_num) '_nms_' num2str(EXP.box_NMS) '/'];
checkpath = [checkdir checkfolder];

num_frame = length(gtInfo(1).frameNums);
U = cell(num_frame,1);
U_cost = cell(num_frame,1);
U_list = cell(num_frame,1);
U_frame = cell(num_frame,1);
U_lsda_score = cell(num_frame,1);
F7 = cell(num_frame,1);%store f7 feature for metric learning
Segment = cell(num_frame,1);
if ~exist([checkpath EXP.label{s_idx}],'dir')
    mkdir([checkpath EXP.label{s_idx}]);
end

num_track = size(gtInfo.X,2);


for i=1:num_frame
    box = [(gtInfo.X(i,:)-gtInfo.W(i,:)/2)',(gtInfo.Y(i,:)-gtInfo.H(i,:))',(gtInfo.X(i,:)+gtInfo.W(i,:)/2)',gtInfo.Y(i,:)',gtInfo.X(i,:)'*0];
    box_feature =[];
    box_f7=[];
    seg=gtInfo.Segment(i,:);
    cost = log((1-(box(:,5)*0+0.99))./(box(:,5)*0+0.99));
    num_box = size(box,1);
    ind = 1:num_box;
    index = gtInfo(1).frameNums(i);
    fprintf('Computing box unary cost for frame %d.\n', index);
    U{index} = box;
    U_cost{index} = cost;
    U_list{index} = ind;
    U_frame{index} = repmat(i,num_track,1);
    U_lsda_score{index} = box_feature;
    F7{index} = box_f7;
    Segment{index} = seg';
    
end
num_node = length(cat(1,U_cost{:}));
node_per_frame = cellfun(@length,U_cost);
node_seperation = [0; cumsum(node_per_frame)]; % node idx starting from 0
node2frame = [node_seperation(1:end-1),node_seperation(2:end)-1]; % node idx starting from 0
assert(num_node == node2frame(end,end)+1);
frame2node = cat(1,U_frame{:});
save([checkpath EXP.label{s_idx} '/costs_box_vertices.mat'], 'num_node','node2frame','frame2node','U','U_cost','U_list','U_lsda_score','F7','Segment','-v7.3');
save([EXP.output_dir 'costs_box_vertices.mat'], 'num_node','node2frame','frame2node','U','U_cost','U_list','U_lsda_score','F7','Segment','-v7.3');

EXP.num_node = num_node;
EXP.node2frame = node2frame;
EXP.frame2node = frame2node;
EXP.U = U;
EXP.U_cost = U_cost ;
EXP.U_list = U_list;
EXP.U_lsda_score = U_lsda_score;
EXP.F7 = F7;
EXP.Segment = Segment;
end