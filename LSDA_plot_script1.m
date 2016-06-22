%% fasterRCNN plot script
EXP = exp_detail(37);
EXP.exp_output_dir = ['/BS/joint-multicut-2/work/Tracking_result/'  'EXP_idx_' num2str(EXP.idx) '/Train/'];
num_seq = length(EXP.label);
for s = 18
    s_name = EXP.label{s};
    %% read h5
    problem_file = [EXP.exp_output_dir  s_name '/' s_name '_problem.h5'];
    boxes = marray_load(problem_file,'boxes');
    segments = marray_load(problem_file,'segments');
    imlist = dir([EXP.im_dir s_name '/*.ppm']);
    for i=47%:boxes(end,6)
        img = imread([EXP.im_dir s_name '/' imlist(i).name]);
        
        h1=figure(1);
        imshow(img,'border','tight');
        %imshow(img);
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
        vis_name = '/home/zhongjie/Downloads/FRCNNplot';
        %set(h1,'PaperUnits','normalized');
        %set(h1,'PaperPosition', [0 0 1 1]);
        %set(h1,'PaperOrientation','landscape');
        %print(1,'-dpdf', vis_name);
        %saveas(h1,vis_name,'eps');
        aver_seg = seg20(:,:,1)*0;
        for i_seg = [10,13,11]
            segment = seg20(:,:,i_seg);
            
            h2=figure(i_seg+1);clf;
            imshow(~segment,'border','tight');
            vis_name = ['/home/zhongjie/Downloads/L' num2str(i_seg) '.png'];
            %print(h2,'-dpng', vis_name);
            aver_seg = aver_seg+segment;
        end
        for i_seg = 4:numDetection
            segment = seg20(:,:,i_seg);
            aver_seg = aver_seg+segment;
        end
        aver_seg=256-uint8(double(aver_seg)/numDetection*256);
        h3=figure(22);
        imshow(aver_seg,'border','tight');
        vis_name = '/home/zhongjie/Downloads/Laverage.pdf';
        %print(h3,'-dpdf', vis_name);
    end
end