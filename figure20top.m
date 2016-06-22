%% draw the figures with top 20 detections and their segmentations

function figure20top(eidx)
% The main function for tracking by motion segmentation
clear EXP;

%% parameters init.
EXP = exp_detail(eidx);
EXP.exp_output_dir = ['/BS/joint-multicut-2/work/Tracking_result/'  'EXP_idx_' num2str(EXP.idx) '/Train/'];
if ~exist(EXP.exp_output_dir)
    mkdir(EXP.exp_output_dir);
end
%% training set
num_seq = length(EXP.label);

for s = 3:num_seq
    %% sequence-dependent output
    s_name = EXP.label{s};
    EXP.output_dir = [EXP.exp_output_dir  s_name '/' ];
    if ~exist(EXP.output_dir,'dir')
        mkdir(EXP.output_dir);
    end
    %% build graph
    if EXP.add_traj == 1 % include trajectory into the model
        [EXP, trajectories, traj_edges, cost_traj_edges] = read_traj(EXP,s);
        num_traj = length(trajectories);
        cost_traj_vertices = zeros(num_traj,1);
    end
    if EXP.add_box == 1 % include bbox into the model
        [EXP, costs_box_vertices, box_edges, cost_box_edges, boxes] = read_box(EXP,s);
        num_box = length( costs_box_vertices);
    end
    % check and build color model
    if strcmp(EXP.JointChoice,'color');
        add_color_model(boxes,EXP,s);
    end
    if EXP.add_traj == 1 && EXP.add_box == 1 % combined graph
        [EXP, traj_edges, traj_box_edges, cost_traj_box] = combine_traj_box(trajectories,traj_edges,num_box,num_traj,boxes,EXP,s);
    end
    
   
    %% write to HDF5
    if  EXP.add_traj == 0
        costs_vertices = costs_box_vertices;
        edges = box_edges;
        cost_edges = cost_box_edges;
        M_coordinates_vertices = boxes(:,1:2);
        class_vertices = zeros(length(costs_vertices),1);
    elseif EXP.add_box == 0
        costs_vertices = cost_traj_vertices;
        edges = traj_edges;
        cost_edges = cost_traj_edges;
        M_coordinates_vertices =ones(size(costs_vertices,1),2);
        boxes = ones(1,6);
        class_vertices = ones(length(costs_vertices),1);
    else
        costs_vertices = [costs_box_vertices; cost_traj_vertices];
        edges = [box_edges; traj_edges;traj_box_edges];
        cost_edges = [cost_box_edges; cost_traj_edges;cost_traj_box];
        [edges,IA,IC] = unique(edges,'rows');
        cost_edges = cost_edges(IA);
        M_coordinates_vertices = [boxes(:,1:2) ;zeros(size( cost_traj_vertices,1),2)];
        class_vertices = [zeros(length(costs_box_vertices),1); ones(length(cost_traj_vertices),1)];
    end
    
    if(length(edges)<0)% do not save h5 problem files
    fprintf('writing  problem to hdf5 file ... \n');
    problem_file = [EXP.output_dir  s_name '_problem.h5'];
    solution_file = [EXP.output_dir  s_name '_solution.h5'];
    
    write_mode = 'overwrite';
    dataset_name = 'costs-vertices';
    marray_save(problem_file, dataset_name, costs_vertices, write_mode);
    
    write_mode = 'append';
    dataset_name =  'edges';
    marray_save(problem_file, dataset_name, edges, write_mode);
    
    dataset_name =  'costs-edges';
    marray_save(problem_file, dataset_name, cost_edges, write_mode);
    
    dataset_name = 'coordinates-vertices';
    marray_save(problem_file, dataset_name, M_coordinates_vertices, write_mode);
    
    dataset_name = 'class-vertices';
    marray_save(problem_file, dataset_name, class_vertices, write_mode);
    
    dataset_name = 'boxes';  %necessary?
    if size(boxes,1)>0
        marray_save(problem_file, dataset_name, boxes, write_mode);
    end
    
    dataset_name = 'edges-cut';
    M_intra_cut = uint64([0 0;0 0]);
    marray_save(problem_file, dataset_name,M_intra_cut, write_mode);
    
    if EXP.save_color_model ==1
        [mus, sigmas] = convertGMMforCpp(EXP,s_name);
        write_mode = 'append';
        dataset_name = 'mu';
        marray_save(problem_file, dataset_name, mus, write_mode);
        write_mode = 'append';
        dataset_name = 'sigma';
        marray_save(problem_file, dataset_name, sigmas, write_mode);
        segments = convertSEGforCpp(EXP);
        write_mode = 'append';
        dataset_name = 'segments';
        marray_save(problem_file, dataset_name, segments, write_mode);
    end
    fprintf('H5 file saved ... \n');
    end
    % to plot the figures
    imlist = dir([EXP.im_dir s_name '/*.ppm']);
    %%
    for i=1:length(EXP.U)
        img = imread([EXP.im_dir s_name '/' imlist(i).name]);
        h = figure(eidx);
        set(h,'Visible','off');
        clf;
        subplot('Position',[0,0.3,1,0.7]),
        imshow(img);
        hold on;
        box20 = double(EXP.U{i,1});
        seg20 = EXP.Segment{i,1};
        numDetection = size(box20,1);
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
            segment = seg20{i_seg};
            if i_seg<=10
                subplot('Position',[0.1*(i_seg-1),0.15,0.1,0.15]),
                imshow(~segment);
            else
                subplot('Position',[0.1*(i_seg-11),0,0.1,0.15]),
                imshow(~segment);
            end
        end
        vis_name = [EXP.output_dir  'img/' imlist(i).name(1:end-3) 'png'];
        if ~exist([EXP.output_dir  'img/'],'dir')
            mkdir([EXP.output_dir  'img/']);
        end
        fprintf('saving %s\n', vis_name);
        print(h,'-dpng', vis_name);
    end
    %%
