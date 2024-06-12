close all;
clear all;
clc;
rng(0) % same set of random integers each time simulation is ran
initCobraToolbox(false);
changeCobraSolver('glpk');

% Change these to be where *your* cobratoolbox is stored, and where your
% code for the knockdowns is stored. 
addpath('/Users/nikitavakoli/cobratoolbox')
addpath('/Users/nikitavakoli/desktop/new_code')

%% For specific combo knockdowns we want to do
% all_reaction_fluxes_percentage=cell(1,74);
% tic % record time elapsed for each reaction knockdown
% 
%     %disp(['knockout number: ', num2str(jj)])
%     all_reaction_fluxes_percentage{1,1} = knockdowns(2,9);
%     save('/Users/nikitavakoli/Desktop/new_code/results/2_5.mat');
%     toc


% all_reaction_fluxes_percentage = cell(1,1);
% combo_index = 1;  % To index each combination uniquely

% for i = 1:74  % First reaction
%     if ismember(i, [1, 44, 61])  % Skip if i is 1, 44, or 61; these are hard constraints and the system will not produce flux if they are knocked out. 
%         continue
%     end
%     for j = i+1:74  % Second reaction, starting from i+1 ensures all pairs are unique
%         if ismember(j, [1, 44, 61])  % Skip if j is 1, 44, or 61; these are hard constraints and the system will not produce flux if they are knocked out. 
%             continue
%         end
%         tic;  % Start timing
%         all_reaction_fluxes_percentage{1,combo_index} = knockdowns(i, j);
%         %Change the path below so it stores it where you want 
%         save_filename = sprintf('/Users/nikitavakoli/Desktop/new_code/results/double_KO_%d_%d.mat', i, j);
%         save(save_filename);
%         toc;  % End timing
%         combo_index = combo_index + 1;  % Increment the combination index
%     end
% end


% Initialize the storage for all knockdown results
all_reaction_fluxes_percentage = cell(1, 2701);  % Pre-allocate assuming maximum number of combinations
combo_index = 1;  % To index each combination uniquely

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

% Save all results in one file after the loop (Make a results directory 
% to save these directly in here, but change the
% location of the path for you.
save('/Users/nikitavakoli/Desktop/new_code/results/all_combinations_knockdowns.mat', 'all_reaction_fluxes_percentage');


