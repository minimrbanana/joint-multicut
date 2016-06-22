function EXP = exp_detail(exp_idx)
%
% Save the details of each experiment here
%
addpath /home/tang/code/anno_code/annotation/;
addpath /home/tang/code/anno_code/;

%% info for FBMS training data
load ('/BS/joint-multicut/work/Tracking_result/Para/Ftrain_label.mat');
EXP.label =  Ftrain_label;
EXP.im_dir = '/BS/joint-multicut/work/FBMS59/Trainingset/';
EXP.BoxDir_color = '/BS/joint-multicut/work/DetectionRes/Ftrain_LC/';
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
        
    case 1 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'all';

    case 2 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 0;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';      

    case 3 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.7;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';   
        
    case 4 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.boxpairWeight = 0.1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation'; 

    case 5 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 6 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 7 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.3;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 8 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.4;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';   
        
    case 9 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';      
        EXP.ImgSaveMode = 'sparse';  
        
    case 10 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.5;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse'; 
        
    case 11 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.5;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 12 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';
        
    case 13 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.7;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 14 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';
        
    case 15 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';       
        
    case 16 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.3;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 17 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.3;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';
        
    case 18 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.9;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.3;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';
        
    case 19 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.9;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.3;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';
        
    case 20 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 21 %zhongjie
        EXP.istest = 1;
        EXP.add_traj = 0;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 22 %zhongjie
        %EXP.istest = 1;
        EXP.add_traj = 0;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1,5];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';
        
    case 23 %zhongjie 
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0.5;
        EXP.segGaussSmooth = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';       
        
    case 24 %zhongjie 
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0.5;
        EXP.segGaussSmooth = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';  
        
    case 25 %zhongjie 
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0;
        EXP.segGaussSmooth = 0;
        EXP.isDeepMask = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';
        
    case 26 %zhongjie 
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0;
        EXP.segGaussSmooth = 0;
        EXP.isDeepMask = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';  
     
    case 27 %zhongjie 
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0;
        EXP.segGaussSmooth = 0;
        EXP.isDeepMask = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';   
        
    case 28 %zhongjie 
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0;
        EXP.segGaussSmooth = 0;
        EXP.isDeepMask = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';   

    case 29 %zhongjie 
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0.5;
        EXP.segGaussSmooth = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse'; 
        
    case 30 %zhongjie 
        EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0.5;
        EXP.segGaussSmooth = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'color';
        EXP.ImgSaveMode = 'sparse';   
        
    case 31 %zhongjie 
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0;
        EXP.segGaussSmooth = 0;
        EXP.isDeepMask = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.95;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';      
        
    case 32 %zhongjie 
        %EXP.istest = 1;
        EXP.add_traj = 1;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 1;
        EXP.box_rank_num = 10;
        EXP.box_NMS = 1;
        EXP.segarearatio = 0;
        EXP.segGaussSmooth = 0;
        EXP.isDeepMask = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.useColor =1;
        EXP.boxpairWeight = 0.2;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation';
        EXP.ImgSaveMode = 'sparse';    
        
    case 33 %test for saving h5 files
        EXP.add_traj = 0;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 4;
        EXP.box_rank_num = 5;
        EXP.box_NMS = 0.9;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
        EXP.sampling = 1;
        EXP.L_dimension = 256;
        EXP.segment_prob = 0.8;
        EXP.boxpairWeight = 0.1;      
        EXP.color_sigma = 2;
        EXP.colorWeight = 0.8; 
        EXP.reduce_boxpair_negative = 1;
        EXP.Iou4segment = 0;
        EXP.JointChoice = 'segmentation'; 
        EXP.save_color_model =1;
        
    case 36 %test GT tracking
        EXP.GTtracking = 1;
        EXP.add_traj = 0;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 0;
        EXP.box_rank_num = 1;
        EXP.box_NMS = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
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

    case 37 %main box graph
        %EXP.GTtracking = 1;
        EXP.add_traj = 0;
        EXP.add_box = 1;       
        
        EXP.box_score_min = 0;
        EXP.box_rank_num = 20;
        EXP.box_NMS = 1;
        EXP.temporal_thr = [0,1];
        
        EXP.solver = 'KL';    
        EXP.pairwise = 'Iapp';
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
    EXP.BoxDir_color = '/BS/joint-multicut/work/DetectionRes/Ftest_LC/';
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