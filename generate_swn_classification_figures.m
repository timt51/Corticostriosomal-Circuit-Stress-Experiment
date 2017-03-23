%% This script generates figures showing how SWNs are clustered.
%  The classification is based on features of the neuron waveform.
%% Get IDs and features of all MSNs, SWNs, and HFNs
[voltages,snr_parameters,neuron_ids] = neuronSNR(twdb_control,0,1,0,1,0); disp(length(neuron_ids));
msn_ids = twdb_lookup(twdb_control, 'index', 'key', 'tetrodeType', 'dms', 'grade', 'sqr_neuron_type', 3, 5, ...
    'grade', 'final_michael_grade', 1, 5);
save('snr_control.mat','snr_parameters','neuron_ids','voltages', 'msn_ids');

[voltages,snr_parameters,neuron_ids] = neuronSNR(twdb_stress,1,1,0,1,0); disp(length(neuron_ids));
msn_ids = twdb_lookup(twdb_stress, 'index', 'key', 'tetrodeType', 'dms', 'grade', 'sqr_neuron_type', 3, 5, ...
    'grade', 'final_michael_grade', 1, 5);
save('snr_stress.mat','snr_parameters','neuron_ids','voltages', 'msn_ids');

[voltages,snr_parameters,neuron_ids] = neuronSNR(twdb_stress2,2,1,0,1,0); disp(length(neuron_ids));
msn_ids = twdb_lookup(twdb_stress2, 'index', 'key', 'tetrodeType', 'dms', 'grade', 'sqr_neuron_type', 3, 5, ...
    'grade', 'final_michael_grade', 1, 5);
save('snr_stress2.mat','snr_parameters','neuron_ids','voltages', 'msn_ids');
%% Load data for the database
db = 1;
twdb = twdbs{db};
load(['snr_' dbs{db} '.mat']);
%% Unpack snr features
peak_width = snr_parameters{1}/150; % Divide by 150 to change to units of milliseconds
valley_width = snr_parameters{2}/150;
half_peak_width = snr_parameters{3}/150;
peakToValley_length = snr_parameters{7}/150;
snr_nan = snr_parameters{11};
neuron_ids = cellfun(@str2num, neuron_ids);
firing_rates = [twdb(neuron_ids).firing_rate];
%% Remove NaNs from relevant parameters
nans = find(isnan(valley_width) | isnan(peakToValley_length) | isnan(peak_width) | isnan(half_peak_width));
to_remove = nans; to_keep = setdiff(1:length(neuron_ids), to_remove); % Complement of to remove is to keep
neuron_ids = neuron_ids(to_keep);
valley_width = valley_width(to_keep);
peakToValley_length = peakToValley_length(to_keep);
half_peak_width = half_peak_width(to_keep);
peak_width = peak_width(to_keep);
firing_rates = firing_rates(to_keep);
voltages = voltages(to_keep,:);
%% Make histogram for important dimensions
% Peak To Valley Length
f = figure;
subplot(2,2,1); histogram(peakToValley_length,30);
title('Distribution of Peak To Valley Lengths'); xlabel('Peak To Valley Length (ms)'); ylabel('Count');
hold on;
y = pdf('Normal',0:.23/100:.23,.12, .03); plot(0:.23/100:.23,18*y,'Color','r','LineWidth',2);
y = pdf('Normal',0:.6/100:.6,.245, .04); plot(0:.6/100:.6,52*y,'Color',[0.9792 0.5000 0.4453],'LineWidth',2);
l = line([.15 .15],[0 350], 'Color', [0 0 0], 'LineWidth', 2);
hold off;
legend(l, 'Threshold');

% Valley Width
subplot(2,2,4); histogram(valley_width,30);
title('Distribution of Valley Widths'); xlabel('Valley Width (ms)'); ylabel('Count');
hold on;
y = pdf('Normal',0:.17/100:.17,.075, .025); plot(0:.17/100:.17,18*y,'Color','r','LineWidth',2);
y = pdf('Normal',0:.35/100:.35,.195, .040); plot(0:.35/100:.35,32*y,'Color',[0.9792 0.5000 0.4453],'LineWidth',2);
y = pdf('Normal',.35:.25/100:.6,.480, .03); plot(.35:.25/100:.6,8*y,'Color',[0.9792 0.5000 0.4453],'LineWidth',2);
l = line([.1 .1],[0 350], 'Color', [0 0 0], 'LineWidth', 2);
hold off;
legend(l, 'Threshold');

