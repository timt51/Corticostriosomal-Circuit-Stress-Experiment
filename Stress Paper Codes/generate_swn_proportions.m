%% This script generates graphs of proportions of HFNs/SWNs out of all DMS
%% Get Data Per Rat
firing_rates = cell(1,length(dbs));
fsi_hfn_counts = {};
for db = 1:length(dbs)
    % Only analyze neurons with good waveforms; that is, do not analyze
    % neurons that have uncalculatable features.
    twdb = twdbs{db};
    load(['snr_' dbs{db} '.mat']);
    snr_nan = snr_parameters{11};
    nans = isnan(snr_nan);
    neuron_ids = neuron_ids(~nans); neuron_ids = cellfun(@str2num, neuron_ids);
    
    ratIDs = unique({twdb.ratID});
    disp(ratIDs);
    
    % For FSIs
    for j = 1:length(ratIDs)
        ids_of_rat = neuron_ids(strcmp({twdb(neuron_ids).ratID},ratIDs{j}));
        fsi_ids_of_rat = all_swn_ids{db}(strcmp({twdb(all_swn_ids{db}).ratID},ratIDs{j}));
        if ~isempty(fsi_ids_of_rat)
            firing_rates{db}{j} = [twdb(fsi_ids_of_rat).firing_rate];
            
            fsis = length(firing_rates{db}{j});
            high_firing_rate = sum(firing_rates{db}{j} > 6);
            total = length(ids_of_rat);
            fsi_hfn_counts{db}{j} = [fsis, high_firing_rate, total];
        else
            fsi_hfn_counts{db}{j} = [0 0 1];
        end
    end
end

proportions_fsi = cell(1,length(dbs)); % per animal
proportions_fsi_hfn = cell(1,length(dbs));
for db = 1:length(fsi_hfn_counts)
    for j = 1:length(fsi_hfn_counts{db})
        if ~isempty(fsi_hfn_counts{db}{j})
            proportions_fsi{db} = [proportions_fsi{db} fsi_hfn_counts{db}{j}(1)/fsi_hfn_counts{db}{j}(3)];
            proportions_fsi_hfn{db} = [proportions_fsi_hfn{db} fsi_hfn_counts{db}{j}(2)/fsi_hfn_counts{db}{j}(3)];
        end
    end
end
few_neurons = find(arrayfun(@(x)x{1}(3),fsi_hfn_counts{1})<200);

proportions_fsi{1} = proportions_fsi{1}(setdiff(1:14,few_neurons)); % Remove rats with no histology [1 2 4 8]

str = {'Control'; 'Stress'; 'Stress2'};

means_fsi = [mean(proportions_fsi{1}), mean(proportions_fsi{2}), mean(proportions_fsi{3})];
stderrs_fsi = [std(proportions_fsi{1})/sqrt(length(proportions_fsi{1})), ...
                std(proportions_fsi{2})/sqrt(length(proportions_fsi{2})), ...
                std(proportions_fsi{3})/sqrt(length(proportions_fsi{3}))];
f = figure; barwitherr(stderrs_fsi,means_fsi);
[~,p1] = ttest2(proportions_fsi{1}, proportions_fsi{2});
[~,p2] = ttest2(proportions_fsi{1}, proportions_fsi{3});
[~,p3] = ttest2(proportions_fsi{1},[proportions_fsi{2} proportions_fsi{3}]);
hold on;
scatter(ones(1,length(proportions_fsi{1})),proportions_fsi{1},100,'*');
scatter(ones(1,length(proportions_fsi{2}))*2,proportions_fsi{2},100,'*');
scatter(ones(1,length(proportions_fsi{3}))*3,proportions_fsi{3},100,'*');
hold off;
set(gca, 'XTickLabel',str, 'XTick',1:numel(str));
xlabel('Experimental Group');
ylabel('Proportion of Short Width Neurons');
title({'Proportion of Short Width Neurons Across Experimental Groups (Per Rat)', ...
        'Removing Rats With < 200 Neurons Total', 'Final Michael Grades 1-5', ...
        ['Control vs Stress ttest2 p = ' num2str(p1)], ...
        ['Control vs Stress2 ttest2 p = ' num2str(p2)], ...
        ['Combining Stress and Stress2 ttest2 p = ' num2str(p3)]});
