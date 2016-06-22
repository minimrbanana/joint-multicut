function EXP = fasterRCNN_deeplab_compute_box_unary_cost(EXP,s_idx,box_color_dir,box_flow_dir,box_color_seg_dir,box_flow_seg_dir)
%
% compute boxes unary cost;
%
try 
    load([EXP.output_dir  'costs_box_vertices.mat']);
catch
    checkdir = '/BS/joint-multicut-2/work/Tracking_result/UnaryBox/';
    switch EXP.istest
        case 1
            T_label = 'Test_';
        case 0
            T_label = 'Train_';
    end
    if EXP.isDeepMask == 0
        checkfolder = ['FRCNN_' T_label 'score_' int2str(EXP.box_score_min) '_rank_' int2str(EXP.box_rank_num) '_nms_' num2str(EXP.box_NMS) '/'];
    else
        checkfolder = ['FRCNN_' T_label 'score_' int2str(EXP.box_score_min) '_rank_' int2str(EXP.box_rank_num) '_DeepMask_1/'];
    end
    checkpath = [checkdir checkfolder];
    try
        load([checkpath EXP.label{s_idx} '/costs_box_vertices.mat']);
        save([EXP.output_dir 'costs_box_vertices.mat'], 'num_node','node2frame','frame2node','U','U_cost','U_list','U_lsda_score','F7','Segment','-v7.3');
    catch
        if ~exist([checkpath EXP.label{s_idx}],'dir')
            mkdir([checkpath EXP.label{s_idx}]);
        end
        %% detection dir
        color_mat_list = dir([box_color_dir '*.mat']);
        flow_mat_list = dir([box_flow_dir '*.mat']);
        color_seg_list = dir([box_color_seg_dir '*.mat']);
        flow_seg_list = dir([box_flow_seg_dir '*.mat']);
        num_frame = length(color_mat_list);


        %% para init
        U = cell(num_frame,1);
        U_cost = cell(num_frame,1);
        U_list = cell(num_frame,1);
        U_frame = cell(num_frame,1);
        U_lsda_score = cell(num_frame,1);
        F7 = cell(num_frame,1);%store f7 feature for metric learning
        Segment = cell(num_frame,1);
        %% compute unary cost
        for i = 1:num_frame
            fprintf('Computing box unary cost for frame %d.\n', i);

            % load detections and segmentations
            load([box_color_dir color_mat_list(i).name]); cbox = Boxes2save(:,1:4); cbox_score = Boxes2save(:,5); cbox_feature = []; cbox_f7 = [];
            load([box_color_seg_dir color_seg_list(i).name]); cseg = segment;
            if i ~= num_frame
                 fbox = []; fbox_score = []; fbox_feature = []; fbox_f7 = [];
                 fseg = [];
            end
            box = [cbox cbox_score ; fbox fbox_score]; num_box = size(box,1);
            box_feature = [cbox_feature; fbox_feature];
            box_f7 = [cbox_f7; fbox_f7];
            seg = [cseg'; fseg];

            % filter and compute the cost
            if ~isempty(box)
                if EXP.isDeepMask == 1
                    [rank, ind] = sort(box(:,5),'descend');
                    ind = ind(1:20);
                    box = box(ind,:);
                    box_feature = box_feature(ind,:);
                    box_f7 = box_f7(ind,:);
                    if EXP.istest == 1
                        stemp='test';
                    else
                        stemp='train';
                    end
                    stemp2=sprintf('_%.4d',i);
                    load(['/BS/joint-multicut/work/DetectionRes/F' stemp '_DeepMask_S/' EXP.label{s_idx} '/' EXP.label{s_idx} stemp2 '.mat']);
                    seg = segment;
                end


                % selected detection;
                % rank
                % cost

                cost = -box(:,5)*2+6;

                % save
                U{i} = box;
                U_cost{i} = cost;
                U_list{i} = 1:num_box;
                U_frame{i} = repmat(i,num_box,1);
                U_lsda_score{i} = box_feature;
                F7{i} = box_f7;
                Segment{i} = seg;
            end
        end
        %% node frame relations
        num_node = length(cat(1,U_cost{:}));
        node_per_frame = cellfun(@length,U_cost);
        node_seperation = [0; cumsum(node_per_frame)]; % node idx starting from 0
        node2frame = [node_seperation(1:end-1),node_seperation(2:end)-1]; % node idx starting from 0
        assert(num_node == node2frame(end,end)+1);
        frame2node = cat(1,U_frame{:});
        save([checkpath EXP.label{s_idx} '/costs_box_vertices.mat'], 'num_node','node2frame','frame2node','U','U_cost','U_list','U_lsda_score','F7','Segment','-v7.3');
        save([EXP.output_dir 'costs_box_vertices.mat'], 'num_node','node2frame','frame2node','U','U_cost','U_list','U_lsda_score','F7','Segment','-v7.3');
    end
end
%% output
EXP.num_node = num_node;
EXP.node2frame = node2frame;
EXP.frame2node = frame2node;
EXP.U = U;
EXP.U_cost = U_cost ;
EXP.U_list = U_list;
EXP.U_lsda_score = U_lsda_score;
EXP.F7 = F7;
EXP.Segment = Segment;
%% visualize
%visualize_unary(EXP,s_idx);
end

function visualize_unary(EXP,s_idx)
%
im_dir = [EXP.im_dir  EXP.label{s_idx} '/'];
im_list = dir([im_dir '*.jpg']);
figure; hold on;
for i =1:length(im_list)
    imshow(imread([im_dir im_list(i).name]));
    box = double(EXP.U{i});
    cost = double(EXP.U_cost{i});
    if ~isempty(box)
        for b = 1:size(box,1)
            rec = box(b,:);
            rectangle('Position', [rec(1), rec(2), rec(3)- rec(1), rec(4) -  rec(2)],  'EdgeColor', 'b', 'LineWidth', 5);
            text(rec(1), rec(2)+(rec(4) -  rec(2))/5, num2str(cost(b)), 'FontSize', 20, 'Color', 'b');
        end
    end
end
end

