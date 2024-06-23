close all;
clear all;
clc;
rng(0) % same set of random integers each time simulation is ran
initCobraToolbox(false);
changeCobraSolver('gurobi');
% changeCobraSolver('glpk');

% Change these to be where *your* cobratoolbox is stored, and where your
% code for the knockdowns is stored. 
addpath('/Users/nikitavakoli/cobratoolbox')
addpath('/Users/nikitavakoli/desktop/new_code')


% Initialize the storage for all knockdown results
all_reaction_fluxes_percentage = cell(1, 2701);  % Pre-allocate assuming maximum number of combinations
combo_index = 1;  % To index each combination uniquely

% % For specific combo knockdowns we want to do
% tic;
% all_reaction_fluxes_percentage{1, 1} = knockdowns(4, 36);
% toc;

% Loop over all unique reaction pairs
for i = 1:74
    if ismember(i, [1, 44, 61])  % Skip certain reactions with hard constraints
        continue
    end
    for j = i+1:74
        if ismember(j, [1, 44, 61])  % Also skip these reactions for the second reaction
            continue
        end
        tic;  % Start timing the operation
        all_reaction_fluxes_percentage{1, combo_index} = knockdowns(i, j);
        toc;  % End timing
        combo_index = combo_index + 1;  % Increment for the next combination
    end
end


% Save all results in one file after the loop
% *(Make a results directory to save these directly in here, but change the
% location of the path for you)*
save('/Users/nikitavakoli/Desktop/all_combinations_knockdowns.mat', 'all_reaction_fluxes_percentage');


