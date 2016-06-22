function [EXP, costs_box_vertices, box_edges, cost_box_edges, boxes] = read_box(EXP,s_idx)
% Read boxes information -edges, costs, coordinates

%% load info
% at present labels are not used
%temp = load('/BS/joint-multicut/work/Tracking_result/Para/label.mat');  %label from lsda
%labels = temp.temp;
if EXP.GTtracking ==0 
    box_color_dir = [EXP.BoxDir_color  EXP.label{s_idx} '/'];
    box_color_seg_dir = [EXP.BoxDir_color(1:end-3) 'SC/' EXP.label{s_idx} '/'];
    box_flow_dir = [EXP.BoxDir_flow EXP.label{s_idx} '/'];
    box_flow_seg_dir = [EXP.BoxDir_flow(1:end-3) 'SF/' EXP.label{s_idx} '/'];


    %% compute box unary cost
    % with rank top 5 above 4
    EXP = compute_box_unary_cost(EXP,s_idx,box_color_dir,box_flow_dir,box_color_seg_dir,box_flow_seg_dir);

    % compute_color_model(EXP,s_idx);

    costs_box_vertices = double(cat(1,EXP.U_cost{:}));
    boxes =  double([cat(1,EXP.U{:}) EXP.frame2node]);
    %% compute box pairwise cost
    EXP = compute_box_pairwise_cost(EXP,s_idx);

    [cost_box_edges, box_edges] = cost2pair(EXP);
    if EXP.box_pair_choice == 0
        cost_box_edges = zeros(size(cost_box_edges));
    end
% generate V, E, and costs for boxex
% [ costs_box_vertices, box_edges, cost_box_edges, box_center, boxes] = mat2box( matdir, labels);
end
if EXP.GTtracking == 1 % for ground truth tracking
    if ~EXP.istest
        gtpath = '/BS/siyu-project/work/MulticutMotionTracking/dataset/Ftrain/gtSeg/';
    else
        gtpath = '/BS/siyu-project/work/MulticutMotionTracking/dataset/FBMS59GT/GT';
    end
    gtInfo = load([gtpath EXP.label{s_idx} '/gt.mat']);
    gtInfo = gtInfo.gtInfo;
    num_track = size(gtInfo.X,2);    
%     if num_track==1
%         EXP = compute_gt_unary_cost(EXP,gtInfo,s_idx);
%         costs_box_vertices = double(cat(1,EXP.U_cost{:}));
%         boxes =  double([cat(1,EXP.U{:}) EXP.frame2node]);
%         box_edges = uint64(nchoosek(EXP.frame2node,2)-1);
%         cost_box_edges = ones(size(box_edges,1),1)*(log((1-0.99)/0.99));
%     end
    if num_track>0
        EXP = compute_gt_unary_cost(EXP,gtInfo,s_idx);
        Box=[];
        Index = [];
        count = 0;
        for i=1:num_track
            box = [(gtInfo.X(:,i)-gtInfo.W(:,i)/2),(gtInfo.Y(:,i)-gtInfo.H(:,i)),(gtInfo.X(:,i)+gtInfo.W(:,i)/2),gtInfo.Y(:,i),gtInfo.X(:,i)*0+i,gtInfo.frameNums'];
            box(box(:,4)==0,:)=[];
            index = ((1:size(box,1))+count)';
            count = count+size(box,1);
            Box=[Box;box];
            Index=[Index;index];
        end
        listtrack=Box(:,5);
        box_edges=[];
        cost_box_edges=[];
        leftIndex = Index;
        leftlist = listtrack;
        for i=1:num_track
            cur_track = Index(listtrack==i);
            leftIndex(leftlist==i)=[];
            leftlist(leftlist==i)=[];
            not_track = leftIndex;
            cur_box_edges1 = nchoosek(cur_track,2);
            if size(cur_box_edges1,2)==1
                cur_box_edges1=[];
                cost_box_edges1=[];
            else
                cost_box_edges1 = ones(size(cur_box_edges1,1),1)*(-log((1-0.99)/0.99));
            end
            cur_box_edges2 = combvec(cur_track',not_track')';
            if size(cur_box_edges2,2)==1
                cur_box_edges2=[];
                cost_box_edges2=[];
            else
                cost_box_edges2 = ones(size(cur_box_edges2,1),1)*(+log((1-0.99)/0.99));
            end
            box_edges=[box_edges; cur_box_edges1; cur_box_edges2];
            cost_box_edges=[cost_box_edges; cost_box_edges1; cost_box_edges2];
        end
        box_edges = uint64(box_edges-1);
        %cost_box_edges = cost_box_edges*(log((1-0.99)/0.99));
        boxes = [Box ];
        costs_box_vertices = zeros(size(Box,1),1)+(log((1-0.99)/0.99));
    end
    %[cost_box_edges, box_edges] = cost2pair(EXP);
end
end