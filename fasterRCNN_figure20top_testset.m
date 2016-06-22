%% draw the figures with top 20 detections and their segmentations
function fasterRCNN_figure20top_testset(eidx)
% The main function for tracking by motion segmentation
clear EXP;

%% parameters init.
EXP = fasterRCNN_deeplab_exp_detail(eidx);
EXP.exp_output_dir = ['/BS/joint-multicut-2/work/Tracking_result/'  'EXP_idx_' num2str(EXP.idx) '/Train/'];

%% test set
EXP.istest =1;
load ('/BS/joint-multicut/work/Tracking_result/Para/Ftest_label.mat');
EXP.label =  Ftest_label;
EXP.im_dir = '/BS/joint-multicut/work/FBMS59/Testset/';
EXP.BoxDir_color = '/BS/joint-multicut-2/work/FBMS-fasterRCNN/Testset02/';
EXP.BoxDir_flow = '/BS/joint-multicut/work/DetectionRes/Ftest_LF/';
EXP.TrajDir = '/BS/joint-multicut/work/FBMS59/Testset/';

EXP.exp_output_dir = ['/BS/joint-multicut-2/work/Tracking_result/'  'EXP_idx_' num2str(EXP.idx) '/Test/'];

num_seq = length(EXP.label);
h = figure(eidx);
for s = 1:num_seq
    %% sequence-dependent output
    s_name = EXP.label{s};

        %% read h5
    
    problem_file = [EXP.exp_output_dir  s_name '/' s_name '_problem.h5'];
    
    boxes = marray_load(problem_file,'boxes');
    segments = marray_load(problem_file,'segments');
    %mu = marray_load(problem_file,'mu');
    fprintf('H5 file read ... \n');
    % to plot the figures
    imlist = dir([EXP.im_dir s_name '/*.ppm']);
    %%
    for i=1:boxes(end,6)
        img = imread([EXP.im_dir s_name '/' imlist(i).name]);
        
        set(h,'Visible','off');
        clf;
        subplot('Position',[0,0.3,1,0.7]),
        imshow(img);
        hold on;
        box_list = find(boxes(:,6)==i);
        numDetection = min(size(box_list,1),20);%plot the first 20 boxes and segments
        box_list = box_list(1:numDetection);
        box20 = boxes(box_list,:);
        seg20 = segments(:,:,box_list);
        for i_box = 1:numDetection
            rect_x1 = box20(i_box,1);
            rect_y1 = box20(i_box,2);
            rect_width = box20(i_box,3) - box20(i_box,1);
            rect_height = box20(i_box,4) - box20(i_box,2);
            rectangle('Position', [rect_x1, rect_y1, rect_width, rect_height], ...
                    'EdgeColor', 'r', 'LineWidth', 0.3);
            text(rect_x1 - 8, rect_y1 - 4, ...
                        num2str(i_box), 'FontSize', 6, 'Color', 'k');
        end
        for i_seg = 1:numDetection
            segment = seg20(:,:,i_seg);
            if i_seg<=10
                subplot('Position',[0.1*(i_seg-1),0.15,0.1,0.15]),
                imshow(~segment);
            else
                subplot('Position',[0.1*(i_seg-11),0,0.1,0.15]),
                imshow(~segment);
            end
        end
        vis_name = [EXP.exp_output_dir s_name '/img/' imlist(i).name(1:end-3) 'png'];
        if ~exist([EXP.exp_output_dir s_name '/img/'],'dir')
            mkdir([EXP.exp_output_dir s_name '/img/']);
        end
        fprintf('saving %s\n', vis_name);
        print(h,'-dpng', vis_name);
    end
end
end