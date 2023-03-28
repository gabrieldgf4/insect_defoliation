%
% % Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022)
%

addpath(genpath('multilevelOT'));
addpath(genpath('DeBleeding'));
addpath(genpath('inpaintBCT'));
addpath(genpath('Evaluation'));
addpath(genpath('utils'));

clear; close all;

%% Load images
template_images = load_images('images/template_images', 'png');
test_images = load_images('images/test_images', 'png');

%% PREPROCESSING
% binarize model data
threshold = 5;
qtty_modelData = length(template_images);
template_images_mask = cell(qtty_modelData,1);

for i=1:qtty_modelData
    template_images_mask{i} = binarize_image(template_images{i}, threshold);
    template_images{i} = double(template_images{i}) .* template_images_mask{i};
end

% prepare leaf models
leaf_models = cell(qtty_modelData,1);

for i=1:qtty_modelData
    [~,~, ch] = size(template_images{i});

    l_model...
    = build_leaf_models(template_images{i});
    leaf_models(i) = { l_model };    
end

%% binarize leaf models
leaf_models_mask = cell(qtty_modelData,1);
for i=1:qtty_modelData
    leaf_model_mask = leaf_models{i};
    leaf_model_mask = logical(leaf_model_mask(:,:,2));
    leaf_model_mask_hull = bwconvhull(leaf_model_mask);
    leaf_models_mask{i} = leaf_model_mask_hull;
end

%% binarize test data
threshold = 0;
qtty_testImages = length(test_images);
test_images_mask = cell(qtty_testImages,1);
for i=1:qtty_testImages
    test_images_mask{i} = binarize_image(test_images{i}, threshold);
    test_images{i} = double(test_images{i}) .* test_images_mask{i};
end

%% Apply synthetic defoliation
id = 1;
img = test_images{id};
img_mask = test_images_mask{id};
min_defoliation = 16;
max_defoliation = 31;

[defoliated_leaf_testData, bite_signature_testData, img_out, defoliation_level, damaged_areas] = ...
    synthetic_defoliation(img,img_mask,'caterpillar_bite', min_defoliation, max_defoliation, 6, 50, 1);

figure; imagesc(uint8(img)); title('Original Image');
figure; imagesc(uint8(defoliated_leaf_testData)); colormap gray
title(['Synthetic defoliation: ', num2str(defoliation_level), '% damage']);

%% binarize defoliated leaf test data
defoliated_leaf_testData_mask = binarize_image(defoliated_leaf_testData,threshold);

%% Compute defoliation
[damaged_leaf_out, healthy_leaf_out, damaged_areas_out, bite_signatures_out] = ...
        detect_leaf(defoliated_leaf_testData, img, damaged_areas, bite_signature_testData);

% calc defoliation using healthy leaf mask
healthy_leaf_out_mask = logical(healthy_leaf_out(:,:,2));
defoliation_level_ALL(1) = (sum(damaged_areas_out(:) * 100) / sum(healthy_leaf_out_mask(:)));

% prepare the damaged leaf mask
damaged_leaf_out_mask = logical(damaged_leaf_out(:,:,2));
damaged_leaf_out_mask_hull = bwconvhull(damaged_leaf_out_mask);

% IMAGE MATCHING
% compare the damaged leaf with the leaf models using jaccard
jac_result = zeros(length(leaf_models_mask), 1);
for j=1:length(leaf_models_mask)
    jac_result(j) = jaccard(leaf_models_mask{j}, damaged_leaf_out_mask_hull); 
end
[jac_max, jac_max_idx] = max(jac_result);


%% DEFOLIATION ESTIMATE
leaf_model = leaf_models{jac_max_idx};
leaf_model_mask = logical(leaf_model(:,:,2));
diff = leaf_model_mask & ~damaged_leaf_out_mask;
defoliation_level_ALL(2) = (sum(diff(:) * 100) / (sum(leaf_model_mask(:))));

% evaluate the damaged area
jac = jaccard(damaged_areas_out, diff);
dic = dice(damaged_areas_out, diff);

% keep evaluating the damaged area
[confusionMatrix_pixels, resultRates_pixels, resultSDT, overlap] =...
    leaf_evaluation(damaged_leaf_out_mask, healthy_leaf_out_mask);
%%
fprintf('#### DEFOLIATION ESTIMATE #### \n')

fprintf('Actual Damage (GT): %1.4f\nDefoliation Estimate (DE) Index: %1.4f\n',...
    defoliation_level_ALL(1), defoliation_level_ALL(2));

fprintf('Jaccard Index: %1.4f\nDice Index: %1.4f\n', jac, dic)

