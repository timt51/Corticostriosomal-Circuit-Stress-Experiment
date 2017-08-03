%% Find all PL and Striosomes in each session
pls_neurons = cell(1,length(dbs));
swn_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    pls_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    swn_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        pls_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_pls_ids{db} bbs_pls_ids{db}]);
        swn_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_strio_ids{db} bbs_strio_ids{db}]); % Striosomes instead!
    end
end
%% Find firing rates associated with each session
swn_activity_types = {'Baseline Firing Rate', 'In Task Zscore', 'In Task Firing Rate'};
pls_actvity_type = swn_activity_types{1};
swn_activity_type = swn_activity_types{3};
pls_BL_FRs = cell(1,length(dbs));   pls_counts = cell(1,length(dbs));
swn_BL_FRs = cell(1,length(dbs));   swn_counts = cell(1,length(dbs));

for db = 1:length(dbs)
    for sessionDir_idx = 1:length(pls_neurons{db})
        if ~isempty(pls_neurons{db}{sessionDir_idx}) && ~isempty(swn_neurons{db}{sessionDir_idx})
            % PLS
            if strcmp(pls_actvity_type, 'Baseline Firing Rate')
                pls_BL_FRs{db} = [pls_BL_FRs{db} mean(arrayfun(@(x) baseline_firing_rate(twdbs{db},x),pls_neurons{db}{sessionDir_idx}))];
            elseif strcmp(pls_actvity_type, 'In Task Zscore')
                pls_FRs = arrayfun(@(x) quantify_neuron_activity(twdbs{db},x,'spikes',60,240,301,315),pls_neurons{db}{sessionDir_idx});
                pls_BL_FRs{db} = [pls_BL_FRs{db} mean(pls_FRs)];
            elseif strcmp(pls_actvity_type, 'In Task Firing Rate')
                [~,~,~,~,pls_FRs,~] = arrayfun(@(x) quantify_neuron_activity(twdbs{db},x,'spikes',60,240,301,330),pls_neurons{db}{sessionDir_idx});
                pls_BL_FRs{db} = [pls_BL_FRs{db} mean(pls_FRs)];
            end
            pls_counts{db} = [pls_counts{db} length(pls_neurons{db}{sessionDir_idx})];
            
            % SWNs
            if strcmp(swn_activity_type, 'Baseline Firing Rate')
                swn_BL_FRs{db} = [swn_BL_FRs{db} mean(arrayfun(@(x) baseline_firing_rate(twdbs{db},x),swn_neurons{db}{sessionDir_idx}))];
            elseif strcmp(swn_activity_type, 'In Task Zscore')
                swn_FRs = arrayfun(@(x) quantify_neuron_activity(twdbs{db},x,'spikes',60,240,301,315),swn_neurons{db}{sessionDir_idx});
                swn_BL_FRs{db} = [swn_BL_FRs{db} mean(swn_FRs)];
            elseif strcmp(swn_activity_type, 'In Task Firing Rate')
                [~,~,~,~,swn_FRs,~] = arrayfun(@(x) quantify_neuron_activity(twdbs{db},x,'spikes',60,240,301,330),swn_neurons{db}{sessionDir_idx});
                swn_BL_FRs{db} = [swn_BL_FRs{db} mean(swn_FRs)];
            end
            swn_counts{db} = [swn_counts{db} length(swn_neurons{db}{sessionDir_idx})];
            
            % Remove bad sessions
            if isnan(pls_BL_FRs{db}(end)) || isnan(swn_BL_FRs{db}(end)) || isinf(pls_BL_FRs{db}(end)) || isinf(swn_BL_FRs{db}(end))
                pls_BL_FRs{db}(end) = [];
                swn_BL_FRs{db}(end) = [];
                pls_counts{db}(end) = [];
                swn_counts{db}(end) = [];
            end
        end
    end
end

%% Correlate baseline firing rates
f = figure;
subplot(2,2,1);
min_per_session = 2;
if strcmp(swn_activity_type,'In Task Zscore')
    min_swn_FR = 0;
    take_log = false;
