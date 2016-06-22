function EXP = compute_box_pairwise_cost(EXP,s_idx)
%
% compute boxes pairwise cost;
%

U = EXP.U;
num_frame =  length(U);
%% para init.
try 
    load([EXP.output_dir  'costs_box_edges.mat'])
catch
    pairwise_cost_all = cell(num_frame);

    %% compute pairwise cost
    for i = 1:num_frame
        fprintf('Compute pairwise cost for frame:  %d ', i)
        u_1 = U{i};
        if ~isempty(u_1)
            for offset_idx = 1:length(EXP.temporal_thr)
                % computing pairwise cost between frame i and frame j
                j = i+EXP.temporal_thr(offset_idx);
                if j<=num_frame
                    fprintf(' and  %d', j)
                    u_2 = U{j};
                    if ~isempty(u_2)
                        switch EXP.pairwise %choose combination of pairwise terms
                            case 'IoU'
                                if EXP.Iou4segment == 0
                                    pairwise_cost_1 = compute_pairwise_cost_block(EXP,i,j);% iou
                                else
                                    pairwise_cost_1 = compute_pairwise_cost_segment(EXP,i,j);% iou seg
                                end
                            case 'appearance'
                                temp = loadL(EXP.L_dimension);
                                EXP.L = temp.L;
                                pairwise_cost_1 = compute_pairwise_cost_block_metriclearning(EXP,i,j,s_idx);% appearance

                            case 'Iapp'
                                if EXP.Iou4segment == 0
                                    pairwise_cost_1 = compute_pairwise_cost_block(EXP,i,j);% iou
                                else
                                    pairwise_cost_1 = compute_pairwise_cost_segment(EXP,i,j);% iou seg
                                end
                                temp = loadL(EXP.L_dimension);
                                EXP.L = temp.L;
                                pairwise_cost_3 = compute_pairwise_cost_block_metriclearning(EXP,i,j,s_idx);% appearance
                                if (j-i)<6
                                    pairwise_cost_1 = pairwise_cost_1*(1-0.2*(j-i))+pairwise_cost_3*0.2*(j-i);
                                else
                                    pairwise_cost_1 = pairwise_cost_3;
                                end
                                if EXP.reduce_boxpair_negative == 1
                                    pairwise_cost_1(pairwise_cost_1>=0) = 0;
                                end
                        end
                        % sign dealed in fcn cost2pair
                        pairwise_cost = pairwise_cost_1;
                        pairwise_cost_all{i,j} = double(EXP.boxpairWeight*pairwise_cost);
                        
                    end
                end
            end
        end
        fprintf('\n');
    end
    save([EXP.output_dir 'costs_box_edges.mat'], 'pairwise_cost_all');
end
EXP.pairwise_cost = pairwise_cost_all;
end

function pairwise_cost = compute_pairwise_cost_block(EXP,frame_idx_1, frame_idx_2)
% compute box IoU 
b1 = EXP.U{frame_idx_1};
b2 = EXP.U{frame_idx_2};
num_det_1 = size(b1,1);
num_det_2 = size(b2,1);


% translate boxes from [x1 y1 x2 y2] to [x1 y1 w h]
box1 = [b1(:,1) b1(:,2) b1(:,3)-b1(:,1) b1(:,4)-b1(:,2)];
box2 = [b2(:,1) b2(:,2) b2(:,3)-b2(:,1) b2(:,4)-b2(:,2)];
switch EXP.boxpairIoU
    case 'IoU'
        iou = bboxOverlapRatio(box1,box2);
    case 'IoUmin'
        iou = bboxOverlapRatio(box1,box2,'Min');
    case 'IoUmax'
        BoxInt = rectint(box1,box2);
        BoxArea1 = box1(:,3).*box1(:,4)*ones(1,num_det_2);
        BoxArea2 = ones(num_det_1,1)*(box2(:,3).*box2(:,4))';
        maxArea = max(BoxArea1,BoxArea2);
        iou = BoxInt./maxArea;
end
pairwise_cost = iou*(-20)+10;
end

function pairwise_cost = compute_pairwise_cost_segment(EXP,frame_idx_1, frame_idx_2)
% compute IoU based on segmentation
b1 = EXP.U{frame_idx_1};
b2 = EXP.U{frame_idx_2};
s1 = EXP.Segment{frame_idx_1};
s2 = EXP.Segment{frame_idx_2};
num_det_1 = size(b1,1);
num_det_2 = size(b2,1);

pairwise_cost = zeros(num_det_2,num_det_1);
                                    
for d1 = 1 : num_det_1
    seg_1 = s1{d1,1};
    area1 = sum(sum(seg_1));
    for d2 = 1: num_det_2
        seg_2 = s2{d2,1};
        area2 = sum(sum(seg_2));
        segInt = seg_1&seg_2;
        segAll = seg_1|seg_2;
        iou = sum(sum(segInt))/sum(sum(segAll));
        %ioumin = sum(sum(segInt))/min(area1,area2);%
        pairwise_cost(d2,d1) = iou*(-20)+10;
    end
end


end

function pairwise_cost = compute_pairwise_cost_block_metriclearning(EXP,frame_idx_1, frame_idx_2, s_idx)
% compute cost based on the appearance feature
b1 = EXP.F7{frame_idx_1};
b2 = EXP.F7{frame_idx_2};
num_det_1 = size(b1,1);
num_det_2 = size(b2,1);
L = EXP.L;

d_f7=[];
for d1 = 1 : num_det_1
    f1 = b1(d1,:);
    f1m = ones(num_det_2,1)*f1;
    d_f7 =[d_f7; f1m-b2];    
end
dist0 = (d_f7*L')*(L*d_f7');
dist = diag(dist0);
pairwise_cost=reshape(dist,num_det_2,num_det_1)';
if EXP.L_dimension == 4096
    pairwise_cost = 0.4*pairwise_cost-10;
elseif EXP.L_dimension == 256
    pairwise_cost = 2*pairwise_cost-3;
elseif EXP.L_dimension ==0.5
    pairwise_cost = 1.71*pairwise_cost-3;
end

end

function L = loadL(dimL)
% load matrix L according to the given dimension
switch dimL
    case 4096
        L = load('/BS/joint-multicut/work/Tracking_result/Para/L.mat');
    case 256
        L = load('/BS/joint-multicut/work/Tracking_result/Para/L256.mat');
    case 0.5
        L = load('/BS/joint-multicut/work/Tracking_result/Para/Lhalf.mat');
end
end