%
%   
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 

function [damaged_leaf_out, healthy_leaf_out, damaged_areas_out, bite_signatures_out] =...
    detect_leaf(damaged_leaf, healthy_leaf, damaged_areas, bite_signatures)

damaged_leaf = double(damaged_leaf);
healthy_leaf = double(healthy_leaf);
 
% bw = damaged_leaf_mask;
% bw = imfill(bw,'holes');
% bw_l = bwlabel(bw);
% info = regionprops(bw,'Boundingbox','Area');
% [~, idx] = max([info.Area]);

% % use only the larger bonding box (i.e., the leaf)
% bw_l(bw_l~=idx) = 0;
% damaged_leaf = damaged_leaf.*logical(bw_l); 
% healthy_leaf = healthy_leaf.*logical(bw_l); 
% damaged_areas = damaged_areas.*logical(bw_l);

% find the central line of the leaf
ref_line = find_ReferenceLine(damaged_leaf);

x1 = ref_line(1); y1 = ref_line(3); x2 = ref_line(2); y2 = ref_line(4);
slope = (y2 - y1) ./ (x2 - x1);
angle = atand(slope);
angle = floor(-angle);
% the central line
central_line = struct('point1', [y1 x1], 'point2', [y2 x2], 'theta', angle, 'rho', 0);

lines = central_line;

% % show the reference line
% figure, imagesc(uint8(damaged_leaf)), hold on
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end   

[damaged_leaf_out, healthy_leaf_out, damaged_areas_out, bite_signatures_out] =...
    rotate_image(damaged_leaf, healthy_leaf, damaged_areas, bite_signatures, lines.theta);

end

function [damaged_leaf_out, healthy_leaf_out, damaged_areas_out, bite_signatures_out] =...
    rotate_image(damaged_leaf, healthy_leaf, damaged_areas, bite_signatures, theta2)

[height, width, ~] = size(damaged_leaf);

% a transform suitable for images
Rimage=[ ...
    cosd(theta2) -sind(theta2) 0
    sind(theta2) cosd(theta2) 0
    0 0 1
    ];
% make tform object suitable for imwarp
tform = affine2d(Rimage);

% transform image and spatial referencing with tform
[damaged_leaf_rot, ~] = imwarp(damaged_leaf, tform); 
[healthy_leaf_rot, ~] = imwarp(healthy_leaf, tform);
[damaged_areas_rot, ~] = imwarp(damaged_areas, tform);
[bite_signatures_rot, ~] = imwarp(bite_signatures, tform);

    
bw1 = damaged_leaf_rot(:,:,2) > 0;
[rows_ref1, columns_ref1] = find(bw1);

bw2 = healthy_leaf_rot(:,:,2) > 0;
[rows_ref2, columns_ref2] = find(bw2);

damaged_leaf_crop = damaged_leaf_rot(min(rows_ref1):max(rows_ref1), min(columns_ref1):max(columns_ref1), : );
healthy_leaf_crop = healthy_leaf_rot(min(rows_ref2):max(rows_ref2), min(columns_ref2):max(columns_ref2), : );
damaged_areas_crop = damaged_areas_rot(min(rows_ref2):max(rows_ref2), min(columns_ref2):max(columns_ref2), : );
bite_signatures_crop = bite_signatures_rot(min(rows_ref2):max(rows_ref2), min(columns_ref2):max(columns_ref2), : );

% prepare the model
damaged_leaf_out = imresize(damaged_leaf_crop, [height, width], 'nearest', 'Antialiasing', false);
healthy_leaf_out = imresize(healthy_leaf_crop, [height, width], 'nearest', 'Antialiasing', false);
damaged_areas_out = imresize(damaged_areas_crop, [height, width], 'nearest', 'Antialiasing', false);
bite_signatures_out = imresize(bite_signatures_crop, [height, width], 'nearest', 'Antialiasing', false);

end
