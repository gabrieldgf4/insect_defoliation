
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 
%

function reconstructed_leaf  = leaf_inpaint(leaf_model, damaged_leaf_out)

    leaf_model_mask = logical(leaf_model(:,:,2));
    leaf_model_mask = imfill(leaf_model_mask,'holes');
    damaged_leaf_out_mask = logical(damaged_leaf_out(:,:,2));
    
    damaged_leaf_out_mask = imerode(damaged_leaf_out_mask, strel('disk', 2));
  
    mask = double(~damaged_leaf_out_mask);
    reconstructed_leaf = inpaintBCT(damaged_leaf_out,'orderD',mask,'guidanceC',[26 5550 1 1]);

    cHull = bwconvhull(damaged_leaf_out_mask);
    
    mask_final = leaf_model_mask & cHull;
    
    reconstructed_leaf = reconstructed_leaf.*mask_final;
end