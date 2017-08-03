%% Remove some bad neurons
cb_swn_ids{1} = setdiff(cb_swn_ids{1}, [3863 3875]);
cb_ids = {cb_pl_ids, cb_pls_ids, cb_strio_ids, cb_matrix_ids, cb_hfn_ids, cb_swn_ids};




%% Make line plots for main figure. First, make line plots and cascade plot
%  for PLs Neurons, striosomes, and SWNs; show exciation for all neurons
%  types an databases, except control striosomes, for which we show
%  inhibition. 
max_samples  = Inf;
neuron_type_idxs = [2,3,6];
types = {{NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {'excitation', 'excitation', 'excitation'}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {'excitation', 'excitation', 'excitation'}}; 
save_line_plots = true;
save_cascade = true;
save_results = true;
make_line_plots_master_version2(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)

% Next, make the line plot for striosome excitation, as we show in the main
% figure.
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
make_line_plots_master_version2(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)

max_samples  = Inf;
neuron_type_idxs = 5;
types = {{NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {NaN,NaN,NaN}, ...
         {'excitation','excitation','excitation'}, ...
         {NaN,NaN,NaN}}; 
save_line_plots = true;
save_cascade = false;
save_results = false;
make_line_plots_master_version2(neuron_types, dbs, cb_ids, twdbs, ROOT_DIR, max_samples, neuron_type_idxs, types, save_line_plots, save_cascade,save_results)


%% Add the removed neurons back; they are still okay for other analyses
cb_swn_ids{1} = [cb_swn_ids{1}, 3863, 3875];
cb_ids = {cb_pl_ids, cb_pls_ids, cb_strio_ids, cb_matrix_ids, cb_hfn_ids, cb_swn_ids};