else
    min_swn_FR = 0;
    take_log = true;
end
neuron_type = 'Striosome';
to_plot = true;

[true_p_value, true_slope, true_cor] = pls_hfn_FR_corr(pls_BL_FRs,swn_BL_FRs,pls_counts,swn_counts,min_per_session,min_swn_FR,take_log,neuron_type,pls_activity_type, swn_activity_type, to_plot);
%% Bootstrap
% Take a random permutation of sessions
to_plot = false;
shuffled_p_values = zeros(1,100);
shuffled_slopes = zeros(1,100);
shuffled_cors = zeros(1,100);
for y = 1:100
    pls_BL_FRs_tmp = cellfun(@(x) x(randperm(length(x))), pls_BL_FRs, 'uni',false);
    swn_BL_FRs_tmp = cellfun(@(x) x(randperm(length(x))), swn_BL_FRs, 'uni',false);

    [shuffled_p_values(y), shuffled_slopes(y), shuffled_cors(y)] = pls_hfn_FR_corr(pls_BL_FRs_tmp,swn_BL_FRs_tmp,pls_counts,swn_counts,min_per_session,min_swn_FR,take_log,neuron_type,pls_activity_type, swn_activity_type, to_plot);
end
%% Histogram of pvalues
subplot(2,2,2);
[N,centers] = hist(shuffled_cors,100);
bar(centers,N/sum(N),'FaceColor',rgb('RoyalBlue'),'EdgeColor','none');
line([true_cor, true_cor],[0,max(N/sum(N))],'Color','black','LineWidth',2);
title({'Distribution of Correlation Coefficients', ['Zscore of Original CorCoef = ' num2str((true_cor-mean(shuffled_cors)) / std(shuffled_cors))]});
xlabel('Correlation Coefficient'); ylabel('Frequency');
legend('Correlation Coefficients of Shuffled Data', 'CorCoef of Original Data','Location','NorthWest');

subplot(2,2,3);
[N,centers] = hist(log(shuffled_p_values),100);
bar(centers,N/sum(N),'FaceColor',rgb('RoyalBlue'),'EdgeColor','none');
line(log([true_p_value, true_p_value]),[0,max(N/sum(N))],'Color','black','LineWidth',2);
title({'Distribution of P Values', ['Proportion of More Extreme P Values (One-Tailed) = ' num2str(sum(log(shuffled_p_values)<log(true_p_value))/length(shuffled_p_values))]});
xlabel('log(P Value)'); ylabel('Frequency');
legend('P Values of Shuffled Data', 'P Value of Original Data','Location','NorthWest');

subplot(2,2,4);
[N,centers] = hist(shuffled_slopes,100);
bar(centers,N/sum(N),'FaceColor',rgb('RoyalBlue'),'EdgeColor','none');
line([true_slope, true_slope],[0,max(N/sum(N))],'Color','black','LineWidth',2);
title({'Distribution of Slopes', ['Zscore of Original Slope = ' num2str((true_slope-mean(shuffled_slopes)) / std(shuffled_slopes))]});
xlabel('Slope'); ylabel('Frequency');
legend('Slopes of Shuffled Data', 'Slope of Original Data','Location','NorthWest');

suptitle({'Parameters: ', ...
        ['At least ' num2str(min_per_session) ' PL neurons and Striosomes per session'], ...
        ['Removing points with Striosome firing rate <' num2str(min_swn_FR) ' Hz']});

% Save figure
fig_dir = [ROOT_DIR 'PLs Neurons/Correlation of Firing Rates Between Neuron Types/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Correlation of PLs Neuron ' pls_activity_type ' and log ' neuron_type ' ' swn_activity_type],'fig');
saveas(f,[fig_dir 'Correlation of PLs Neuron ' pls_activity_type ' and log ' neuron_type ' ' swn_activity_type],'epsc2');
saveas(f,[fig_dir 'Correlation of PLs Neuron ' pls_activity_type ' and log ' neuron_type ' ' swn_activity_type],'jpg');
