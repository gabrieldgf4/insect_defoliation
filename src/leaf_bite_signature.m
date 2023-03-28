
% bite_sign = leaf_bite_signature(leaf_model, damaged_leaf, 25, 2, 0.98)

%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 
%

function bite_sign = leaf_bite_signature(leaf_model, damaged_leaf,...
    remove_small_bites, size_disc_element, ecc_thresh)

leaf_model_mask = logical(leaf_model(:,:,2));
leaf_model_mask = imfill(leaf_model_mask,'holes');
damaged_leaf_mask = logical(damaged_leaf(:,:,2));

diff = leaf_model_mask & ~damaged_leaf_mask;

damaged_leaf_border = bwmorph(damaged_leaf_mask, 'remove');
% enlarge the contour
damaged_leaf_border = imdilate(damaged_leaf_border, strel('disk', size_disc_element));

bite_sign = diff & damaged_leaf_border;

bite_sign = bwareaopen(bite_sign, remove_small_bites);

bite_labels = bwlabel(bite_sign);
st_bite = regionprops(bite_sign, 'BoundingBox', 'Eccentricity' );

for i=1:length(st_bite)
    if st_bite(i).Eccentricity > ecc_thresh
        bite_sign(bite_labels == i) = 0;
    end
end

% st_bite = regionprops(bite_sign, 'BoundingBox', 'Eccentricity' );
% figure, imshow(bite_sign);
% for k = 1 : length(st_bite)
%   thisBB = st_bite(k).BoundingBox;
%   rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%   'EdgeColor','r','LineWidth',2 )
% end


end