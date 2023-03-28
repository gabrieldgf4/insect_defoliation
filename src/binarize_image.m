
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 
%

function img_mask = binarize_image(img, threshold)

[~,~, ch] = size(img);
if ch == 1
    img_mask = img ~= threshold;
else
    r = img(:,:,1) ~= threshold; g = img(:,:,2) ~= threshold; b = img(:,:,3) ~= threshold;
    img_mask = r | g | b;
    % fill small holes
    img_mask = ~bwareaopen(~img_mask, 250);
end
    
end