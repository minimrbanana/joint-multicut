function segments = fasterRCNN_deeplab_convertSEGforCpp(EXP,boxes)
%load segments
seg = EXP.Segment;

j=1;
CurSeg = seg{j,1};
while size(CurSeg,1)==0 && j<length(seg)
    j=j+1;
    CurSeg = seg{j,1};
end
if size(CurSeg,1)
    FirstSeg = CurSeg{1,1};
    [h,w] = size(FirstSeg);
    segments = zeros(h,w,size(boxes,1));
    index=1;
    for i=j:length(seg)
        CurSeg = seg{i,1};
        if size(CurSeg,1)
            for k=1:size(CurSeg,1)
                if ~isempty(CurSeg{k,1})
                    segments(:,:,index) = CurSeg{k,1};
                    index=index+1;
                end
            end
        end
    end
else
    segments = uint8(0);

end
segments = uint8(segments);