%% Show the results
figure; imshowpair(uint8(leaf_model), uint8(damaged_leaf_out));
title('Leaf model and Damaged leaf');
%%
B = imoverlay(uint8(damaged_leaf_out), diff, [1 0 0]);
figure; imshow(uint8(B));
title('Damaged areas');



%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%
%%%%%%%

% Bite signature evaluation
remove_small_bites = 25; 
size_disc_element = 2;
ecc_thresh = 0.98;

bite_sign = leaf_bite_signature(leaf_model, damaged_leaf_out,...
    remove_small_bites, size_disc_element, ecc_thresh);

[result_TP_FP_FN] = leaf_evaluation_bites(bite_sign, bite_signatures_out,...
    5, 12, 0.5);

figure; imshowpair(uint8(leaf_model), uint8(bite_sign));
title('Leaf model and Bite segments');

figure; imshowpair(uint8(bite_signatures_out), uint8(bite_sign));
title('Ground-Truth bites and Detected bite segments');

%% BITE BOUNDING BOXES
 st = regionprops(bite_sign, 'BoundingBox' );
 
 bite = imoverlay(uint8(damaged_leaf_out), bite_sign, 'g');
 figure(4); imshow(bite);
 figure(4)
 
 for k = 1 : length(st)
  thisBB = st(k).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','r','LineWidth',2 )
 end

%%
fprintf('#### INSECT PREDATION - BITE SEGMENTS #### \n')

fprintf('True positive bites: %i\nFalse positive bites: %i\nFalse negative bites: %i\n',...
    result_TP_FP_FN(1), result_TP_FP_FN(2), result_TP_FP_FN(3))

%% Leaf reconstruction evaluation

fprintf('#### LEAF RECONSTRUCTION #### \n')

% Leaf reconstruction using the retrived model
reconstructed_leaf_1  = leaf_model; %leaf_reconstruction(leaf_model, damaged_leaf_out);

% only leaf regions that are in the leaf model
healthy_leaf_out_based_model = healthy_leaf_out.*leaf_model_mask;

[resultQuality_1, resultDistances_1] = leaf_evaluation_quality(healthy_leaf_out_based_model, reconstructed_leaf_1);
SSIM_reconstruction_1 = resultQuality_1(1);

figure; imshowpair(uint8(healthy_leaf_out_based_model), uint8(reconstructed_leaf_1), 'montage')
title('Health leaf and reconstructed with the retrieved model')

fprintf('SSSIM model (Leaf Model): %1.4f\n', SSIM_reconstruction_1);

%% Leaf reconstruction evaluation
% Leaf reconstruction using image blending
reconstructed_leaf_2  = leaf_blending(leaf_model, damaged_leaf_out);

% only leaf regions that are in the leaf model
healthy_leaf_out_based_model = healthy_leaf_out.*leaf_model_mask;

[resultQuality_2, resultDistances_2] = leaf_evaluation_quality(healthy_leaf_out_based_model, reconstructed_leaf_2);
SSIM_reconstruction_2 = resultQuality_2(1);

figure; imshowpair(uint8(healthy_leaf_out_based_model), uint8(reconstructed_leaf_2), 'montage')
title('Health leaf and reconstructed with image blending')

fprintf('SSSIM model (Image Blending): %1.4f\n', SSIM_reconstruction_2);

%% Leaf reconstruction evaluation
% Leaf reconstruction using image inpainting
reconstructed_leaf_3  = leaf_inpaint(leaf_model, damaged_leaf_out);

% only leaf regions that are in the leaf model
healthy_leaf_out_based_model = healthy_leaf_out.*leaf_model_mask;

[resultQuality_3, resultDistances_3] = leaf_evaluation_quality(healthy_leaf_out_based_model, reconstructed_leaf_3);
SSIM_reconstruction_3 = resultQuality_3(1);

figure; imshowpair(uint8(healthy_leaf_out_based_model), uint8(reconstructed_leaf_3), 'montage')
title('Health leaf and reconstructed with inpaint')
fprintf('SSSIM model (Image Inpaint): %1.4f\n', SSIM_reconstruction_3);


%% LEAF CONTOUR
bin = leaf_model_mask;
bin_c = bwmorph(bin,'remove');
bin_l = logical(damaged_leaf_out(:,:,2));

bin_f = bin_c & ~bin_l;
bin_f2 = bwareaopen(bin_f,10);

se = strel('square',2);
bin_f2 = imdilate(bin_f2, se);

% only damaged leaf regions that are in the leaf model
damaged_leaf_out_based_model = damaged_leaf_out.*leaf_model_mask;

overlay = imoverlay(uint8(damaged_leaf_out_based_model), bin_f2, 'r');
figure; imshow(overlay);

