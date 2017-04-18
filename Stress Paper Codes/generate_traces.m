%% This script generates traces neurons of various neuron types
% The loop below generates populations traces, which are traces that
% average the activity of all neurons of the same type recorded during the
% cost benefit task.
for neuron_type_idx = 1:length(neuron_types)
    neuron_type_ids = cb_ids{neuron_type_idx};
    for db = 1:length(dbs)
        fig_dir = [ROOT_DIR 'Traces/' neuron_types{neuron_type_idx} '/' strs{db}];
        ah_generate_plots(twdbs{db},arrayfun(@(x){num2str(x)},neuron_type_ids{db}), fig_dir,[strs{db} ' ' neuron_types{neuron_type_idx}],[strs{db} ' ' neuron_types{neuron_type_idx} ' in CB'],'trace', false);
    end
end
close all;

% The following code generates examples of traces of individual neurons
% with an extra horizontal line showing the firig rate that is a certain
% number of standard deviations above or below the mean firing rate for
% that neuron.
db = 1; neuron_type_idx = 6; neuron_idx = 10;
fig_dir = [ROOT_DIR 'Example Individual Traces/' neuron_types{neuron_type_idx} '/' strs{db}];
ah_generate_plots(twdbs{db},{num2str(cb_hfn_ids{db}(neuron_idx))}, fig_dir,[num2str(neuron_idx) ' ' strs{db} ' ' neuron_types{neuron_type_idx}],[num2str(neuron_idx) ' ' strs{db} ' ' neuron_types{neuron_type_idx} ' in CB'],'trace', 3);
db = 3; neuron_type_idx = 6; neuron_idx = 4;
fig_dir = [ROOT_DIR 'Example Individual Traces/' neuron_types{neuron_type_idx} '/' strs{db}];
ah_generate_plots(twdbs{db},{num2str(cb_hfn_ids{db}(neuron_idx))}, fig_dir,[num2str(neuron_idx) ' ' strs{db} ' ' neuron_types{neuron_type_idx}],[num2str(neuron_idx) ' ' strs{db} ' ' neuron_types{neuron_type_idx} ' in CB'],'trace', 3);
db = 1; neuron_type_idx = 3; neuron_idx = 49;
fig_dir = [ROOT_DIR 'Example Individual Traces/' neuron_types{neuron_type_idx} '/' strs{db}];
ah_generate_plots(twdbs{db},{num2str(cb_strio_ids{db}(neuron_idx))}, fig_dir,[num2str(neuron_idx) ' ' strs{db} ' ' neuron_types{neuron_type_idx}],[num2str(neuron_idx) ' ' strs{db} ' ' neuron_types{neuron_type_idx} ' in CB'],'trace', -1);
