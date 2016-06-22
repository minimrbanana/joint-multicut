function [mus, sigmas] = convertGMMforCpp(EXP,s_name)
%setting path
switch EXP.istest
    case 1
        set1 = 'Test_';
    case 0
        set1 = 'Train_';
end
set2 = num2str(EXP.box_score_min);
set3 = num2str(EXP.box_rank_num);
if EXP.isDeepMask
    set4 = '_DeepMask_1/';
else
    set4 = ['_nms_' num2str( EXP.box_NMS ) '/'];
end
setting = [set1 'score_' set2 '_rank_' set3 set4];
datapath = ['/BS/joint-multicut-2/work/FBMS_GMM/' setting];

load([datapath,s_name,'/','GMModel.mat']);
mus = zeros(length(GMModels),3);
sigmas = zeros(length(GMModels),9);
if ~isempty(GMModels)
    for i=1:length(GMModels)
        [m,ind]=max(GMModels{i}.PComponents);
        maxmu = GMModels{i}.mu(ind,:);
        maxSigma = pinv(GMModels{i}.Sigma(:,:,ind));
        maxSigma = maxSigma(:);
        mus(i,:)=lab2rgb(maxmu);
        sigmas(i,:) = maxSigma;
    end
else
    mus=0;sigmas=0;
end


