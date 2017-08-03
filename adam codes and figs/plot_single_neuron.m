function plot_single_neuron(db, id)

    [~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(db, {num2str(id)});
    [plotting_bins, evt_times_distribution, timeOfBins, numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .4, .6], [0 0]);
    ah_plot_double_aligned_population_analysis(plotting_bins, evt_times_distribution, timeOfBins, numTrials, [1 2], .5, 15, 0, 'red',false);

end