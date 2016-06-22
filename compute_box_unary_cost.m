function EXP = compute_box_unary_cost(EXP,s_idx,box_color_dir,box_flow_dir,box_color_seg_dir,box_flow_seg_dir)
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
        checkfolder = [T_label 'score_' int2str(EXP.box_score_min) '_rank_' int2str(EXP.box_rank_num) '_nms_' num2str(EXP.box_NMS) '/'];
    else
        checkfolder = [T_label 'score_' int2str(EXP.box_score_min) '_rank_' int2str(EXP.box_rank_num) '_DeepMask_1/'];
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
            load([box_color_dir color_mat_list(i).name]); cbox = boxes; cbox_score = max(scores,[],2); cbox_feature = scores; cbox_f7 = f7;
            load([box_color_seg_dir color_seg_list(i).name]); cseg = segment;
            if i ~= num_frame
                load([box_flow_dir flow_mat_list(i).name]);   fbox = boxes; fbox_score = max(scores,[],2); fbox_feature = scores; fbox_f7 = f7;
                load([box_flow_seg_dir flow_seg_list(i).name]); fseg = segment;
            end
            box = [cbox cbox_score ; fbox fbox_score]; num_box = size(box,1);
            box_feature = [cbox_feature; fbox_feature];
            box_f7 = [cbox_f7; fbox_f7];
            seg = [cseg; fseg];

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
                list_min_score = find(box(:,5) > EXP.box_score_min);

                if EXP.box_NMS ~= 0
                    list_nms = nms(box, EXP.box_NMS);
                else
                    list_nms = 1:num_box;
                end

                % selected detection;
                list = intersect(list_nms, list_min_score);
                box = box(list,:);
                box_feature = box_feature(list,:);
                box_f7 = box_f7(list,:);
                seg = seg(list,:);
                segarea = cellfun(@sum,seg,'UniformOutput', false);
                segarea = cellfun(@sum,segarea,'UniformOutput', false);
                segarea = cell2mat(segarea);
                if ~isempty(list)
                    segarea = segarea./((box(:,3)-box(:,1)).*(box(:,4)-box(:,2)));
                else
                    segarea = [];
                end
                box = box(segarea>EXP.segarearatio,:);
                list = list(segarea>EXP.segarearatio,:);
                box_feature = box_feature(segarea>EXP.segarearatio,:);
                box_f7 = box_f7(segarea>EXP.segarearatio,:);
                seg = seg(segarea>EXP.segarearatio,:);
                if EXP.segGaussSmooth==1
                    seg = cellfun(@(x) x*255, seg,'UniformOutput', false);
                    f = cell(size(seg,1),1);
                    f(:,1) = {fspecial('gaussian',[3 3],10)};
                    seg = cellfun(@imfilter, seg,f,'UniformOutput', false);
                    seg = cellfun(@(x) x>127,seg,'UniformOutput', false);
                end
                % rank
                if EXP.box_rank_num<size(list,1)
                    [rank, ind] = sort(box(:,5),'descend');
                    ind = ind(1:EXP.box_rank_num);
                    box = box(ind,:);
                    box_feature = box_feature(ind,:);
                    box_f7 = box_f7(ind,:);
                    seg = seg(ind,:);
                    num_box = size(box,1);
                else
                    [rank, ind] = sort(box(:,5),'descend');
                    ind = ind(1:length(ind));
                    box = box(ind,:);
                    box_feature = box_feature(ind,:);
                    box_f7 = box_f7(ind,:);
                    seg = seg(ind,:);
                    num_box = size(box,1);
                end
                % cost

                cost = -box(:,5)*2+6;

                % save
                U{i} = box;
                U_cost{i} = cost;
                U_list{i} = ind;
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

