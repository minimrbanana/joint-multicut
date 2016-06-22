function [EXP, traj_edges, traj_box_edges, cost_traj_box] = combine_traj_box(trajectories, traj_edges,num_box,num_traj,boxes,EXP,s_idx)
%
% Given bbox graph and trajectory graph, define the new graph and the
% pairwise costs.
%
traj_edges = traj_edges+num_box;
traj_edges = uint64(traj_edges);
sigma=0.7;
cost_traj_box=[];
traj_box_edges=[];
%sort trajectories by frames
%format: for every frame: [traj_id, x_pos. ypos]
traj_frames=cell(1,EXP.num_frame);
fprintf('trajectories projecting on frames...');
for traj_it=1:num_traj
    if(size(trajectories{traj_it,1},1)>2)% here we can filter the traj by length
        for j=1:size(trajectories{traj_it,1},1)
            traj_frames{trajectories{traj_it,1}(j,3)+1}= [traj_frames{trajectories{traj_it,1}(j,3)+1};...
            traj_it, trajectories{traj_it,1}(j,1), trajectories{traj_it,1}(j,2)];
        end
    end
end
disp('done');
switch EXP.JointChoice
    % do we need box-trajectory cost?
%     case 'box'
%         for bbx_it = 1:num_box
%             box_center_x = (boxes(bbx_it,3)+boxes(bbx_it,1))/2;
%             box_center_y = (boxes(bbx_it,4)+boxes(bbx_it,2))/2;
% 
%             for traj_it=1:size(traj_frames{boxes(bbx_it,6)},1)
%                 x_distance = (box_center_x - traj_frames{boxes(bbx_it,6)}(traj_it,2))^2;
%                 y_distance = (box_center_y - traj_frames{boxes(bbx_it,6)}(traj_it,3))^2;
%                 distance = (x_distance+y_distance);
%                 if distance<0.6
%                     traj_bbx_prob = exp(-(x_distance+y_distance)^2/(sigma^2));%join probability
%                 else
%                     if distance<1.5
%                         traj_bbx_prob = 0.5;%join probability
%                     else
%                       traj_bbx_prob = exp(-(x_distance+y_distance)^2/(sigma^2));
%                     end
%                 end
%                 if(traj_bbx_prob)>0.0001
%                     cost_traj_box(end+1)=log(traj_bbx_prob/(1-traj_bbx_prob));
%                     traj_box_edges(end+1,:) = [traj_frames{boxes(bbx_it,6)}(traj_it,1), bbx_it-1];
%                 end
%             end
%         end

    case 'segmentation'
        Segment = cat(1,EXP.Segment{:});
        for bbx_it = 1:num_box
            segment = Segment{bbx_it};
% if bbx_it==368
%     temp=0;
% end
            for traj_it=1:size(traj_frames{boxes(bbx_it,6)},1)
                traj_x = round(traj_frames{boxes(bbx_it,6)}(traj_it,2))+1;
                traj_y = round(traj_frames{boxes(bbx_it,6)}(traj_it,3))+1;


                if segment(traj_y,traj_x)==1
                    traj_bbx_prob = EXP.segment_prob;
                else
                    traj_bbx_prob = 0;
                end
                if(traj_bbx_prob)>0.0001
                    if strcmp(EXP.solver,'ILP')
                        cost_traj_box(end+1)=-log(traj_bbx_prob/(1-traj_bbx_prob));
                    elseif strcmp(EXP.solver,'KL')
                        cost_traj_box(end+1)=log(traj_bbx_prob/(1-traj_bbx_prob));
                    end
                    traj_box_edges(end+1,:) = [traj_frames{boxes(bbx_it,6)}(traj_it,1)+num_box-1, bbx_it-1];
                end
            end
            if mod(bbx_it,100)==0
                fprintf('bounding box %d from %d combined...\n',bbx_it,num_box);
            end
        end
    case 'color'
        checkdir = '/BS/joint-multicut/work/Tracking_result/GMModel/';
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
        %checkfolder = [T_label 'score_' int2str(EXP.box_score_min) '_rank_' int2str(EXP.box_rank_num) '_nms_' num2str(EXP.box_NMS) '/'];
        checkpath = [checkdir checkfolder];
        load([checkpath EXP.label{s_idx} '/GMModel.mat']);
        boxframe = 0;
        im_dir = [EXP.im_dir  EXP.label{s_idx} '/'];
        im_list = dir([im_dir '*.ppm']);
        for bbx_it = 1:num_box
            if(boxframe~=boxes(bbx_it,6))
                boxframe=boxes(bbx_it,6);
                im = imread([im_dir im_list(boxframe).name]);
                im=imfilter(im, fspecial('gaussian',[7,7]));
                im = rgb2lab(im);
                
            end
            GMM = GMModels{1,bbx_it};
                %visualize
%                 figure(10),
%                 imshow(['/BS/joint-multicut/work/FBMS59/Trainingset/bear01/' im_list(1).name]);
%                 box_location = boxes(bbx_it,1:4);
%                 showbox=[box_location(1) box_location(2) box_location(3)-box_location(1) box_location(4)-box_location(2)];
%                 rectangle('Position',showbox);hold on;
                %end visualize
            for traj_it=1:size(traj_frames{boxes(bbx_it,6)},1)
                traj_x = round(traj_frames{boxes(bbx_it,6)}(traj_it,2))+1;
                traj_y = round(traj_frames{boxes(bbx_it,6)}(traj_it,3))+1;
                traj_color = reshape(im(traj_y,traj_x,:),3,1);
                box_location = boxes(bbx_it,1:4);
                if traj_x<box_location(1,3) && traj_x>box_location(1,1) && traj_y>box_location(1,2) && traj_y<box_location(1,4)
                    [w,w_ind] = max(GMM.ComponentProportion);
                    d1=sqrt((traj_color'-GMM.mu(1,:,:))/(GMM.Sigma(:,:,1))*(traj_color-GMM.mu(1,:,:)'));
                    d2=sqrt((traj_color'-GMM.mu(2,:,:))/(GMM.Sigma(:,:,2))*(traj_color-GMM.mu(2,:,:)'));
                    
                    traj_bbx_prob = sqrt((traj_color'-GMM.mu(w_ind,:,:))/(GMM.Sigma(:,:,w_ind))*(traj_color-GMM.mu(w_ind,:,:)'));
                    show1 = traj_bbx_prob;
                    show2 = min(d1,d2);
                    traj_bbx_prob = exp(-traj_bbx_prob^2/(2*EXP.color_sigma^2))*EXP.colorWeight;
                    if traj_bbx_prob>=0.5
                        if strcmp(EXP.solver,'ILP')
                            cost_traj_box(end+1)=-log(traj_bbx_prob/(1-traj_bbx_prob));
                        elseif strcmp(EXP.solver,'KL')
                            cost_traj_box(end+1)=log(traj_bbx_prob/(1-traj_bbx_prob));
                        end
                        %visualize
                        %plot(traj_x,traj_y,'o');
                        %end visualize
                        traj_box_edges(end+1,:) = [traj_frames{boxes(bbx_it,6)}(traj_it,1)+num_box-1, bbx_it-1];
                    end
                end
            end
            if mod(bbx_it,100)==0
                fprintf('bounding box %d from %d combined...\n',bbx_it,num_box);
            end
        end
end
traj_box_edges = uint64(traj_box_edges);
cost_traj_box = cost_traj_box';
disp('trajectory and box combined');
end
