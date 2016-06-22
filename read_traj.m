function [EXP, trajectories, traj_edges, cost_traj_edges] = read_traj(EXP,s_idx, prior)
% Read trajectory information - edges, costs, coordinates

if nargin<3
    prior=0.5;
end
try 
    load([EXP.output_dir  'trajectories.mat'])
catch
    checkdir = '/BS/joint-multicut/work/Tracking_result/UnaryTraj/';
    switch EXP.istest
        case 1
            T_label = 'Test_';
        case 0
            T_label = 'Train_';
    end
    checkfolder = [T_label 'sample_' int2str(EXP.sampling) '_from_' num2str(5000008) '/'];
    checkpath = [checkdir checkfolder];
    try
        load([checkpath EXP.label{s_idx} '/trajectories.mat']);
        save([EXP.output_dir  'trajectories.mat'], 'trajectories','traj_edges','cost_traj_edges');
    catch
        if ~exist([checkpath EXP.label{s_idx}],'dir')
            mkdir([checkpath EXP.label{s_idx}]);
        end
        tra_dir = [EXP.TrajDir EXP.label{s_idx} '/MulticutResults/2mldof0.5000008/'];
        sampling=EXP.sampling; %sample every k-th trajectory
        tra_file = dir([tra_dir 'TrackswoLabels*.dat']);
        fprintf('parsing trajectory file ...\n')
        trajectories=parse_tra(tra_dir, tra_file(1).name, sampling);
        fprintf('\nReading trajectory weight file ...\n')
        cost_tra_file = dir([tra_dir 'Weights*.dat']); 
        probs = load([tra_dir cost_tra_file(1).name ]);
        v1 = probs(:,1)+1;
        v2 = probs(:,2)+1;
        probs = probs(:,3);
        try temp=EXP.traj_cost_para;
            probs=probs*temp;
        catch
        end
        if strcmp(EXP.solver,'ILP')
            cost_traj_edges = log((1-probs)./probs)+log((1-prior)/prior);
        elseif strcmp(EXP.solver,'KL')
            cost_traj_edges = -(log((1-probs)./probs)+log((1-prior)/prior));
        end
        %adapt weights to sampling rate of trajectories
        max_vertexbs = max(max(v1),max(v2));
        tr_vertexmap = zeros(max_vertexbs,1);
        for traj_it=1:size(trajectories,1)
            tr_vertexmap(trajectories{traj_it,2}) = traj_it;
        end
        %v11=v1;v22=v2;
        for i=1:length(v1)
            v1(i) = tr_vertexmap(v1(i));
            v2(i) = tr_vertexmap(v2(i));
        end
        %val_ind = (v1>=0) .*(v2>=0);
        val_ind =1- ((v1==0) |(v2==0));
        cost_traj_edges=cost_traj_edges(val_ind>0);
        v1=v1(val_ind>0);
        v2=v2(val_ind>0);
        traj_edges = [v1;v2];
        [temp,IA,IC] = unique(traj_edges);
        trajectories0 = cell(size(temp,1),2);
        for traj_it=1:size(temp,1)
            trajectories0{traj_it,1} = trajectories{temp(traj_it),1};
            trajectories0{traj_it,2} = trajectories{temp(traj_it),2};
        end
        trajectories = trajectories0;
        traj_edges = reshape(IC,size(IC,1)/2,2);
        traj_edges = traj_edges - 1;
        traj_edges = uint64(traj_edges);
        save([checkpath EXP.label{s_idx} '/trajectories.mat'], 'trajectories','traj_edges','cost_traj_edges');
        save([EXP.output_dir  'trajectories.mat'], 'trajectories','traj_edges','cost_traj_edges');
    end
end
EXP.trajectories = trajectories;
%get number of frames
box_color_dir = [EXP.BoxDir_color  EXP.label{s_idx} '/'];
color_mat_list = dir([box_color_dir '*.mat']);
num_frame = length(color_mat_list);
EXP.num_frame = num_frame;

end