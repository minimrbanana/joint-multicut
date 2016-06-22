function [clusters, cluster_frames, clusters_node_id] = convert_linkmatrix_to_clusters(EXP)
% from link matrix to clusters
fprintf('Converting adjacencymatrix to clusters ... \n')

load([EXP.output_dir 'optimization_result.mat']);

if EXP.add_box==1
    U = EXP.U;
end
if EXP.add_traj==1
    trajectories = EXP.trajectories;
end
fprintf('finding connected components...');
comp_mat = find_conn_comp(link_matrix);
disp('done');
cluster_size_list = cellfun(@length, comp_mat);
comp_mat = comp_mat(find(cluster_size_list(:) > 0));
cluster_size_list = cellfun(@length, comp_mat);

% find out non active node and remove them from cluster
nonactive_node = find(labels_vertices == 0);

if EXP.add_box==1 && EXP.add_traj==0
    U_all = cat(1,U{:});
    assert(size(U_all,1) == length(labels_vertices));
    frame2node = EXP.frame2node;
    num_cluster = length(cluster_size_list);
    count = 1;
    for i = 1:num_cluster
        cluster_u_list = comp_mat{i};
        if length(cluster_u_list) == 1 && ~isempty(find(nonactive_node == cluster_u_list))
            continue; 
        else
            clusters{count} = U_all(cluster_u_list,:);%%%U_all for boxes
            cluster_frames{count} = frame2node(cluster_u_list,:);
            clusters_node_id{count} = cluster_u_list-1; % node id is 0 based
            count = count+1;
        end
    end
    save([EXP.output_dir 'clusters.mat'],'clusters','cluster_frames', 'clusters_node_id');
end
if EXP.add_traj==1 && EXP.add_box==0
    U_all = trajectories;
    
    num_cluster = length(cluster_size_list);
    count = 1;
    trajNum = size(trajectories,1);
    for i = 1:num_cluster
        cluster_u_list = comp_mat{i};
        traj_list = cluster_u_list;
        if size(traj_list,1)>0
            temp = U_all(traj_list,1);
            num_cluster_traj = size(temp,1);
            totalLength = 0;
            for lengthLoop = 1:num_cluster_traj
                totalLength = totalLength + sqrt(size(temp{lengthLoop,1},1));
            end

            if num_cluster_traj<3 || totalLength<10
            %if num_cluster_traj<1 || totalLength<1
                trajNum = trajNum - num_cluster_traj;
                clusters_t{count} = [];
                cluster_frames_t{count} = [];
                clusters_node_id_t{count} = [];
            else
                clusters_t{count} = U_all(traj_list,1);%%%U_all for boxes
                cluster_frames_t{count} = U_all(traj_list,1);
                clusters_node_id_t{count} = traj_list-1; % node id is 0 based          
            end
        end
        count = count+1;     
    end
    fid = fopen([EXP.output_dir 'Tracks' num2str(EXP.num_frame) '.dat'],'w');
    fprintf(fid, '%d\n%d\n', EXP.num_frame,trajNum);
    for count = 1:size(clusters_t,2)
        if size(clusters_t{count},1)>0
            for evaloop=1:size(clusters_t{count},1)
                fprintf(fid,'%d %d\n', count-1,size(clusters_t{count}{evaloop,:},1));
                fprintf(fid,'%f %f %d\n', clusters_t{count}{evaloop,:}');
            end
        end
    end
    fclose(fid);
    save([EXP.output_dir 'clusters_t.mat'],'clusters_t','cluster_frames_t', 'clusters_node_id_t');
end

if EXP.add_traj==1 && EXP.add_box==1

    U_box = cat(1,U{:});%box
    U_traj = trajectories;%trajectories
    num_box = size(U_box,1);
    assert((num_box+size(U_traj,1)) == length(labels_vertices));
    frame2node = EXP.frame2node;
    num_cluster = length(cluster_size_list);
    count = 1;
    trajNum = size(trajectories,1);
    for i = 1:num_cluster
        cluster_u_list = comp_mat{i};
        %if length(cluster_u_list) == 1 && ~isempty(find(nonactive_node == cluster_u_list))
            %continue; 
        %else
            %box
            box_list = cluster_u_list(find(cluster_u_list<=num_box));
            if size(box_list,1)>0
                clusters{count} = U_box(box_list,:);%%%U_all for boxes
                cluster_frames{count} = frame2node(box_list,:);
                clusters_node_id{count} = box_list-1; % node id is 0 based
            end
            %traj
            traj_list = cluster_u_list(find(cluster_u_list>num_box));
            if size(traj_list,1)>0
                temp = U_traj(traj_list-num_box,1);
                num_cluster_traj = size(temp,1);
                totalLength = 0;
                for lengthLoop = 1:num_cluster_traj
                    totalLength = totalLength + sqrt(size(temp{lengthLoop,1},1));
                end
                
                if num_cluster_traj<3 || totalLength<10
                    trajNum = trajNum - num_cluster_traj;
                    clusters_t{count} = [];
                    cluster_frames_t{count} = [];
                    clusters_node_id_t{count} = [];
                else
                    clusters_t{count} = U_traj(traj_list-num_box,1);%%%U_all for boxes
                    cluster_frames_t{count} = U_traj(traj_list-num_box,1);
                    clusters_node_id_t{count} = traj_list-num_box-1; % node id is 0 based          
                end

            end
            count = count+1;
    end
    %% save dat file for evaluation
    fid = fopen([EXP.output_dir 'Tracks' num2str(EXP.num_frame) '.dat'],'w');
    fprintf(fid, '%d\n%d\n', EXP.num_frame,trajNum);
    for count = 1:size(clusters_t,2)
        if size(clusters_t{count},1)>0
            for evaloop=1:size(clusters_t{count},1)
                fprintf(fid,'%d %d\n', count-1,size(clusters_t{count}{evaloop,:},1));
                fprintf(fid,'%f %f %d\n', clusters_t{count}{evaloop,:}');
            end
        end
    end
    fclose(fid);
    %% save clusters
    save([EXP.output_dir 'clusters_c.mat'],'clusters','cluster_frames', 'clusters_node_id','clusters_t','cluster_frames_t', 'clusters_node_id_t');

end


end




