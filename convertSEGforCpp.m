function segments = convertSEGforCpp(EXP,boxes)
%load segments
seg = EXP.Segment;

j=1;
CurSeg = seg{j,1};
while size(CurSeg,1)==0 && j<length(seg)
    j=j+1;
    CurSeg = seg{j,1};
end
num_track = boxes(end,5);
if size(CurSeg,1)
    FirstSeg = CurSeg{1,1};
    [h,w] = size(FirstSeg);
    segments = zeros(h,w,size(boxes,1));
    index=1;
    for n_track = 1:num_track
        for i=j:length(seg)
            CurSeg = seg{i,1};
            if size(CurSeg,1)
                if ~isempty(CurSeg{n_track,1})
                    segments(:,:,index) = CurSeg{n_track,1};
                    index=index+1;
                end
            end
        end
    end
else
    segments = uint8(0);

end
segments = uint8(segments);

