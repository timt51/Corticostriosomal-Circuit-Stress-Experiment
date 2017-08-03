%% This script makes histograms and raster plots of a PLS neuron stimulated antidromically
%  and a striosome stimulated orthodromically
%% Antidromic Example StrioProjPL_rep_ras
% Index of the example PLS neuron
idx = 9501;
        %% Set up spikes array
sessionDir = twdb_control(idx).sessionDir;
sessionDir = strrep(sessionDir,'/Users/Seba/Dropbox/UROP/stress_project','../Final Stress Data/Data');
sessionDir = strrep(sessionDir,'D:\UROP','../Final Stress Data/Data');
events = load([sessionDir, '\events6.EVTSAV'], '-mat');
events = events.lfp_save_events;
block_idx = find(events(:,2)==43);
block_end = find(events(block_idx+2:end,2)==100,1,'first') + block_idx + 1;
events = events(block_idx:block_end,:);
events(events==6)=4;

unitnum = str2double(twdb_control(idx).neuronN);
sessionDir = twdb_control(idx).clusterDataLoc;
sessionDir = strrep(sessionDir,'/Users/Seba/Dropbox/UROP/stress_project','../Final Stress Data/Data');
sessionDir = strrep(sessionDir,'D:\UROP','../Final Stress Data/Data');
spikes = load(sessionDir);
spikes = spikes.output;
spikes = spikes(spikes(:,2)==unitnum,1);

stim_spikes = ah_build_spikes_array(spikes,events,4,[-1 1],4);
data = twdb_control(idx).striosomality2_data;
numTrials = length(stim_spikes);
        %% Draw raster plot
figure; hold all;
line([0 0], [0 numTrials], 'LineWidth', 2, 'Color', 'Red')
patch([1 10 10 1], [0 0 numTrials numTrials], [1.00 0.75 0.75], 'EdgeColor', 'none')
for trial_idx = 1:numTrials
    for spike_idx = 1:length(stim_spikes{trial_idx})
        spike_time = stim_spikes{trial_idx}(spike_idx)*1000;
        line([spike_time spike_time], [trial_idx-1 trial_idx], 'LineWidth', 2, 'Color', 'Black')
    end
end
        %% Plot formatting
set(gca, 'ydir', 'reverse')
xlim([-15 15]);
xlabel('Time (ms)');
ylim([0 numTrials]);
ylabel('Trial Number');
fig_dir = [ROOT_DIR 'Stimulation Examples/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
saveas(gca, [fig_dir, 'Antidromic Stimulation Example Raster Plot'], 'fig');
saveas(gca, [fig_dir, 'Antidromic Stimulation Example Raster Plot'], 'epsc2');
saveas(gca, [fig_dir, 'Antidromic Stimulation Example Raster Plot'], 'jpg');

        %% Draw/format histogram
figure; hold all
spike = cell2mat(stim_spikes)*1000;
tvals = -999.75:.5:999.75; binwidth = tvals(2) - tvals(1); numBins = length(tvals);
bins = hist(spike,tvals); bins = bins*1000/(numTrials*binwidth);
bar(tvals,bins,1)
xlim([-15 15]);
xlabel('Time (ms)');
ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, 'Antidromic Stimulation Example Histogram'], 'fig');
saveas(gca, [fig_dir, 'Antidromic Stimulation Example Histogram'], 'epsc2');
saveas(gca, [fig_dir, 'Antidromic Stimulation Example Histogram'], 'jpg');

%% Orthodromic Example
% Index of the example striosome
idx = 710;
        %% Set up spikes array
sessionDir = twdb_control(idx).sessionDir;
sessionDir = strrep(sessionDir,'/Users/Seba/Dropbox/UROP/stress_project','../Final Stress Data/Data');
sessionDir = strrep(sessionDir,'D:\UROP','../Final Stress Data/Data');
events = load([sessionDir, '\events6.EVTSAV'], '-mat');
events = events.lfp_save_events;

unitnum = str2double(twdb_control(idx).neuronN);
sessionDir = twdb_control(idx).clusterDataLoc;
sessionDir = strrep(sessionDir,'/Users/Seba/Dropbox/UROP/stress_project','../Final Stress Data/Data');
sessionDir = strrep(sessionDir,'D:\UROP','../Final Stress Data/Data');
spikes = load(sessionDir);
spikes = spikes.output;
spikes = spikes(spikes(:,2)==unitnum,1);

stim_spikes = ah_build_spikes_array(spikes,events,4,[-1 1],4);
data = twdb_control(idx).striosomality2_data;
numTrials = length(stim_spikes);
        %% Draw raster plot
figure; hold all;
line([0 0], [0 numTrials], 'LineWidth', 2, 'Color', 'Red')
patch([1 10 10 1], [0 0 numTrials numTrials], [1.00 0.75 0.75], 'EdgeColor', 'none')
% patch([1 10 10 1], [0 0 numTrials numTrials], [1.00 0.75 0.75], 'EdgeColor', 'none')
% patch(1000*[data(7:8) data(8:-1:7)], [0 0 numTrials numTrials], [0.75 0.75 0.75], 'EdgeColor', 'none')
for trial_idx = 1:numTrials
    for spike_idx = 1:length(stim_spikes{trial_idx})
        spike_time = stim_spikes{trial_idx}(spike_idx)*1000;
        line([spike_time spike_time], [trial_idx-1 trial_idx], 'LineWidth', 2.5, 'Color', 'Black')
    end
end
        %% Plot formatting
set(gca, 'ydir', 'reverse')
xlim([-15 15]);
xlabel('Time (ms)');
ylim([0 numTrials]);
ylabel('Trial Number');
fig_dir = [ROOT_DIR 'Stimulation Examples/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
saveas(gca, [fig_dir, 'Orthodomic Stimulation Example Raster Plot'], 'fig');
saveas(gca, [fig_dir, 'Orthodomic Stimulation Example Raster Plot'], 'epsc2');
saveas(gca, [fig_dir, 'Orthodomic Stimulation Example Raster Plot'], 'jpg');
%% Draw/format histogram
figure; hold all
spike = cell2mat(stim_spikes)*1000;
tvals = -995:.5:995; binwidth = tvals(2) - tvals(1); numBins = length(tvals);
bins = hist(spike,tvals); bins = bins*1000/(numTrials*binwidth);
bar(tvals,bins,1)
xlim([-15 15]);
xlabel('Time (ms)');
ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, 'Orthodomic Stimulation Example Histogram'], 'fig');
saveas(gca, [fig_dir, 'Orthodomic Stimulation Example Histogram'], 'epsc2');
saveas(gca, [fig_dir, 'Orthodomic Stimulation Example Histogram'], 'jpg');
