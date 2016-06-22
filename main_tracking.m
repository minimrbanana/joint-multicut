function main_tracking(eidx)
% The main function for tracking by motion segmentation
clear EXP;

%% parameters init.
EXP = exp_detail(eidx);
EXP.exp_output_dir = ['/BS/joint-multicut-2/work/Tracking_result/'  'EXP_idx_' num2str(EXP.idx) '/Train/'];
if ~exist(EXP.exp_output_dir)
    mkdir(EXP.exp_output_dir);
end
%% multicut main
num_seq = length(EXP.label);

for s = 13:num_seq
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
    if strcmp(EXP.JointChoice,'color');
        add_color_model(boxes,EXP,s);
    end
    if EXP.add_traj == 1 && EXP.add_box == 1 % combined graph
        % check and build color model

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
    if(length(edges>0))
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
        segments = convertSEGforCpp(EXP,boxes);
        write_mode = 'append';
        dataset_name = 'segments';
        marray_save(problem_file, dataset_name, segments, write_mode);
    end
    
    fprintf('H5 file saved ... \n');
    %% solve
%     if strcmp(EXP.solver,'KL')
%         solver= '/BS/multicut_tracking/work/test/people_tracking-build/track-multicut-kl';
%     elseif strcmp(EXP.solver,'ILP')
%         solver = '/home/tang/Projects/git/ILP_tracking-build/track-multicut-gurobi-callback';    
%     end
%     
%     cmd = [solver ' -p ' problem_file  '  -s ' solution_file];
%     system(cmd);
%     %% read from HDF5
%     num_node = size(costs_vertices,1);
%     dataset_name = 'labels-vertices';
%     labels_vertices = marray_load(solution_file, dataset_name);
%     %
%     dataset_name = 'labels-edges';
%     labels_edges = marray_load(solution_file, dataset_name);
%     %% label to matrix
%     fprintf('label to matrix ... \n');
%     if strcmp(EXP.solver,'ILP')
%         link_matrix = label_link_matrix(edges,labels_edges,num_node);
%     elseif strcmp(EXP.solver,'KL')
%         link_matrix = label_link_matrix(edges,1-labels_edges,num_node);
%     end
%     save([EXP.output_dir 'optimization_result.mat'], ...
%         'link_matrix','labels_vertices','costs_vertices','edges','EXP');
%     %% matrix to conn component
%     convert_linkmatrix_to_clusters(EXP);
%     %% visualize boxes clusters
%     % save figures without presenting frame by frame
%     cluster_vis(EXP,s);
    end
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
    if(length(edges>0))
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
        segments = convertSEGforCpp(EXP,boxes);
        write_mode = 'append';
        dataset_name = 'segments';
        marray_save(problem_file, dataset_name, segments, write_mode);
    end
    fprintf('H5 file saved ... \n');
    %% solve
%     if strcmp(EXP.solver,'KL')
%         solver= '/BS/multicut_tracking/work/test/people_tracking-build/track-multicut-kl';
%     elseif strcmp(EXP.solver,'ILP')
%         solver = '/home/tang/Projects/git/ILP_tracking-build/track-multicut-gurobi-callback';    
%     end
%     
%     cmd = [solver ' -p ' problem_file  '  -s ' solution_file];
%     system(cmd);
%     %% read from HDF5
%     num_node = size(costs_vertices,1);
%     dataset_name = 'labels-vertices';
%     labels_vertices = marray_load(solution_file, dataset_name);
%     %
%     dataset_name = 'labels-edges';
%     labels_edges = marray_load(solution_file, dataset_name);
%     %% label to matrix
%     fprintf('label to matrix ... \n');
%     if strcmp(EXP.solver,'ILP')
%         link_matrix = label_link_matrix(edges,labels_edges,num_node);
%     elseif strcmp(EXP.solver,'KL')
%         link_matrix = label_link_matrix(edges,1-labels_edges,num_node);
%     end
%     save([EXP.output_dir 'optimization_result.mat'], ...
%         'link_matrix','labels_vertices','costs_vertices','edges','EXP');
%     %% matrix to conn component
%     convert_linkmatrix_to_clusters(EXP);
%     %% visualize boxes clusters
%     % save figures without presenting frame by frame
%     cluster_vis(EXP,s);
    end
end

end