%% This script generates figures analyzing data from the PV experiment.
%  It identifies neurons that respond to stimulation (either inhibition
%  of excitation), and then plots, for the neurons, features such as firing
%  rate and peak to vallet length.
%% Make plots for PV
p_threshold = 1/1000000.0;
dendritic_filter = true;
min_firing_rate = 0.05;
min_peak_height = 80;
min_final_michael_grade = -Inf;

load('../Final Stress Data/PV Experiment/twdb_inhibition.mat'); % Inhibition database
[~, inhibited_ids, ~, ~, inhibited_peakToValley_lengths, inhibited_firing_rates, inhibited_peak_heights, inhibited_MSWs] = ...
find_responders_simple(twdb, 'all', 'trough', 'Tim', p_threshold, dendritic_filter, min_firing_rate, min_peak_height, min_final_michael_grade, false);

load('../Final Stress Data/PV Experiment/twdb_excitation.mat'); % Excitation database
[stimulated_ids, ~, ~, ~, stimulated_peakToValley_lengths, stimulated_firing_rates, stimulated_peak_heights, stimulated_MSWs] = ...
find_responders_simple(twdb, 'all', 'peak', 'Tim', p_threshold, dendritic_filter, min_firing_rate, min_peak_height, min_final_michael_grade, false);

f1 = figure;
subplot(2,3,1);
histogram([inhibited_peakToValley_lengths stimulated_peakToValley_lengths], 10);
xlabel('Peak To Valley Length (ms)'); ylabel('Count');

subplot(2,3,2);
histogram([inhibited_firing_rates stimulated_firing_rates], 10);
xlabel('Firing Rate (Hz)'); ylabel('Count');

subplot(2,3,3);
mean_MSW = mean([inhibited_MSWs; stimulated_MSWs]);
min_MSW = min(mean_MSW); max_MSW = max(mean_MSW);
plot((mean_MSW - min_MSW)/(max_MSW - min_MSW), 'red', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Voltage (mV)');

subplot(2,3,4);
hold on;
scatter(stimulated_peakToValley_lengths, stimulated_peak_heights, 'filled', 'red');
scatter(inhibited_peakToValley_lengths, inhibited_peak_heights, 'filled', 'blue');
hold off;
legend('Excitation', 'Inhibition');
xlabel('Peak To Valley Length (ms)'); ylabel('Start Times (s)');

subplot(2,3,5);
hold on;
scatter(stimulated_peakToValley_lengths, stimulated_firing_rates, 'filled', 'red');
scatter(inhibited_peakToValley_lengths, inhibited_firing_rates, 'filled', 'blue');
hold off;
legend('Excitation', 'Inhibition');
xlabel('Peak To Valley Length (ms)'); ylabel('Firing Rate (Hz)');

supertitle({['PV: p Threshold: ' num2str(p_threshold)], ...
            ['Dendritic Filter: ' num2str(dendritic_filter)], ...
            ['Min FR: ' num2str(min_firing_rate) ' Min Peak Height: ' num2str(min_peak_height)], ...
            ['Min FMG: ' num2str(min_final_michael_grade)]});
        
%% What are MSNs doing...?
p_threshold = 1/1000000.0;
dendritic_filter = true;
min_firing_rate = 0.05;
min_peak_height = 80;
min_final_michael_grade = -Inf;

load('../Final Stress Data/PV Experiment/twdb_inhibition.mat'); % Inhibition database
[msn_stimulated_ids, ~, ~, ~, msn_stimulated_peakToValley_lengths, msn_stimulated_firing_rates, msn_stimulated_peak_heights, msn_stimulated_MSWs] = ...
find_responders_simple(twdb, 'all', 'peak', 'Tim', p_threshold, dendritic_filter, min_firing_rate, min_peak_height, min_final_michael_grade, false);

load('../Final Stress Data/PV Experiment/twdb_excitation.mat'); % Excitation database
[~, msn_inhibited_ids, ~, ~, msn_inhibited_peakToValley_lengths, msn_inhibited_firing_rates, msn_inhibited_peak_heights, msn_inhibited_MSWs] = ...
find_responders_simple(twdb, 'all', 'trough', 'Tim', p_threshold, dendritic_filter, min_firing_rate, min_peak_height, min_final_michael_grade, false);

f2 = figure;
subplot(2,3,1);
histogram([msn_stimulated_peakToValley_lengths msn_inhibited_peakToValley_lengths], 10);
xlabel('Peak To Valley Length (ms)'); ylabel('Count');

subplot(2,3,2);
histogram([msn_stimulated_firing_rates msn_inhibited_firing_rates], 10);
xlabel('Firing Rate (Hz)'); ylabel('Count');

figure(f1); subplot(2,3,3);
mean_MSW = mean([msn_inhibited_MSWs(msn_inhibited_peakToValley_lengths>.21,:); msn_stimulated_MSWs(msn_stimulated_peakToValley_lengths>.21,:)]);
min_MSW = min(mean_MSW); max_MSW = max(mean_MSW);
hold on; plot((mean_MSW - min_MSW)/(max_MSW - min_MSW), 'blue', 'LineWidth', 2); hold off;
xlabel('Time (ms)'); ylabel('Voltage (mV)');

figure(f2);
subplot(2,3,4);
hold on;
s1h = scatter(msn_inhibited_peakToValley_lengths, msn_inhibited_peak_heights, 'filled', 'blue');
s2h = scatter(msn_stimulated_peakToValley_lengths, msn_stimulated_peak_heights, 'filled', 'red');
hold off;
legend('Inhibition', 'Excitation');
xlabel('Peak To Valley Length (ms)'); ylabel('Start Times (s)');

subplot(2,3,5);
hold on;
scatter(msn_inhibited_peakToValley_lengths, msn_inhibited_firing_rates, 'filled', 'blue');
scatter(msn_stimulated_peakToValley_lengths, msn_stimulated_firing_rates, 'filled', 'red');
hold off;
legend('Inhibition', 'Excitation');
xlabel('Peak To Valley Length (ms)'); ylabel('Firing Rate (Hz)');

supertitle({['MSN: p Threshold: ' num2str(p_threshold)], ...
    ['Dendritic Filter: ' num2str(dendritic_filter)], ...
    ['Min FR: ' num2str(min_firing_rate) ' Min Peak Height: ' num2str(min_peak_height)], ...
    ['Min FMG: ' num2str(min_final_michael_grade)]});



fig_dir = [ROOT_DIR 'PV Experiment/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f1, [fig_dir 'SWNs'], 'fig');
saveas(f1, [fig_dir 'SWNs'], 'epsc2');
saveas(f1, [fig_dir 'SWNs'], 'jpg');
saveas(f2, [fig_dir 'MSNs'], 'fig');
saveas(f2, [fig_dir 'MSNs'], 'epsc2');
saveas(f2, [fig_dir 'MSNs'], 'jpg');