% Half Peak Width
subplot(2,2,3); histogram(half_peak_width,50);
title('Distribution of Half Peak Widths'); xlabel('Half Peak Width (ms)'); ylabel('Count');
hold on;
y = pdf('Normal',0:.15/100:.15,.095, .01); plot(0:.15/100:.15,4*y,'Color','r','LineWidth',2);
y = pdf('Normal',0:.35/100:.35,.125, .015); plot(0:.35/100:.35,17*y,'Color',[0.9792 0.5000 0.4453],'LineWidth',2);
l = line([.125 .125],[0 500], 'Color', [0 0 0], 'LineWidth', 2); xlim([.05 .35]);
hold off;
legend(l, 'Threshold');
%% Determine fsis based on thresholds, scatter MSNs vs FSIs
subplot(2,2,2);

% For presentation, cluster only in main dimensions
fsi_main = find(peakToValley_length < .15 & valley_width < .1);
not_fsi_main = setdiff(1:length(neuron_ids), fsi_main);

% For analysis, cluster also in supplemental dimesnions
fsi = find(peakToValley_length < .15 & valley_width < .1 & half_peak_width < .125);
not_fsi = setdiff(1:length(neuron_ids), fsi);

% Determine MSNs
msn_ids = cellfun(@str2num, msn_ids); msn_ids = intersect(msn_ids,neuron_ids);
msn = find(ismember(neuron_ids,msn_ids));
msn = setdiff(msn,fsi_main);

hold on;
scatter(valley_width(fsi_main), peakToValley_length(fsi_main), 2, [1 0 0],'filled');
scatter(valley_width(msn), peakToValley_length(msn), 2, [0 0 1],'filled');
hold off;

title(dbs{db}); xlabel('Valley Width (ms)'); ylabel('Peak To Valley Length (ms)');
xlim([0 0.3]); ylim([0 0.4]);
saveas(f, [ROOT_DIR 'Classification/Clustering.fig']);
saveas(f, [ROOT_DIR 'Classification/Clustering.eps'],'epsc2');
saveas(f, [ROOT_DIR 'Classification/Clustering.jpg'],'jpg');


% Scatter HFNs
hold on;
hf_plot = intersect(find(firing_rates>6),[msn fsi_main]);
scatter(valley_width(hf_plot), peakToValley_length(hf_plot), 4, [0 0 0],'filled');
hold off;
saveas(f, [ROOT_DIR 'Classification/Clustering With HFNs.fig']);
saveas(f, [ROOT_DIR 'Classification/Clustering With HFNs.eps'],'epsc2');
saveas(f, [ROOT_DIR 'Classification/Clustering With HFNs.jpg'],'jpg');
%% Plot mean spike waveform (MSW) of MSNs and SWNs
f = figure; % Superimpose MSW of MSNs and SWNs
mean_vs = mean(voltages(msn,:));
stderr_vs = 2*std(voltages(msn,:))/sqrt(length(msn));
[hp1, ~] = dg_plotShadeCL(gca, [(1:150)/150;mean_vs-stderr_vs;mean_vs+stderr_vs;mean_vs]', ...
    'Color', [0 0 0], 'FaceColor', 'b');
title(['Mean Sample Waveform of ' dbs{db} ' MSNs']);
xlabel('Time (ms)');
ylabel('Min-Max Normalized Voltage');

hold on;
mean_vs = mean(voltages(fsi,:));
stderr_vs = 2*std(voltages(fsi,:))/sqrt(length(fsi));
[hp2, ~] = dg_plotShadeCL(gca, [(1:150)/150;mean_vs-stderr_vs;mean_vs+stderr_vs;mean_vs]', ...
    'Color', [0 0 0], 'FaceColor', 'r');
title(['Mean Sample Waveform of ' dbs{db} ' MSNs and Short Width Neurons']);
xlabel('Time (ms)');
ylabel('Min-Max Normalized Voltage');
hold off;
legend([hp1, hp2], 'MSN', 'Short Width');
xlim([0 .8]);

saveas(f, [ROOT_DIR 'Classification/Superimposed Mean Spike Waveform for MSNs and SWNs.fig']);
saveas(f, [ROOT_DIR 'Classification/Superimposed Mean Spike Waveform for MSNs and SWNs.eps'],'epsc2');
saveas(f, [ROOT_DIR 'Classification/Superimposed Mean Spike Waveform for MSNs and SWNs.jpg'],'jpg');
%% Plot Example Spike Waveform of Not Short Width, Short Width + label features
neuronSNRplot(twdb,0,1,1,5284,ROOT_DIR);