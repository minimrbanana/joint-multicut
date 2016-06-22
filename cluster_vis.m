function  cluster_vis(EXP, s_idx)
% visualize and save the results
if strcmp(EXP.ImgSaveMode,'none')
    return;
end

if EXP.add_traj==0 && EXP.add_box==1
    load([EXP.output_dir 'clusters.mat']);
    U = EXP.U;
end
if EXP.add_box==0 && EXP.add_traj==1
    load([EXP.output_dir 'clusters_t.mat']);
end
if EXP.add_box==1 && EXP.add_traj==1
    load([EXP.output_dir 'clusters_c.mat']);
end

load([EXP.output_dir 'optimization_result.mat']);
vis_dir = [EXP.output_dir 'cluster_vis'];
if exist(vis_dir, 'dir') == 0
    mkdir(vis_dir);
end


if EXP.add_traj==0 && EXP.add_box==1
    num_cluster = length(clusters);
    track_colors = get_track_colors(num_cluster, 1);

    num_frames = length(U);
    im_dir = [EXP.im_dir  EXP.label{s_idx} '/'];
    if EXP.istest==1
        im_list = dir([im_dir '*.ppm']);
    else
        im_list = dir([im_dir '*.jpg']);
    end
    
    figidx = EXP.idx;
    switch EXP.ImgSaveMode
        case 'all'
            for imgidx = 1: num_frames
                comp_cluster_vis_helper(im_dir , im_list,clusters, cluster_frames,  track_colors, imgidx, vis_dir,clusters_node_id,figidx,EXP);
            end
        case 'sparse'
            for imgidx = 1:round(num_frames/10):num_frames
                comp_cluster_vis_helper(im_dir , im_list,clusters, cluster_frames,  track_colors, imgidx, vis_dir,clusters_node_id,figidx,EXP);
            end
    end
end


if EXP.add_box==0 && EXP.add_traj==1
    num_cluster = length(clusters_t);
    track_colors = get_track_colors(num_cluster, 1);

    num_frames = EXP.num_frame;
    im_dir = [EXP.im_dir  EXP.label{s_idx} '/'];
    im_list = dir([im_dir '*.ppm']);
    figidx = EXP.idx;
    switch EXP.ImgSaveMode
        case 'all'
            for imgidx = 1: num_frames
                comp_cluster_vis_traj(im_dir , im_list,clusters_t, cluster_frames_t,  track_colors, imgidx, vis_dir,clusters_node_id_t,figidx,EXP);
            end
        case 'sparse'
            for imgidx = 1:round(num_frames/10):num_frames
                comp_cluster_vis_traj(im_dir , im_list,clusters_t, cluster_frames_t,  track_colors, imgidx, vis_dir,clusters_node_id_t,figidx,EXP);
            end
    end
end


if EXP.add_box==1 && EXP.add_traj==1
    num_cluster = max(length(clusters_t),length(clusters));
    track_colors = get_track_colors(num_cluster, 1);
    num_frames = EXP.num_frame;
    im_dir = [EXP.im_dir  EXP.label{s_idx} '/'];
    im_list = dir([im_dir '*.ppm']);
    figidx = EXP.idx;
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
    GMModels=[];
    if strcmp(EXP.JointChoice,'color')
        temp = load([checkpath EXP.label{s_idx} '/GMModel.mat']);
        GMModels = temp.GMModels;
    end
    segment = EXP.Segment;
    segsum = 0;
    if size(segment,1)>0
        for i=1:size(segment,1)
            segnum = size(segment{i,1},1);
            segment{i,2}= (1:segnum) +segsum;
            segsum = segsum+segnum;
        end
    else
        segment{:,2}=[];
    end
    switch EXP.ImgSaveMode
        case 'all'
            for imgidx = 1: num_frames
                comp_cluster_vis_comb(im_dir , im_list,clusters, cluster_frames,  track_colors, imgidx, vis_dir,clusters_node_id,clusters_t, cluster_frames_t,clusters_node_id_t,figidx,GMModels,segment,EXP);
            end
        case 'sparse'
            for imgidx = 1:round(num_frames/10):num_frames
                comp_cluster_vis_comb(im_dir , im_list,clusters, cluster_frames,  track_colors, imgidx, vis_dir,clusters_node_id,clusters_t, cluster_frames_t,clusters_node_id_t,figidx,GMModels,segment,EXP);
            end
    end
end

end

function comp_cluster_vis_helper(im_dir, img_list, clusters, cluster_frames,  track_colors, aidx, vis_dir, clusters_node_id,figidx,EXP)

vidx_name = {'r', 'rb', 'b', 'lb', ...
    'l', 'lf', 'f', 'rf'};

text_x_offset = 10;
text_y_offset = 30;

score_x_offset = 0;
score_y_offset = -15;