end



%% test set
EXP.istest =1;
load ('/BS/joint-multicut/work/Tracking_result/Para/Ftest_label.mat');
EXP.label =  Ftest_label;
EXP.im_dir = '/BS/joint-multicut/work/FBMS59/Testset/';
EXP.BoxDir_color = '/BS/joint-multicut/work/DetectionRes/Ftest_LC/';
EXP.BoxDir_flow = '/BS/joint-multicut/work/DetectionRes/Ftest_LF/';
EXP.TrajDir = '/BS/joint-multicut/work/FBMS59/Testset/';

EXP.exp_output_dir = ['/BS/joint-multicut-2/work/Tracking_result/'  'EXP_idx_' num2str(EXP.idx) '/Test/'];
if ~exist(EXP.exp_output_dir)
    mkdir(EXP.exp_output_dir);
end

num_seq = length(EXP.label);

for s = 1:num_seq
    %% sequence-dependent output
    s_name = EXP.label{s};
    EXP.output_dir = [EXP.exp_output_dir  s_name '/' ];
    if ~exist(EXP.output_dir,'dir')
        mkdir(EXP.output_dir);
    end
    %% build graph
    if EXP.add_traj == 1 % include trajectory into the model
        [EXP, trajectories, traj_edges, cost_traj_edges] = read_traj(EXP,s);
        num_traj = length(trajectories);
        cost_traj_vertices = zeros(num_traj,1);
    end
    if EXP.add_box == 1 % include bbox into the model
        [EXP, costs_box_vertices, box_edges, cost_box_edges, boxes] = read_box(EXP,s);
        num_box = length( costs_box_vertices);
    end
    % check and build color model
    if strcmp(EXP.JointChoice,'color');
        add_color_model(boxes,EXP,s);
    end
    if EXP.add_traj == 1 && EXP.add_box == 1 % combined graph
        [EXP, traj_edges, traj_box_edges, cost_traj_box] = combine_traj_box(trajectories,traj_edges,num_box,num_traj,boxes,EXP,s);
    end
    
   
    %% write to HDF5
    if  EXP.add_traj == 0
        costs_vertices = costs_box_vertices;
        edges = box_edges;
        cost_edges = cost_box_edges;
        M_coordinates_vertices = boxes(:,1:2);
        class_vertices = zeros(length(costs_vertices),1);
    elseif EXP.add_box == 0
        costs_vertices = cost_traj_vertices;
        edges = traj_edges;
        cost_edges = cost_traj_edges;
        M_coordinates_vertices =ones(size(costs_vertices,1),2);
        boxes = ones(1,6);
        class_vertices = ones(length(costs_vertices),1);
    else
        costs_vertices = [costs_box_vertices; cost_traj_vertices];
        edges = [box_edges; traj_edges;traj_box_edges];
        cost_edges = [cost_box_edges; cost_traj_edges;cost_traj_box];
        [edges,IA,IC] = unique(edges,'rows');
        cost_edges = cost_edges(IA);
        M_coordinates_vertices = [boxes(:,1:2) ;zeros(size( cost_traj_vertices,1),2)];
        class_vertices = [zeros(length(costs_box_vertices),1); ones(length(cost_traj_vertices),1)];
    end
    if(length(edges)<0)
    fprintf('writing  problem to hdf5 file ... \n');
    problem_file = [EXP.output_dir  s_name '_problem.h5'];
    solution_file = [EXP.output_dir  s_name '_solution.h5'];
    
    write_mode = 'overwrite';
    dataset_name = 'costs-vertices';
    marray_save(problem_file, dataset_name, costs_vertices, write_mode);
    
    write_mode = 'append';
    dataset_name =  'edges';
    marray_save(problem_file, dataset_name, edges, write_mode);
    
    dataset_name =  'costs-edges';
    marray_save(problem_file, dataset_name, cost_edges, write_mode);
    
    dataset_name = 'coordinates-vertices';
    marray_save(problem_file, dataset_name, M_coordinates_vertices, write_mode);
    
    dataset_name = 'class-vertices';
    marray_save(problem_file, dataset_name, class_vertices, write_mode);
    
    dataset_name = 'boxes';  %necessary?
    if size(boxes,1)>0
        marray_save(problem_file, dataset_name, boxes, write_mode);
    end
    
    dataset_name = 'edges-cut';
    M_intra_cut = uint64([0 0;0 0]);
    marray_save(problem_file, dataset_name,M_intra_cut, write_mode);
    
    if EXP.save_color_model ==1
        [mus, sigmas] = convertGMMforCpp(EXP,s_name);
        write_mode = 'append';
        dataset_name = 'mu';
        marray_save(problem_file, dataset_name, mus, write_mode);
        write_mode = 'append';
        dataset_name = 'sigma';
        marray_save(problem_file, dataset_name, sigmas, write_mode);
        segments = convertSEGforCpp(EXP);
        write_mode = 'append';
        dataset_name = 'segments';
        marray_save(problem_file, dataset_name, segments, write_mode);
    end
    fprintf('H5 file saved ... \n');
    end
    % to plot the figures
    imlist = dir([EXP.im_dir s_name '/*.ppm']);
    for i=1:length(EXP.U)
        img = imread([EXP.im_dir s_name '/' imlist(i).name]);
        h = figure(eidx);
        set(h,'Visible','off');
        clf;
        subplot('Position',[0,0.3,1,0.7]),
        imshow(img);
        hold on;
        box20 = double(EXP.U{i,1});
        seg20 = EXP.Segment{i,1};
        for i_box = 1:20
            rect_x1 = box20(i_box,1);
            rect_y1 = box20(i_box,2);
            rect_width = box20(i_box,3) - box20(i_box,1);
            rect_height = box20(i_box,4) - box20(i_box,2);
            rectangle('Position', [rect_x1, rect_y1, rect_width, rect_height], ...
                    'EdgeColor', 'r', 'LineWidth', 0.3);
            text(rect_x1 - 8, rect_y1 - 4, ...
                        num2str(i_box), 'FontSize', 6, 'Color', 'k');
        end
        for i_seg = 1:20
            segment = seg20{i_seg};
            if i_seg<=10
                subplot('Position',[0.1*(i_seg-1),0.15,0.1,0.15]),
                imshow(~segment);
            else
                subplot('Position',[0.1*(i_seg-11),0,0.1,0.15]),
                imshow(~segment);
            end
        end
        vis_name = [EXP.output_dir  'img/' imlist(i).name(1:end-3) 'png'];
        if ~exist([EXP.output_dir  'img/'],'dir')
            mkdir([EXP.output_dir  'img/']);
        end
        fprintf('saving %s\n', vis_name);
        print(h,'-dpng', vis_name);
    end
end
end