text(1,.23,['n = ' num2str(sum(arrayfun(@(x)x{1}(1),fsi_hfn_counts{1}(setdiff(1:14,few_neurons)))))]);
text(2,.23,['n = ' num2str(sum(arrayfun(@(x)x{1}(1),fsi_hfn_counts{2})))]);
text(3,.23,['n = ' num2str(sum(arrayfun(@(x)x{1}(1),fsi_hfn_counts{3})))]);
saveas(f, [ROOT_DIR 'Clustering/Short Width Neurons Count'], 'fig');
saveas(f, [ROOT_DIR 'Clustering/Short Width Neurons Count'], 'epsc2');
saveas(f, [ROOT_DIR 'Clustering/Short Width Neurons Count'], 'jpg');

proportions_fsi_hfn{1} = proportions_fsi_hfn{1}(setdiff(1:14,few_neurons)); % Remove rats with no histology
means_fsi = [mean(proportions_fsi_hfn{1}), mean(proportions_fsi_hfn{2}), mean(proportions_fsi_hfn{3})];
stderrs_fsi = [std(proportions_fsi_hfn{1})/sqrt(length(proportions_fsi_hfn{1})), ...
                std(proportions_fsi_hfn{2})/sqrt(length(proportions_fsi_hfn{2})), ...
                std(proportions_fsi_hfn{3})/sqrt(length(proportions_fsi_hfn{3}))];
f = figure; barwitherr(stderrs_fsi,means_fsi);
[~,p1] = ttest2(proportions_fsi_hfn{1}, proportions_fsi_hfn{2});
[~,p2] = ttest2(proportions_fsi_hfn{1}, proportions_fsi_hfn{3});
[~,p3] = ttest2(proportions_fsi_hfn{1},[proportions_fsi_hfn{2} proportions_fsi_hfn{3}]);
hold on;
scatter(ones(1,length(proportions_fsi_hfn{1})),proportions_fsi_hfn{1},100,'*');
scatter(ones(1,length(proportions_fsi_hfn{2}))*2,proportions_fsi_hfn{2},100,'*');
scatter(ones(1,length(proportions_fsi_hfn{3}))*3,proportions_fsi_hfn{3},100,'*');
hold off;
set(gca, 'XTickLabel',str, 'XTick',1:numel(str));
xlabel('Experimental Group');
ylabel('Proportion of High Firing Neurons (> 6 Hz)');
title({'Proportion of High Firing Neurons (> 6 Hz) Across Experimental Groups (Per Rat)', ...
        'Removing Rats With < 200 Neurons Total', 'Final Michael Grades 1-5', ...
        ['Control vs Stress ttest2 p = ' num2str(p1)], ...
        ['Control vs Stress2 ttest2 p = ' num2str(p2)], ...
        ['Combining Stress and Stress2 ttest2 p = ' num2str(p3)]});
text(1,.045,['n = ' num2str(sum(arrayfun(@(x)x{1}(2),fsi_hfn_counts{1}(setdiff(1:14,few_neurons)))))]);
text(2,.045,['n = ' num2str(sum(arrayfun(@(x)x{1}(2),fsi_hfn_counts{2})))]);
text(3,.045,['n = ' num2str(sum(arrayfun(@(x)x{1}(2),fsi_hfn_counts{3})))]);
saveas(f, [ROOT_DIR 'Clustering/High Firing Neurons Count'], 'fig');
saveas(f, [ROOT_DIR 'Clustering/High Firing Neurons Count'], 'epsc2');
saveas(f, [ROOT_DIR 'Clustering/High Firing Neurons Count'], 'jpg');