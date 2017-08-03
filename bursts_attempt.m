
for db = 1:length(dbs)
    for neuron_type_idx = [5]
        twdb = twdbs{db};
        neuron_ids = all_ids{neuron_type_idx}{db};
        neuron_ids = arrayfun(@num2str, 1:length(neuron_ids),'uni',false);
        [~, ~, ~, spikes_array, bursts_array, ses_evt_timings, neuronidsAndData] = ah_extractDataFromTWDB(twdb, neuron_ids);
        [bins, evt_dist, ts, nTrials] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuronidsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [0 0], [12 0 5]);
        smoothing_coeff = 15;
        ah_plot_double_aligned_population_analysis(bins,evt_dist,ts,nTrials,[1 2], .55, smoothing_coeff, 1, [1 0 0], false)
        title(['DB: ' strs{db} ' Neuron Type: ' neuron_types{neuron_type_idx}]);
    end
end