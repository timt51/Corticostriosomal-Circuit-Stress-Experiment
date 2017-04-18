%% This script generates figures that compare proportion of HFNs vs response to stress*
% *See Hope's excel sheet
%% Count SWNs and HFNs per rat
dms_ids = cellfun(@(twdb) find(strcmp({twdb.tetrodeType},'dms') & [twdb.final_michael_grade] >= 1), twdbs, 'uni', false);
BLstart = 60; BLend = 240;
window_starts = [316,316,321,321,310,310];
window_ends = [330,330,335,335,320,320];
neuron_type_overall_FRs = cell(1,length(neuron_types));
neuron_type_baseline_FRs = cell(1,length(neuron_types));
neuron_type_num_per_rat = cell(1,length(neuron_types));

for neuron_type_idx = 5:6 % Only look at SWNs and HFNs
    neuron_type_overall_FRs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_baseline_FRs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_num_per_rat{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_ids = all_ids{neuron_type_idx};
    
    for db = 1:length(dbs)
        load(['snr_' dbs{db} '.mat']);
        snr_nan = snr_parameters{11};
        nans = isnan(snr_nan);
        neuron_ids = neuron_ids(~nans); neuron_ids = cellfun(@str2num, neuron_ids);
        
        ratIDs = unique({twdbs{db}.ratID}); disp(dbs{db}); disp(ratIDs);
        neuron_type_overall_FRs{neuron_type_idx}{db} = cell(1,length(ratIDs));
        neuron_type_baseline_FRs{neuron_type_idx}{db} = cell(1,length(ratIDs));
        neuron_type_num_per_rat{neuron_type_idx}{db} = zeros(1,length(ratIDs));
        
        for rat_idx = 1:length(ratIDs)
            ids_of_rat = neuron_type_ids{db}(strcmp({twdbs{db}(neuron_type_ids{db}).ratID},ratIDs{rat_idx}));
            
            for neuron_idx = 1:length(ids_of_rat)
                [zscore, ~, BLmean, ~, FR, ~] = quantify_neuron_activity(twdbs{db},...
                    ids_of_rat(neuron_idx),'spikes',...
                    BLstart,BLend,window_starts(neuron_type_idx),...
                    window_ends(neuron_type_idx));
                neuron_type_baseline_FRs{neuron_type_idx}{db}{rat_idx} = [neuron_type_baseline_FRs{neuron_type_idx}{db}{rat_idx} BLmean];
            end
            
            neuron_type_overall_FRs{neuron_type_idx}{db}{rat_idx} = [twdbs{db}(ids_of_rat).firing_rate];
            
            all_ids_of_rat = dms_ids{db}(strcmp({twdbs{db}(dms_ids{db}).ratID},ratIDs{rat_idx}));
            neuron_type_num_per_rat{neuron_type_idx}{db}(rat_idx) = length(intersect(all_ids_of_rat, dms_ids{db}));
        end
    end
end
%% Plots
f = figure;
%% With stress 8 removed
%% Compare effect of stress vs proportion of HFNs
% Compute proportion of FSI that are HFN per rat
subplot(1,3,1);
proportions = cell(1,length(dbs));
for db = 2:length(dbs)
    for ratIdx = 1:length(neuron_type_overall_FRs{5}{db})
        proportions{db} = [proportions{db} sum(neuron_type_overall_FRs{6}{db}{ratIdx}>=6)/neuron_type_num_per_rat{6}{db}(ratIdx)];
    end
end
proportions = [proportions{2} proportions{3}([3 4 1 2])]; proportions(6) = [];
stress_response = [.3459 .3539 .2979 .4635 .1840 .0890 .3288 .2740 .3288]; stress_response(6) = [];

hold on;
scatter(stress_response, proportions);

[r1,m1,b1]=regression(stress_response,proportions);
[cor, p] = corr(stress_response',proportions','tail','left');

X_range=min(stress_response):0.01:max(stress_response);
Y_proportions=X_range*m1+b1;
plot(X_range,Y_proportions,'b');
hold off;

title({'Alternative Hypothesis: Correlation Is Less Than Zero (One Tailed Test)'
        ['Pearson Corr Coef: ' num2str(cor) ' P = ' num2str(p) '/// Slope: ' num2str(m1)]});
xlabel('Response To Stress (Mean % Choice of Mixture For Control Rats - % Choice of Mixture (Per Stress Rat))');
ylabel('Proportion of HFNs (Firing Rate > 6Hz)');
xlim([0 .5]); ylim([0 .04]);

%% Compare effect of stress vs proportion of FSIs
subplot(1,3,2);
proportions = cell(1,length(dbs));
for db = 2:length(dbs)
    for ratIdx = 1:length(neuron_type_overall_FRs{5}{db})
        proportions{db} = [proportions{db} length(neuron_type_overall_FRs{6}{db}{ratIdx})/neuron_type_num_per_rat{6}{db}(ratIdx)];
    end
end
proportions = [proportions{2} proportions{3}([3 4 1 2])]; proportions(6) = [];
stress_response = [.3459 .3539 .2979 .4635 .1840 .0890 .3288 .2740 .3288]; stress_response(6) = [];

hold on;
scatter(stress_response, proportions);

[r1,m1,b1]=regression(stress_response,proportions);
[cor, p] = corr(stress_response',proportions','tail','left');

X_range=min(stress_response):0.01:max(stress_response);
Y_proportions=X_range*m1+b1;
plot(X_range,Y_proportions,'b');
hold off;

title({['CorrCoef: ' num2str(cor) ' P = ' num2str(p) '/// Slope: ' num2str(m1)]});
ylabel('Proportion of FSIs');
xlim([0 .5]); ylim([0 .4]);

%% Compare effect of stress vs mean firing rate of FSIs
subplot(1,3,3);
proportions = cell(1,length(dbs));
for db = 2:length(dbs)
    for ratIdx = 1:length(neuron_type_overall_FRs{5}{db})        
        proportions{db} = [proportions{db} mean(neuron_type_overall_FRs{6}{db}{ratIdx})];
    end
end
proportions = [proportions{2} proportions{3}([3 4 1 2])]; proportions(6) = [];
stress_response = [.3459 .3539 .2979 .4635 .1840 .0890 .3288 .2740 .3288]; stress_response(6) = [];

hold on;
scatter(stress_response, proportions);

[r1,m1,b1]=regression(stress_response,proportions);
[cor, p] = corr(stress_response',proportions','tail','left');

X_range=min(stress_response):0.01:max(stress_response);
Y_proportions=X_range*m1+b1;
plot(X_range,Y_proportions,'b');
hold off;

title({['CorrCoef: ' num2str(cor) ' P = ' num2str(p) '/// Slope: ' num2str(m1)]});
ylabel('Mean Firing Rate of FSIs');
xlim([0 .5]); ylim([0 6]);

%% Save
fig_dir = [ROOT_DIR 'Behavioural/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir)
end
% set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
saveas(f, [fig_dir 'Correlations'], 'fig');
saveas(f, [fig_dir 'Correlations'], 'epsc2');
saveas(f, [fig_dir 'Correlations'], 'jpg');