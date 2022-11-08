
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 
%

function reconstructed_leaf  = leaf_blending(leaf_model, damaged_leaf_out)

    leaf_model_mask = logical(leaf_model(:,:,2));
    leaf_model_mask = imfill(leaf_model_mask,'holes');
    damaged_leaf_out_mask = logical(damaged_leaf_out(:,:,2));
    
    damaged_leaf_out_mask = imerode(damaged_leaf_out_mask, strel('disk', 2));
    
%     source_mask = damaged_leaf_out_mask;
%     source = damaged_leaf_out;
  
    source_mask = damaged_leaf_out_mask & leaf_model_mask; % only leaf regions that are in the leaf model
    source = damaged_leaf_out.*leaf_model_mask; % only leaf regions that are in the leaf model
    target_mask = leaf_model_mask;
    target = leaf_model;
    reconstructed_leaf = ConvPyrBlending(target,source,source_mask, target_mask);

end