%figidx = 1;
h = figure(figidx);
%h = figure('visiable', 'off');
set(h,'Visible','off');

clf;

tracklet_length = 1;

% I = imread(EXP_PARAM.gt_annolist(aidx).image.name);
I = imread([im_dir img_list(aidx).name]);
imshow(I);
%imagesc(I); axis equal;
hold on;

for tidx = 1:length(clusters)
    
    fidx_list = cluster_frames{tidx}(:,ceil(tracklet_length/2));
    
    
    if any(fidx_list == aidx)
        %     if aidx >= firstidx && aidx <= lastidx
        
        %         fidx = aidx - firstidx + 1;
        bbox_idx_list = find(fidx_list == aidx);
        
        fidx = aidx;
        
        tmp_tracks = clusters{tidx}(bbox_idx_list);
        tmp_tracks_id = clusters_node_id{tidx}(bbox_idx_list);
        
        %         tracks_velocity = compute_tracks_velocity(tmp_tracks, 1);
        
        
        for k = 1: length(bbox_idx_list)
            bbox_idx = bbox_idx_list(k);
            
            det = double(clusters{tidx}(bbox_idx,:));
            rect_x1 = max(det(1), 1);
            rect_y1 = max(det(2), 1);
            
            rect_x2 = min(det(3), size(I, 2));
            rect_y2 = min(det(4), size(I, 1));
            
            rect_width = rect_x2 - rect_x1;
            rect_height = rect_y2 - rect_y1;
            
            %             velocity = tracks_velocity(k,:);
            %             if track_double_idx(tmp_tracks_id(k)) ==0
            rectangle('Position', [rect_x1, rect_y1, rect_width, rect_height], ...
                'EdgeColor', track_colors(tidx, :), 'LineWidth', 1.5);
            %             else
            %                 rectangle('Position', [rect_x1, rect_y1, rect_width, rect_height], ...
            %                     'EdgeColor', track_colors(tidx, :), 'LineWidth', 2,'LineStyle','--');
            %             end
            
            %             x0 = clusters{tidx}{bbox_idx}(d_idx).ox;
            %             y0 = clusters{tidx}{bbox_idx}(d_idx).y2;
            %             x1 = x0 + velocity(1)*rect_height*10;
            %             y1 = y0 + velocity(2)*rect_height*10;
            % %             line([x0 x1 ],[y0 y1 ],'Color', track_colors(tidx, :), 'LineWidth', 2)
            %
            text(rect_x1 + text_x_offset, rect_y1 + text_y_offset, ...
                num2str(tidx), 'FontSize', 10, 'Color', track_colors(tidx, :));
            
            %             % unary score
            %             bbox_unary = clusters_unary{tidx}(bbox_idx);
            %             text(rect_x1 + score_x_offset, rect_y1 + score_y_offset, ...
            %                 ['U:' num2str(bbox_unary)], 'FontSize', 20, 'Color', track_colors(tidx, :));
        end
        
    end
end

vis_name = [vis_dir '/imgidx' padZeros(num2str(aidx), 4) '.png'];
fprintf('saving %s\n', vis_name);

set(gca, 'visible', 'off', 'position', [0, 0, 1, 1]);
% set(gcf, 'position', [100, 100, size(I, 2), size(I, 1)]);

print(['-f' num2str(figidx)], '-dpng', '-r200', vis_name);

% pause;
end

function comp_cluster_vis_traj(im_dir, img_list, clusters, cluster_frames,  track_colors, aidx, vis_dir, clusters_node_id,figidx,EXP)

vidx_name = {'r', 'rb', 'b', 'lb', ...
    'l', 'lf', 'f', 'rf'};

text_x_offset = 10;
text_y_offset = 30;

score_x_offset = 0;
score_y_offset = -15;

%figidx = 1;
h = figure(figidx);
set(h,'Visible','off');

clf;

tracklet_length = 1;

% I = imread(EXP_PARAM.gt_annolist(aidx).image.name);
I = imread([im_dir img_list(aidx).name]);
I = 255*ones(size(I));
imshow(I);
%imagesc(I); axis equal;
hold on;

for tidx = 1:length(clusters)
    temp = cluster_frames{tidx};
    if size(temp,1)>0
        flow_list = cat(1,temp{:});
    else
        flow_list = [];
    end
    if size(flow_list,1)>0
        fidx_list = flow_list(:,3)+1;  
    
    
    if any(fidx_list == aidx)
        %     if aidx >= firstidx && aidx <= lastidx
        
        %         fidx = aidx - firstidx + 1;
        bbox_idx_list = find(fidx_list == aidx);
       
               
        for k = 1: length(bbox_idx_list)
            bbox_idx = bbox_idx_list(k);
            
            dot = flow_list(bbox_idx,1:2);

            %plot(dot(1),dot(2),'.','color',track_colors(tidx, :));
            plot(dot(1),dot(2),'s','color',track_colors(tidx, :),'MarkerFaceColor',track_colors(tidx, :),'MarkerSize',5);
               
        end
        
    end
    end
