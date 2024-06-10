close all;
clear all;
clc;
rng(0) % same set of random integers each time simulation is ran
initCobraToolbox(false);
changeCobraSolver('glpk');

%If installed, use Gurobi! (much faster)
% changeCobrasolver('gurobi');

%% For specific combo knockdowns we want to do
%all_reaction_fluxes_percentage=cell(1,74);
%tic % record time elapsed for each reaction knockdown

    %disp(['knockout number: ', num2str(jj)])
    %all_reaction_fluxes_percentage{1,1} = will_code_double(2,31);
    %save('double_knockdowns/double_KO_2_31.mat')
    %toc

%% For all pairwise knockdowns
% Create  a large cell to store results in
all_reaction_fluxes_percentage = cell(74, 74);
tic % Record time elapsed for the entire process

for j = 1:74
    for cc = 1:74
        if j ~= cc % Ensure that we don't knockdown the same reaction twice
            disp(['Combination knockdown of reactions: ', num2str(j), ' and ', num2str(cc)])
            all_reaction_fluxes_percentage{j, cc} = double_enzyme_knockdowns(j, cc);
            save(['pairwise_knockdown_results', num2str(j), '_', num2str(cc), '.mat'])
        end
    end
end

