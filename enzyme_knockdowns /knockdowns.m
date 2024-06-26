function matrix_of_fluxes = knockdowns(j,cc)
% will_code_double.m runs the combination knockdowns for a given first reaction
% (j) and second reaction (cc). It returns matrix_of_fluxes (cell). 

%Number of evenly spaced points of enzyme knockout percentage from 0%-100%, 
% eg. if numpoints=4, 0% 33% 66% 100%.
%I set this to 2, so it calculates 0% knockdown and 100% knockdown. 

%disp(['Combination of ', j, 'and', cc]);

number_of_increments = 2;

matrix_of_fluxes = cell(1,number_of_increments);
biomass_fluxes = cell(1,number_of_increments);
knockdown_percents = zeros(1,number_of_increments); %Matrix that saves percentages of enzyme knockouts


disp(['Simulating combination knockdown of reaction ' num2str(j) 'and reaction ' num2str(cc)]);

for y = 1:number_of_increments
    percent = round(((y*(1/(number_of_increments-1))) - (1/(number_of_increments-1))),1); %percent in decimal form of enzyme knockout, saved in matrix
    knockdown_percents(1,y) = percent;
    disp(['Inhibition of ', num2str(percent * 100), '%']);


% Load in the baseline data, calculated from original flux balance analysis.     
folder_path_lst = {['baselineData/WT_vs_KRAS_CRC_media/'], ['baselineData/WT_vs_KRAS_CAF_media/'], ...
    ['baselineData/WT_CRC_media_vs_CAF_media/'], ['baselineData/KRAS_CRC_media_vs_CAF_media/']};  

conditions_lst = {{'WT', 'KRAS'}, {'WT', 'KRAS'}, ...
    {'CRC media', 'CAF media'}, {'CRC media', 'CAF media'}};
title_name_lst = {'WT vs KRAS in CRC media', 'WT vs KRAS in CAF media', ...
    'WT in CRC media vs CAF media', 'KRAS in CRC media vs CAF media'};


% Separate out the flux values from the baseline data.

for z=1:2
    if z==1
        %load('KRAS_CRC_media_vs_CAF_media/data.mat');
        load('baselineData/KRAS_CRC_media_vs_CAF_media/data.mat');
        KRAS_CRC=data(:,1:2:end);
        KRAS_CCM=data(:,2:2:end);
    end
    if z==2
        %load('WT_CRC_media_vs_CAF_media/data.mat');
        load('baselineData/WT_CRC_media_vs_CAF_media/data.mat');
        WT_CRC=data(:,1:2:end);
        WT_CCM=data(:,2:2:end);
    end
end

% Define the condition names
condition_names = {'WT CRC', 'KRAS CAF', 'WT CAF', 'KRAS CRC'};