end

vis_name = [vis_dir '/imgidx' padZeros(num2str(aidx), 4) '.png'];
fprintf('saving %s\n', vis_name);

set(gca, 'visible', 'off', 'position', [0, 0, 1, 1]);
% set(gcf, 'position', [100, 100, size(I, 2), size(I, 1)]);

print(['-f' num2str(figidx)], '-dpng', '-r200', vis_name);

% pause;
end

function comp_cluster_vis_comb(im_dir, img_list, clusters, cluster_frames,  track_colors, aidx, vis_dir, clusters_node_id,clusters_t, cluster_frames_t,clusters_node_id_t,figidx,GMModels,segment,EXP)

text_x_offset = 10;
text_y_offset = 20;

h = figure(figidx);
set(h,'Visible','off');
%figure(figidx);
clf;

I = imread([im_dir img_list(aidx).name]);
I = 256*ones(size(I));
subplot('Position',[0,0.3,1,0.7]),
imshow(I);
hold on;

%different color for box
color4box = rgb2hsv(track_colors);
color4box(:,3) = color4box(:,3)*0.9;
color4box = hsv2rgb(color4box);


%traj plot
for tidx = 1:length(clusters_t)
    temp = cluster_frames_t{tidx};
    if size(temp,1)>0
        flow_list = cat(1,temp{:});
    else
        flow_list = [];
    end
    if size(flow_list,1)>0
        fidx_list = flow_list(:,3)+1;   
        if any(fidx_list == aidx)
            bbox_idx_list = find(fidx_list == aidx);

            textlabel=0;
            for k = 1: length(bbox_idx_list)
                bbox_idx = bbox_idx_list(k);

                dot = flow_list(bbox_idx,1:2);

                plot(dot(1),dot(2),'s','color',track_colors(tidx, :),'MarkerFaceColor',track_colors(tidx, :),'MarkerSize',5);
                if textlabel==0
                    textlabel=1;
                end
            end

        end
    end
end
hold on;
%box plot
for tidx = 1:length(clusters)
    
    fidx_list = cluster_frames{tidx}(:);
    if size(fidx_list,1)>0
    
        if any(fidx_list == aidx)
            bbox_idx_list = find(fidx_list == aidx);

            isnumberplot=0;
            for k = 1: length(bbox_idx_list)
                bbox_idx = bbox_idx_list(k);

                det = double(clusters{tidx}(bbox_idx,:));
                rect_x1 = max(det(1), 1);
                rect_y1 = max(det(2), 1);

                rect_x2 = min(det(3), size(I, 2));
                rect_y2 = min(det(4), size(I, 1));

                rect_width = rect_x2 - rect_x1;
                rect_height = rect_y2 - rect_y1;

                rectangle('Position', [rect_x1, rect_y1, rect_width, rect_height], ...
                    'EdgeColor', color4box(tidx, :), 'LineWidth', 0.9);
                if isnumberplot==0
                    text(rect_x1 + text_x_offset, rect_y1 + text_y_offset, ...
                        num2str(tidx), 'FontSize', 20, 'Color', color4box(tidx, :));
                    isnumberplot=1;
                end
            end
        end
    end
end
hold on;
%segment plot
if size(segment{aidx,1},1)>0
    for i=1:size(segment{aidx,1},1)
        segIm = imresize(segment{aidx,1}{i,1},[size(I,1),size(I,2)]);
        if strcmp(EXP.JointChoice,'color')
            GMM = GMModels{1,segment{aidx,2}(i)};
            [w,w_index] = max(GMM.ComponentProportion);
            mu = GMM.mu(w_index,:);
            I(:,:,1) = double(segIm * mu(1))+(segIm~=1)*100;
            I(:,:,2) = double(segIm * mu(2));%*256+(~segIm)*256;
            I(:,:,3) = double(segIm * mu(3));%*256+(~segIm)*256;
            rgbIm = lab2rgb(I,'OutputType','uint8');
        else
            rgbIm = segIm*255;
        end
        hold on;
        if i<6
            subplot('Position',[0.2*(i-1),0.15,0.2,0.15]),
            imshow(rgbIm);
        else
            subplot('Position',[0.2*(i-6),0,0.2,0.15]),
            imshow(rgbIm);
        end
    end
end

vis_name = [vis_dir '/imgidx' padZeros(num2str(aidx), 4) '.png'];
fprintf('saving %s\n', vis_name);

%set(gca, 'visible', 'off', 'position', [0, 0, 1, 1]);
%print(gcf,['-f' num2str(figidx)], '-dpng', '-r200', vis_name);
print(h,'-dpng', vis_name);
end

