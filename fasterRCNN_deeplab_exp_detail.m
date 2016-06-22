function EXP = fasterRCNN_deeplab_exp_detail(exp_idx)
%
% Save the details of each experiment here with faster rcnn
%
addpath /home/tang/code/anno_code/annotation/;
addpath /home/tang/code/anno_code/;

%% info for FBMS training data
load ('/BS/joint-multicut/work/Tracking_result/Para/Ftrain_label.mat');
EXP.label =  Ftrain_label;
EXP.im_dir = '/BS/joint-multicut/work/FBMS59/Trainingset/';
EXP.BoxDir_color = '/BS/joint-multicut-2/work/FBMS-fasterRCNN/Trainingset02/';
EXP.BoxDir_flow = '/BS/joint-multicut/work/DetectionRes/Ftrain_LF/';
EXP.TrajDir = '/BS/joint-multicut/work/FBMS59/Trainingset/';
EXP.UseColor =0;
%% default parameters
EXP.pairwise = 'IoU';
EXP.L_dimension = 4096;
EXP.useColor =0;
%probability of cluster, from intersection of segmentation and trajectory
EXP.segment_prob = 0.9;
% 0: 0 cost for box pairwised term, 1: original.con
EXP.box_pair_choice = 1;
EXP.must_cut = 0;
EXP.box_rank_num = 2048;
EXP.prior = 0.5;
EXP.sampling = 8;
EXP.istest = 0;
EXP.boxpairWeight = 1;
EXP.colorWeight = 1;
EXP.reduce_boxpair_negative = 0;
EXP.Iou4segment = 0;
EXP.boxpairIoU = 'IoU';% other cases: 'IoUmin','IoUmax'
EXP.JointChoice = 'box';% other cases: 'segmentation', 'color'
EXP.ImgSaveMode = 'all';% other cases: 'sparse', 'none'
EXP.segarearatio = 0; % ratio of segmentation over bbox
EXP.segGaussSmooth = 0; % smooth the segmentation or not
EXP.isDeepMask = 0; % whether use DeepMask seg or not

EXP.GTtracking = 0;
EXP.save_color_model =0;
%% experiment details
EXP.idx = floor(exp_idx);
switch exp_idx      

    case 38 %main box graph
        %EXP.GTtracking = 1;
        EXP.add_traj = 0;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 0;
        EXP.box_rank_num = 20;
        EXP.box_NMS = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'IoU';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.boxpairWeight = 0.1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color'; 
        EXP.save_color_model =1;       
        
end
%% for test set settings
if EXP.istest==1
    load ('/BS/joint-multicut/work/Tracking_result/Para/Ftest_label.mat');
    EXP.label =  Ftest_label;
    EXP.im_dir = '/BS/joint-multicut/work/FBMS59/Testset/';
    EXP.BoxDir_color = '/BS/joint-multicut-2/work/FBMS-fasterRCNN/Testset02/';
    EXP.BoxDir_flow = '/BS/joint-multicut/work/DetectionRes/Ftest_LF/';
    EXP.TrajDir = '/BS/joint-multicut/work/FBMS59/Testset/';
end
%% output dir
EXP.exp_output_dir = ['/BS/joint-multicut-2/work/Tracking_result/'  'EXP_idx_' num2str(EXP.idx) '/'];
if ~exist(EXP.exp_output_dir)
    mkdir(EXP.exp_output_dir);
end
%%
end 