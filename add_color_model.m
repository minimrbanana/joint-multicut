function add_color_model(boxes, EXP,s_idx)
% try load GMModel, if do not exist, build GMModel
try 
    load([EXP.output_dir  'GMModel.mat'])
catch
    checkdir = '/BS/joint-multicut-2/work/FBMS_GMM/';
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
    %checkfolder = [T_label 'score_' int2str(EXP.box_score_min) '_rank_' int2str(EXP.box_rank_num) '_nms_' num2str(EXP.box_NMS) '/'];
    checkpath = [checkdir checkfolder];
    try
        load([checkpath EXP.label{s_idx} '/GMModel.mat']);
    catch
        addpath /home/tang/code/emgm/emgm/;
        if ~exist([checkpath EXP.label{s_idx}],'dir')
            mkdir([checkpath EXP.label{s_idx}]);
        end
        GMModels=cell(1,size(boxes,1));
        im_dir = [EXP.im_dir  EXP.label{s_idx} '/'];
        im_list = dir([im_dir '*.ppm']);
        boxframe=0;
        initFrame = boxes(1,6)-1;
        for i = 1:size(boxes,1)
            if(boxframe~=boxes(i,6))
                boxframe=boxes(i,6);
                seg_n = 1;
                im = imread([im_dir im_list(boxframe-initFrame).name]);
                im=imfilter(im, fspecial('gaussian',[7,7]));
            end

            cur_im = rgb2lab(im);
            seg=[];
            while isempty(seg)
                seg = EXP.Segment{boxframe,1}{seg_n,1};
                seg_n = seg_n+1;
            end
            seg = imresize(seg,[size(cur_im,1),size(cur_im,2)]);
            
            
            feature =  reshape(cur_im, size(cur_im,1)*size(cur_im,2),3);
            seg = reshape(seg, size(cur_im,1)*size(cur_im,2),1);
            feature = feature(seg==1,:);
            if size(feature,1)>3
                GMModel = fitgmdist(feature,2,'Replicates',1,'Options',statset('MaxIter',20,'TolFun',1e-5),'Regularize', 1e-5);
            else
                GMModel = [];
            end
            GMModels{i}=GMModel;
            if i==999
                jjj=1;
            end

        end
        save([checkpath EXP.label{s_idx}  '/GMModel.mat'], 'GMModels');
        save([EXP.output_dir  'GMModel.mat'], 'GMModels');
    end
end
end