b_nonzero_indices_mat = zeros(4, 100, 74, 89);  % 4 conditions, 100 sets of mass balance constraints, 74 reactions, 89 metabolites
knockdown_biomass_mat = cell(4, 100, 1);
for i=1:4    % i=1, WT(CRC-only media); i=2, KRAS(CRC-CAF media); i=3, WT(CRC-CAF media); i=4, KRAS(CRC-only media), this is the correct order
    %disp(i)
    disp(['Condition: ' condition_names{i}]);
    data_path = [folder_path_lst{i} 'data.mat'];
    load(data_path);
    for k=1:100
        %disp(k)
        if (i == 2) || (i == 3)
            model = KRAS_Model.model_lst{1, k};
            model.b(82) = KRAS_Model.v_lst(73, k);
        else
            model = WT_Model.model_lst{1, k};
            model.b(82) = WT_Model.v_lst(73, k);
        end
        model.b(72) = 0;
  
        %4 if statements that give fractional enzyme knockouts depending on
        %condition being used
        if i==1
            if percent == 1  %  Check if inhibition is 100%; if this is the case, fully shut down both the bounds to knock the enzyme out 
                    tmp_model = changeRxnBounds(model, {model.rxns{j}, model.rxns{cc}}, [0, 0], {'b', 'b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CRC(:,j)) > 0 && mean(WT_CRC(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CRC(:,j)))*(1-percent),(mean(WT_CRC(:,cc)))*(1-percent)], {'u','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(WT_CRC(:,j)) < 0 && mean(WT_CRC(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CRC(:,j)))*(1-percent),(mean(WT_CRC(:,cc)))*(1-percent)], {'l','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(WT_CRC(:,j)) > 0 && mean(WT_CRC(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CRC(:,j)))*(1-percent),(mean(WT_CRC(:,cc)))*(1-percent)], {'u','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max'); 
            elseif  mean(WT_CRC(:,j)) <= 0 && mean(WT_CRC(:,cc)) <= 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CRC(:,j)))*(1-percent),(mean(WT_CRC(:,cc)))*(1-percent)], {'l','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CRC(:,j)) == 0 && mean(WT_CRC(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(WT_CRC(:,cc)))*(1-percent)], {'b','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CRC(:,j)) == 0 && mean(WT_CRC(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(WT_CRC(:,cc)))*(1-percent)], {'b','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CRC(:,j)) > 0 && mean(WT_CRC(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CRC(:,j)))*(1-percent), 0], {'u','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CRC(:,j)) < 0 && mean(WT_CRC(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CRC(:,j)))*(1-percent), 0], {'l','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CRC(:,j)) == 0 && mean(WT_CRC(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, 0], {'b','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            end

        end
        if i==2
            if percent == 1  % Check if inhibition is 100%; if this is the case, fully shut down both the bounds to knock the enzyme out 
                    tmp_model = changeRxnBounds(model, {model.rxns{j}, model.rxns{cc}}, [0, 0], {'b', 'b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CCM(:,j)) > 0 && mean(KRAS_CCM(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CCM(:,j)))*(1-percent),(mean(KRAS_CCM(:,cc)))*(1-percent)], {'u','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(KRAS_CCM(:,j)) < 0 && mean(KRAS_CCM(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CCM(:,j)))*(1-percent),(mean(KRAS_CCM(:,cc)))*(1-percent)], {'l','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(KRAS_CCM(:,j)) > 0 && mean(KRAS_CCM(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CCM(:,j)))*(1-percent),(mean(KRAS_CCM(:,cc)))*(1-percent)], {'u','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max'); 
            elseif  mean(KRAS_CCM(:,j)) <= 0 && mean(KRAS_CCM(:,cc)) <= 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CCM(:,j)))*(1-percent),(mean(KRAS_CCM(:,cc)))*(1-percent)], {'l','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CCM(:,j)) == 0 && mean(KRAS_CCM(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(KRAS_CCM(:,cc)))*(1-percent)], {'b','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CCM(:,j)) == 0 && mean(KRAS_CCM(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(KRAS_CCM(:,cc)))*(1-percent)], {'b','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CCM(:,j)) > 0 && mean(KRAS_CCM(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CCM(:,j)))*(1-percent), 0], {'u','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CCM(:,j)) < 0 && mean(KRAS_CCM(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CCM(:,j)))*(1-percent), 0], {'l','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CCM(:,j)) == 0 && mean(KRAS_CCM(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, 0], {'b','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            end 
        end
        if i==3
             if percent == 1  %  Check if inhibition is 100%; if this is the case, fully shut down both the bounds to knock the enzyme out 
                    tmp_model = changeRxnBounds(model, {model.rxns{j}, model.rxns{cc}}, [0, 0], {'b', 'b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CCM(:,j)) > 0 && mean(WT_CCM(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CCM(:,j)))*(1-percent),(mean(WT_CCM(:,cc)))*(1-percent)], {'u','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(WT_CCM(:,j)) < 0 && mean(WT_CCM(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CCM(:,j)))*(1-percent),(mean(WT_CCM(:,cc)))*(1-percent)], {'l','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(WT_CCM(:,j)) > 0 && mean(WT_CCM(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CCM(:,j)))*(1-percent),(mean(WT_CCM(:,cc)))*(1-percent)], {'u','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(WT_CCM(:,j)) <= 0 && mean(WT_CCM(:,cc)) <= 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CCM(:,j)))*(1-percent),(mean(WT_CCM(:,cc)))*(1-percent)], {'l','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CCM(:,j)) == 0 && mean(WT_CCM(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(WT_CCM(:,cc)))*(1-percent)], {'b','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CCM(:,j)) == 0 && mean(WT_CCM(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(WT_CCM(:,cc)))*(1-percent)], {'b','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CCM(:,j)) > 0 && mean(WT_CCM(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CCM(:,j)))*(1-percent), 0], {'u','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CCM(:,j)) < 0 && mean(WT_CCM(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(WT_CCM(:,j)))*(1-percent), 0], {'l','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(WT_CCM(:,j)) == 0 && mean(WT_CCM(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, 0], {'b','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            end 
        end
        if i==4
             if percent == 1  %  Check if inhibition is 100%; if this is the case, fully shut down both the bounds to knock the enzyme out 
                    tmp_model = changeRxnBounds(model, {model.rxns{j}, model.rxns{cc}}, [0, 0], {'b', 'b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CRC(:,j)) > 0 && mean(KRAS_CRC(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CRC(:,j)))*(1-percent),(mean(KRAS_CRC(:,cc)))*(1-percent)], {'u','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(KRAS_CRC(:,j)) < 0 && mean(KRAS_CRC(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CRC(:,j)))*(1-percent),(mean(KRAS_CRC(:,cc)))*(1-percent)], {'l','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max'); 
            elseif  mean(KRAS_CRC(:,j)) > 0 && mean(KRAS_CRC(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CRC(:,j)))*(1-percent),(mean(KRAS_CRC(:,cc)))*(1-percent)], {'u','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif  mean(KRAS_CRC(:,j)) <= 0 && mean(KRAS_CRC(:,cc)) <= 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CRC(:,j)))*(1-percent),(mean(KRAS_CRC(:,cc)))*(1-percent)], {'l','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CRC(:,j)) == 0 && mean(KRAS_CRC(:,cc)) > 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(KRAS_CRC(:,cc)))*(1-percent)], {'b','u'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CRC(:,j)) == 0 && mean(KRAS_CRC(:,cc)) < 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, (mean(KRAS_CRC(:,cc)))*(1-percent)], {'b','l'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CRC(:,j)) > 0 && mean(KRAS_CRC(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CRC(:,j)))*(1-percent), 0], {'u','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CRC(:,j)) < 0 && mean(KRAS_CRC(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [(mean(KRAS_CRC(:,j)))*(1-percent), 0], {'l','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            elseif mean(KRAS_CRC(:,j)) == 0 && mean(KRAS_CRC(:,cc)) == 0
                    tmp_model = changeRxnBounds(model, {model.rxns{j},model.rxns{cc}}, [0, 0], {'b','b'});
                    tmp_sol = optimizeCbModel(tmp_model, 'max');
            end 
        end
            if ~tmp_sol.stat
                relaxOption.internalRelax = 0;
                relaxOption.exchangeRelax = 0;
                relaxOption.steadyStateRelax = 1;
                relaxOption.epsilon = 10e-6;
                mets_to_exclude = false(size(tmp_model.mets));          
                mets_to_exclude(contains(tmp_model.mets, "_greater")) = true;
                mets_to_exclude(contains(tmp_model.mets, "_lower")) = true;
                relaxOption.excludedMetabolites = mets_to_exclude;
                try 
                    solution = relaxedFBA(tmp_model,relaxOption);
                    [stat,v,r,p,q] = deal(solution.stat, solution.v, solution.r, solution.p, solution.q);
                catch ME
                    disp('No feasible solution found.:');
                    disp(ME.message);
                    stat = 0;
                end
                if stat == 0
                    v = zeros(size(tmp_model.rxns));
                    r = zeros(size(tmp_model.mets));
                    p = zeros(size(tmp_model.rxns));
                    q = zeros(size(tmp_model.rxns));
                    %knockdown_biomass_mat{i, k, j} = NaN;
                    knockdown_biomass_mat{i, k, j} = 0;
                else
                    b_nonzero_indices = find(r ~= 0);
                    b_nonzero_values = r(b_nonzero_indices);
                    b_nonzero_indices_mat(i, k, j, b_nonzero_indices) = b_nonzero_indices_mat(i, k, j, b_nonzero_indices)+1;
                    for m = 1:numel(b_nonzero_indices)
                        tmp_model.b(b_nonzero_indices(m)) = tmp_model.b(b_nonzero_indices(m)) - b_nonzero_values(m);
                    end    
                    solutionDel = optimizeCbModel(tmp_model, 'max');
                    stat = solutionDel.stat;
                    if stat == 1
                       v = solutionDel.x;                      
                       if solutionDel.f > 0
                           knockdown_biomass_mat{i, k, j} = solutionDel.v;
                       else
                           knockdown_biomass_mat{i, k, j} = 0;
                       end
                    else
                       v = zeros(size(tmp_model.rxns));
                       r = zeros(size(tmp_model.mets));
                       p = zeros(size(tmp_model.rxns));
                       q = zeros(size(tmp_model.rxns));
                       %knockdown_biomass_mat{i, k, j} = NaN;
                       knockdown_biomass_mat{i, k, j} = 0;
                    end
                end
            else
                if tmp_sol.f > 0
                    knockdown_biomass_mat{i, k, j} = tmp_sol.v;
                else
                    knockdown_biomass_mat{i, k, j} = 0;
                end
            end
        end
end


%Save Biomass production and put into matrix
A=knockdown_biomass_mat(:,:,j);
assignin('base', 'A', A);
B=zeros(4,100);
for l=1:4
    for m=1:100
        if A{l,m}==0
            B(l,m)=0;
        else
            B(l,m)=A{l,m}(73);
            assignin('base', 'B', B);
        end
    end
end
biomass_fluxes{1,y}=B';

%Save fluxes and put into matrix
C=zeros(4,100,74);
for l=1:4
    for m=1:100
        for n=1:74
            if A{l,m}==0
                C(l,m,n)=0;
            else
                C(l,m,n)=A{l,m}(n);
                assignin('base', 'C', C);
            end
        end
    end
end
matrix_of_fluxes{1,y}=squeeze(mean(C,2));
end
end 