close all;
clear all;
clc;
rng(0) % Same set of random integers each time simulation is ran
initCobraToolbox(false);
changeCobraSolver('glpk');

%%
all_reaction_fluxes_percentage=cell(1,74);
tic % record time elapsed for each reaction knockdown
for jj=1:74
    disp(['---------------Knockdown of reaction: ', num2str(jj)]);
    all_reaction_fluxes_percentage{1,jj} = gene_knockdowns_pars(jj);
    disp('Done.')
    save('data.mat')
    toc
end

