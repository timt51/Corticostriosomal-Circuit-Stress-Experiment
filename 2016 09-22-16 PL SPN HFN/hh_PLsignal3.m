function spike = hh_PLsignal3(timeline, spikedur, twdb, db, cb_pls_ids, neuron_num)
    
    PLS_spikes = twdb(cb_pls_ids{db}(neuron_num)).trial_spikes;
    num_trials = length(PLS_spikes);
    trial_num = randi(num_trials, [1 1]);
    PLS_trial_spikes = (PLS_spikes{trial_num} + 20) * 1000; 
    
    tmin = min(timeline);
    tmax = max(timeline);
    time_bins = tmin:spikedur:tmax+spikedur;
    
    spike = histcounts(PLS_trial_spikes, time_bins);
    spike = double(spike >= 1);
end