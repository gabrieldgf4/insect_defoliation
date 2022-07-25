
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 
%

function reconstructed_leaf  = leaf_reconstruction(leaf_model, damaged_leaf_out)

    leaf_damaged_to_model_mask = logical(damaged_leaf_out(:,:,2));
    
    cHull = bwconvhull(leaf_damaged_to_model_mask);

    reconstructed_leaf = leaf_model.*cHull;

end