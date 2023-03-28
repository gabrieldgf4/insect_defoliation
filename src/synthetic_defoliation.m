
%%%%%% without leaf segmentation



% Perform a syntetic defoliation into an image
%
%
%   img - the input leaf
%
%   img_mask - binarized version of img
%
%   'caterpillar_bite' - path for the insect bites image dataset
%
%   min_defoliation - the minimum defoliation that is accepted
%
%   max_defoliation - the maximum defoliation that is accepted
%
%   min_size_leaf_scale_factor - the minimum scale factor for the leaf
%   image
%
%   max_size_leaf_scale_factor - the maximum scalse factor for the leaf
%   image
%
%   only_border_damage - if 1 enables damage only in the leaf borders
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022)

% [leaf_out, bite_signature, img_out, leaf_seg, defoliation_level] = syntetic_defoliation(img, img_mask, 'caterpillar_bite', 1, 15, 6, 50, 1);

function [leaf_out, bite_signature, img_out, defoliation_level, damaged_areas] = ...
    synthetic_defoliation(leaf, leaf_mask, path_bites, min_defoliation,...
    max_defoliation, min_size_leaf_scale_factor, max_size_leaf_scale_factor,...
    only_border_damage)

rng shuffle; % creates a different seed each time

if min_defoliation > max_defoliation
    error('min_defoliation must be lower than max_defoliation');
end

if exist('bites', 'var') == 0
    bites = load_images(path_bites, 'png');
end

if max_defoliation >= 100
    max_defoliation = 99;
end

if min_defoliation <= 0 
    min_defoliation = 1;
end

[height, width, ~] = size(leaf);

mask_background = ~leaf_mask;
% count the internal holes in the leaf image
leaf_seg2_mask = leaf(:,:,2) > 0;

mask_leaf_after = leaf_mask;

defoliation_level = 0;

min_size_scale_factor = round( min_size_leaf_scale_factor );
max_size_scale_factor = round( max_size_leaf_scale_factor );


% while condition: first part avoids 0% of defoliiation, second part
% avoids a defoliation level lower than min_defoliation and third part
% avoids a defoliation level higher than max_defoliation
% i.e., min_defoliation <= defoliation_level <= max_defoliation

while (defoliation_level < min_defoliation) || (defoliation_level > max_defoliation)
    if defoliation_level < min_defoliation
        % increase the bite
        max_size_scale_factor = round(max_size_scale_factor*1.1);
        min_size_scale_factor = round(min_size_scale_factor*1.1);
        if max_size_scale_factor > max_size_leaf_scale_factor %height
            min_size_scale_factor = round( min_size_leaf_scale_factor ); 
            max_size_scale_factor = round( max_size_leaf_scale_factor ); 
        end
        [mask_leaf_after, mask_leaf_before, defoliation_level] = defoliation(mask_leaf_after, ...
            bites, min_size_scale_factor, max_size_scale_factor, height, width,...
            leaf_mask, only_border_damage);
    else
        % decrease the bite
        max_size_scale_factor = round(max_size_scale_factor*0.9);
        min_size_scale_factor = round(min_size_scale_factor*0.9);
        if min_size_scale_factor < min_size_leaf_scale_factor %height
            min_size_scale_factor = round( min_size_leaf_scale_factor ); 
            max_size_scale_factor = round( max_size_leaf_scale_factor ); 
        end
        [mask_leaf_after, mask_leaf_before, defoliation_level] = defoliation(mask_leaf_before, ...
            bites, min_size_scale_factor, max_size_scale_factor, height, width,...
            leaf_mask, only_border_damage);
    end 
end

mask_leaf3 = mask_leaf_after | mask_background;

leaf_out = double(leaf).*mask_leaf_after;
img_out = double(leaf).*mask_leaf3;

e = edge(leaf_mask,'sobel');
e2 = edge((mask_leaf_after & leaf_seg2_mask),'sobel');
bite_signature = e2 & ~e;

damaged_areas = ~mask_leaf3;

end


function [mask_leaf_after, mask_leaf_before, defoliation_level] = ...
    defoliation(mask_leaf, bites, min_size_scale_factor, max_size_scale_factor, ...
    height, width, leaf_mask, only_border_damage)

    mask_leaf_before = mask_leaf;
    
    qtty_bites = length(bites);
    % select a number of bites to be used
    n_bites = randi([1, qtty_bites]);
    
    for i=1:n_bites
        % select a bite
        bite = bites{ randi([1, qtty_bites]) };

        % rotate the bite
        angle_rot = randi([0, 360]);
        bite = imrotate(bite, angle_rot);
        % crop the bite
        [rw, cl] = find(bite);
        bite = bite(min(rw):max(rw), min(cl):max(cl));
        
        % resize the bite with aspect ratio preserved
        rand_scale = randi([min_size_scale_factor, max_size_scale_factor]);
        bite = imresize(bite, [rand_scale, NaN] );
        
        % perform the bite in the input image
        [h_bite, w_bite] = size(bite);
        % crop the leaf      
        [rows, columns] = find(mask_leaf);
        h_top = randi([min(rows), max(rows)]);
        h_buttom = h_top + h_bite -1;
        if h_buttom > height
            bite = bite(1:height-h_top+1, :);
            h_buttom = height;
        end
        w_left = randi([min(columns), max(columns)]);
        w_right = w_left + w_bite -1;
        if w_right > width
            bite = bite(:, 1:width-w_left+1);
            w_right = width;
        end

        intersection = mask_leaf(h_top:h_buttom, w_left:w_right) & bite;
        mask_leaf(h_top:h_buttom, w_left:w_right) = ...
            mask_leaf(h_top:h_buttom, w_left:w_right) - intersection;
    end
% close holes if they exist
if only_border_damage
    mask_leaf = imfill(mask_leaf, 'holes');
end

diff = leaf_mask & ~mask_leaf;
defoliation_level = ( ( sum(diff(:)) ) / sum(leaf_mask(:)) ) *100;

mask_leaf_after = mask_leaf;

end
