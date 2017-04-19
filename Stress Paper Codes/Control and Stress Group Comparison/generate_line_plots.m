%% Make line plots for main figure. First, make line plots and cascade plot
%  for PLs Neurons, striosomes, and SWNs; show exciation for all neurons
%  types an databases, except control striosomes, for which we show
%  inhibition. 
max_samples  = 22;
neuron_type_idxs = [2,3,6];
types = {{NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {'inhibition', 'excitation', 'excitation'}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}}; 
save_line_plots = true;
save_cascade = true;
save_results = true;
make_line_plots_master(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)

% Next, make the line plot for striosome excitation, as we show in the main
% figure.
max_samples  = 22;
neuron_type_idxs = 3;
types = {{NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}}; 
save_line_plots = true;
save_cascade = false;
save_results = false;
make_line_plots_master(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)
%% Make cascade plot for PLs Neurons, striosomes, and SWNs, as we show in
%  the supplemental figures.
max_samples  = 22;
neuron_type_idxs = [2,3,5];
types = {{NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {'inhibition', 'excitation', 'excitation'}, ...
         {NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {NaN,NaN,NaN}}; 
save_line_plots = false;
save_cascade = true;
save_results = false;
make_line_plots_master(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)

%% Make line plots for all PLs Neurons, striosomes, SWNs, and HFNs. Excitation only.
max_samples  = Inf;
neuron_type_idxs = [2,3,5,6];
types = {{NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {'excitation', 'excitation', 'excitation'}}; 
save_line_plots = true;
save_cascade = false;
save_results = false;
make_line_plots_master(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)

%% Make line plots for all striosomes. Inhibition only.
max_samples  = Inf;
neuron_type_idxs = 3;
types = {{NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {'inhibition', 'inhibition', 'inhibition'}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}}; 
save_line_plots = true;
save_cascade = false;
save_results = false;
make_line_plots_master(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)

%% Make line plots for all striosomes. Excitation and inhibition.
max_samples  = Inf;
neuron_type_idxs = 3;
types = {{NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {'both', 'both', 'both'}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}}; 
save_line_plots = true;
save_cascade = false;
save_results = false;
make_line_plots_master(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)
%% Make a plot comparing mean peak time of SWNs and HFNs across experimental groups
neuron_type_idxs = [5,6];
times_of_max = cell(1,length(neuron_types));
sig_std = 3;
num_samples = Inf;
max_ylim = Inf;
type = 'excitation';
for neuron_type_idx = neuron_type_idxs
    times_of_max{neuron_type_idx} = cell(1,length(dbs));
    % Get peak times data
    for db = 1:length(dbs)
    [times_of_max{neuron_type_idx}{db}, ~] = make_peak_activity_line_plot(twdbs{db}, all_ids{neuron_type_idx}{db},[sig_std NaN],...
                            num_samples,max_ylim,neuron_types{neuron_type_idx},false,type);
    end
    % Get mean and standard error of peak times
    means = zeros(1,length(dbs));
    stderrs = zeros(1,length(dbs));
    for db = 1:length(dbs)
        lick_time = 3.5; % s
        times_of_max{neuron_type_idx}{db} = times_of_max{neuron_type_idx}{db}(~isnan(times_of_max{neuron_type_idx}{db}));
        times_of_max{neuron_type_idx}{db} = times_of_max{neuron_type_idx}{db}(times_of_max{neuron_type_idx}{db}<lick_time);
        means(db) = mean(times_of_max{neuron_type_idx}{db});
        stderrs(db) = std(times_of_max{neuron_type_idx}{db})/sqrt(length(times_of_max{neuron_type_idx}{db}));
    end
    % Perform statistical tests
    [~,p1] = ttest2(times_of_max{neuron_type_idx}{1}, times_of_max{neuron_type_idx}{2});
    [~,p2] = ttest2(times_of_max{neuron_type_idx}{1}, times_of_max{neuron_type_idx}{3});
    [~,p3] = ttest2(times_of_max{neuron_type_idx}{2}, times_of_max{neuron_type_idx}{3});
    % Make visualization
    f = figure;
    barwitherr(stderrs, means);
    set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
    xlabel('Experimental Group'); ylabel('Mean Peak Time Relative to Click(s)');
    title({['Mean Peak Time of ' neuron_types{neuron_type_idx} ' Relative to Click in CB Task'], ...
           ['Control vs Stress ttest2 p = ' num2str(p1)], ...
           ['Control vs Stress2 ttest2 p = ' num2str(p2)], ...
           ['Stress vs Stress2 ttest2 p = ' num2str(p3)]});
       
    fig_dir = [ROOT_DIR 'Time of Peak Activity Line Plots/' neuron_types{neuron_type_idx}];
    if ~exist(fig_dir,'dir')
        mkdir(fig_dir);
    end
    saveas(f,[fig_dir '/Mean Peak Time Across Experimental Groups'], 'fig');
    saveas(f,[fig_dir '/Mean Peak Time Across Experimental Groups'], 'epsc2');
    saveas(f,[fig_dir '/Mean Peak Time Across Experimental Groups'], 'jpg');
end