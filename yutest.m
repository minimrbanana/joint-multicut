boxes=marray_load('/BS/joint-multicut-2/work/Tracking_result/EXP_idx_38/Train/cars2/cars2_problem.h5','boxes');
segments=marray_load('/BS/joint-multicut-2/work/Tracking_result/EXP_idx_38/Train/cars2/cars2_problem.h5','segments');
edges=marray_load('/BS/joint-multicut-2/work/Tracking_result/EXP_idx_38/Train/cars2/cars2_problem.h5','edges');
costedges=marray_load('/BS/joint-multicut-2/work/Tracking_result/EXP_idx_38/Train/cars2/cars2_problem.h5','costs-edges');
N = size(boxes,1);
for d=1%:N
%     if ~mod(d,54)
%         ind = 54;
%     else
%         ind = mod(d,54);
%     end
%ind=(d-1)/20+1;
ind=d;
    figure(ind),
    im=segments(:,:,1);
    im=zeros(size(im));
    imshow(~im);
    hold on;
end
for d=1:N
%     if ~mod(d,54)
%         ind = 54;
%     else
%         ind = mod(d,54);
%     end
%ind=(d-1)/20+1;
ind=d;
    figure(ind),
    im=segments(:,:,d);
    [I,J]=find(im==1);
    plot(J,I,'.');
    hold on;
    rect = [boxes(d,1) boxes(d,2) boxes(d,3)-boxes(d,1) boxes(d,4)-boxes(d,2) ];
    rectangle('position', rect);
    hold on; 
    pause;
end
