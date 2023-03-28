% leaf_adjustment find the reference line of the leaf and rotate the leaf 
%
%   'leaf' a segmented leaf
%
%   'leaf_mask' a segmented leaf mask
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022)               

% leaf_models = build_leaf_models(leaf, leaf_mask);

function [leaf_model] = build_leaf_models(leaf)

leaf = double(leaf);

% find the central line of the leaf
ref_line = find_ReferenceLine(leaf);

% % show the central line
% e_bordas = bwmorph(leaf(:,:,2),'remove');
% e_bordas = insertShape(double(e_bordas),'line', [ ref_line(3), ref_line(1), ref_line(4), ref_line(2) ]);
% figure; imshow(e_bordas); 

x1 = ref_line(1); y1 = ref_line(3); x2 = ref_line(2); y2 = ref_line(4);
slope = (y2 - y1) ./ (x2 - x1);
angle = atand(slope);
angle = floor(-angle);
% the central line
central_line = struct('point1', [y1 x1], 'point2', [y2 x2], 'theta', angle, 'rho', 0);

lines = central_line;

leaf_model = rotate_image(leaf, lines.theta);

end


function leaf_model = rotate_image(leaf, theta2)

[height, width, ~] = size(leaf);

% a transform suitable for images
Rimage=[ ...
    cosd(theta2) -sind(theta2) 0
    sind(theta2) cosd(theta2) 0
    0 0 1
    ];
% make tform object suitable for imwarp
tform = affine2d(Rimage);

lf = leaf;

% transform image and spatial referencing with tform
[leaf_rot, ~] = imwarp(lf, tform); 

bw = leaf_rot(:,:,2) > 0;
[rows_ref, columns_ref] = find(bw);
leaf_crop = leaf_rot(min(rows_ref):max(rows_ref), min(columns_ref):max(columns_ref), : );

% prepare the model
leaf_model = imresize(leaf_crop, [height, width], 'nearest', 'Antialiasing', false);

end

