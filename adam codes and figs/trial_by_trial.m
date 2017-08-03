start_time = -3; end_time = 2;
min_delay = .006; max_delay = .1;

results = {[], [], []};

for i = 1:length(dbs)
    pairs = all_pairs{i};
    fsis = unique(pairs(:, 2));
    result = [];
    
    s = size(pairs);
    for j = 1:s(1)
        pls = pairs(j, 1);
        fsi = pairs(j, 2);
        
        pls_spikes = twdbs{i}(pls).trial_spikes;
        pls_bursts = twdbs{i}(pls).trial_bursts;
        pls_fr = twdbs{i}(pls).firing_rate;

        fsi_spikes = twdbs{i}(fsi).trial_spikes;
        fsi_bursts = twdbs{i}(fsi).trial_bursts;
        %fsi_bursts = find_phasic_periods(fsi_spikes, 5, 15, -3, 2, fsi_bursts, 'Tim', false);
        
        [~, pls_to_fsi_frs, pls_to_fsi_prob] = find_phasic_time_delays(pls_spikes, fsi_spikes, pls_bursts, fsi_bursts, min_delay, max_delay, start_time, end_time, false);
        
        if pls_to_fsi_prob > 0
            zscore = (mean(pls_to_fsi_frs(:, 1)) / pls_fr) - 1;
            result = [result; pls_to_fsi_prob, zscore, fsi];
        end
    end
    
    other_result = zeros(length(fsis), 3);
    s = size(result);
    for j = 1:s(1)
        id = find(fsis==result(j, 3));
        other_result(id, 1) = other_result(id, 1) + (result(j, 3) > .9);
        other_result(id, 2) = other_result(id, 2) + result(j, 2);
        other_result(id, 3) = other_result(id, 3) + 1;
    end
    
    final_result = zeros(length(fsis), 2);
    final_result(:, 1) = other_result(:, 1);
    final_result(:, 2) = other_result(:, 2) ./ other_result(:, 3);
    
    results{i} = final_result;
end

figure;
hold all;
for i = 1:length(dbs)
    scatter(results{i}(:, 1), results{i}(:, 2))
end
xlim([0, 7])
xlabel('Number of PLs neurons')
ylim([0, 15])
ylabel('Burst firing rate (z-scores)')
saveas(gcf, 'trialbytrial', 'fig')
saveas(gcf, 'trialbytrial', 'eps')
