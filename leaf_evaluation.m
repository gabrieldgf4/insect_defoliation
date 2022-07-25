
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano (BRAZIL) - 2022) 
%

function [confusionMatrix_pixels, resultRates_pixels, resultSDT, overlap] = leaf_evaluation(leaf_model, healthy_leaf_to_model)

[~,~,c1] = size(leaf_model);
[~,~,c2] = size(healthy_leaf_to_model);

eps = 10^(-6); % very small constant

if c1==3
    leaf_model_mask = logical(leaf_model(:,:,2));
else
    leaf_model_mask = logical(leaf_model);
end  
    
if c2==3
    gt = logical(healthy_leaf_to_model(:,:,2));
else
    gt = logical(healthy_leaf_to_model);
end


%---------
% Rates by using Set Theory, evaluation by pixels 

% True-Positive, says it is tree and it is tree
% n(A intersec B)
TP = sum(sum(gt & leaf_model_mask));

% False-Positive, says it is tree but it is not tree
% n(~A intersec B)
FP = sum(sum(~gt & leaf_model_mask));

% False-Negative, says it is not tree but it is tree
% n(A intersec ~B)
FN = sum(sum(gt & ~leaf_model_mask));

% True-Negative, says it is not tree and it is not tree
% n(~A intersec ~B)
TN = sum(sum(~gt & ~leaf_model_mask));

% sensitivity, recall, hit rate, or true positive rate (TPR)
% n(A intersec B) / n(A)
TPR = sum(sum(gt & leaf_model_mask)) / ( sum(sum(gt)) + eps );

% specificity, selectivity or true negative rate (TNR)
% n(~A intersec ~B) / n(~A)
TNR = sum(sum(~gt & ~leaf_model_mask)) / ( sum(sum(~gt)) + eps );

% precision or positive predictive value (PPV)
% n(A intersec B) / n(B)
PPV = sum(sum(gt & leaf_model_mask)) / ( sum(sum(leaf_model_mask)) + eps );

% negative predictive value (NPV)
% n(~A intersec ~B) / n(~B)
NPV = sum(sum(~gt & ~leaf_model_mask)) / ( sum(sum(~leaf_model_mask))  + eps );

% miss rate or false negative rate (FNR)
% False-Negative Rate (says it isnt tree, but it is)
% fNegativeRate = n[A - (A intersec B)] / n[A]
FNR = (sum(sum(gt - (gt & leaf_model_mask)))) / ( sum(sum(gt)) + eps );    

% fall-out or false positive rate (FPR)
% False-Positive Rate (says it is tree, but it is not)
% fPositiveRate = n[B - (B intersec A)] / n[~A]
FPR = (sum(sum(leaf_model_mask - (leaf_model_mask & gt)))) / ( sum(sum(~gt)) + eps ); 

% false discovery rate (FDR)
% n(~A intersec B) / n(B)
FDR = sum(sum(~gt & leaf_model_mask)) / ( sum(sum(leaf_model_mask)) + eps );

% false omission rate (FOR)
% n(A intersec ~B) / n(~B)
FOR = sum(sum(gt & ~leaf_model_mask)) / ( sum(sum(~leaf_model_mask)) + eps );

% accuracy (ACC)
% n(A intersec B) + n(~A intersec ~B) / n(A) + n(~A)
ACC = (sum(sum(gt & leaf_model_mask)) + sum(sum(~gt & ~leaf_model_mask))) / ( (sum(sum(gt)) + sum(sum(~gt))) + eps );

% bookmaker informedness
BM = (TPR + TNR) - 1;

% F1 score
F1_score = 2*((PPV * TPR) / (PPV + TPR));

confusionMatrix_pixels = [ TP, FP, TN, FN ];
resultRates_pixels = [ TPR, TNR, PPV, NPV, FNR, FPR, FDR, FOR, ACC, BM, F1_score ];


%--------
% Signal Detection Theory - SDT
[zH, zF, dprime, Adprime, Aprime, Beta, c, Btwoprime] = ...
signal_detection_theory(TPR,FPR);

resultSDT = [ zH, zF, dprime, Adprime, Aprime, Beta, c, Btwoprime ];


%---------
% Calculate the overlap
% calc the Qseg
Qseg = sum(sum(leaf_model_mask & gt)) / ( sum(sum(leaf_model_mask | gt)) + eps );  

% calc the Sr
Sr = sum(sum(leaf_model_mask & gt)) / ( sum(sum(gt)) + eps );

% calc the Es
Es = sum(sum(leaf_model_mask & ~gt)) / ( sum(sum(gt)) + eps );

overlap = [ Qseg, Sr, Es ];
 

end