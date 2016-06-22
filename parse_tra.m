function sampled_trajectories=parse_tra(tra_dir, tra_file, sampling)
% parse the trajecotry

fid = fopen([tra_dir tra_file],'r');

numFrame = str2num(fgetl(fid));
numTraj = str2num(fgetl(fid));
trajectories = cell(ceil(numTraj),2);
sampled_trajectories = cell(ceil(numTraj/sampling),2);
tr_count=1;
for j=1:numTraj
    lengthTr= str2num(fgetl(fid));
    trajectories{tr_count,1} = zeros(lengthTr(2),3);
    trajectories{tr_count,2} = lengthTr(1)+1;
    for i=1:lengthTr(2)
        line = str2num(fgetl(fid));
        trajectories{tr_count,1}(i,:) = (line);
    end
    tr_count=tr_count+1;
end
tr_count=1;
for j=1:numTraj
    if mod(j,sampling)==0
 
    sampled_trajectories{tr_count,1} = trajectories{j,1};
    sampled_trajectories{tr_count,2} = trajectories{j,2};
    tr_count=tr_count+1;
    end
    
end
fclose(fid);
end