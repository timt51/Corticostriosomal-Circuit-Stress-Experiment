%% Find all sessions
sessionDirs = cell(1,length(dbs));
sessionDir_neurons = cell(1,length(dbs)); % Neurons #s for each session
for db = 1:length(dbs)
    sessionDirs{db} = {twdbs{db}.sessionDir};
    
    [~,unique_sessionDir_idxs,~] = unique(sessionDirs{db});
    sessionDir_neurons{db} = cell(1,length(unique_sessionDir_idxs));
    for idx = 1:length(unique_sessionDir_idxs)
        sessionDir_neurons{db}{idx} = ...
            find(strcmp({twdbs{db}.sessionDir},sessionDirs{db}{unique_sessionDir_idxs(idx)}));
    end
    
    sessionDirs{db} = sessionDirs{db}(unique_sessionDir_idxs);
    for session_num = 1:length(sessionDirs{db})
        sessionDirs{db}{session_num} = strrep(sessionDirs{db}{session_num},'/Users/Seba/Dropbox/UROP/stress_project','C:/Users/TimT5/Dropbox (MIT)/cell');
        sessionDirs{db}{session_num} = strrep(sessionDirs{db}{session_num},'D:\UROP','C:/Users/TimT5/Dropbox (MIT)/cell/Cell Figures and Data/Data');
    end
end
%% Find all PLS and SWNs in each session
pls_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
swn_neurons{db} = cell(1,length(sessionDir_neurons{db}));
for db = 1:length(dbs)
    pls_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    swn_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    
    % Here we decide which pairs we want i.e. PLS and SWN
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        pls_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_pls_ids{db}]);
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_strio_ids{db}]);
        swn_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_swn_ids{db}]);
    end
end
%% Get triplets
all_triplets = cell(1,length(dbs));
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        all_triplets{db} = [all_triplets{db}; allcomb(pls_neurons{db}{sessionDir_idx},strio_neurons{db}{sessionDir_idx},swn_neurons{db}{sessionDir_idx})];
    end
end
%% Find GC triplets
smooth_factor = 10;
bin_size = 0.067; % seconds
bins = -3:bin_size:6;
max_window_size = 1; % seconds
MINP = 1; % number of bins
MAXP = ceil(max_window_size/bin_size); % number of bins
gcs = cell(1,length(dbs));
triplets = cell(1,length(dbs));
for db = 1:length(dbs)
    for triplet_num = 1:size(all_triplets{db},1)
        pls_id = all_triplets{db}(triplet_num, 1);
        strio_id = all_triplets{db}(triplet_num, 2);
        swn_id = all_triplets{db}(triplet_num, 3);

        pls_spikes = twdbs{db}(pls_id).trial_spikes;
        strio_spikes = twdbs{db}(strio_id).trial_spikes;
        swn_spikes = twdbs{db}(swn_id).trial_spikes;

        pls_binned_spikes = cell2mat(cellfun(@(x) histcounts(x,bins), pls_spikes,'uni',false)');
        strio_binned_spikes = cell2mat(cellfun(@(x) histcounts(x,bins), strio_spikes,'uni',false)');
        swn_binned_spikes = cell2mat(cellfun(@(x) histcounts(x,bins), swn_spikes,'uni',false)');
        
        X = [pls_binned_spikes; strio_binned_spikes; swn_binned_spikes];
        GC = granger_causality(X, MINP, MAXP, false);
        gcs{db} = [gcs{db}  max(max(GC))];
        if max(max(GC)) > 0
            triplets{db} = [triplets{db}; pls_id, strio_id, swn_id];
        end
    end
end
%% Find patterns
% Burst finding parameters
smooth_factor = 3; % For finding thresholds
min_ISIs_per_neuron = 15;
min_time = -3;
max_time = 2.5;
method = 'Tim';
debug_thresholds = false;
% Pattern parameters
min_strio_inhib_time = .5;
min_fsi_excih_time = 0;
max_fsi_excih_time = .02;
min_strio_excih_time = 0;
max_strio_excih_time = .02;
type_a_count = zeros(1,length(dbs));
type_c_count = zeros(1,length(dbs));
for db = 1:length(dbs)
    for triplet_idx = 1:size(triplets{db},1)
        disp([db triplet_idx / size(triplets{db},1)]);
        pls_id = triplets{db}(triplet_idx,1);
        strio_id = triplets{db}(triplet_idx,2);
        swn_id = triplets{db}(triplet_idx,3);

        pls_spikes = twdbs{db}(pls_id).trial_spikes;
        strio_spikes = twdbs{db}(strio_id).trial_spikes;
        swn_spikes = twdbs{db}(swn_id).trial_spikes;

        pls_bursts = find_phasic_periods(pls_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, NaN, method, debug_thresholds);
        strio_bursts = find_phasic_periods(strio_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, NaN, method, debug_thresholds);
        swn_bursts = find_phasic_periods(swn_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, NaN, method, debug_thresholds);
        
        if ~iscell(pls_bursts) || ~iscell(strio_bursts) || ~iscell(swn_bursts)
            continue;
        end
        for trial_idx = 1:length(pls_bursts)
            if isempty(pls_bursts{trial_idx}) || isempty(strio_bursts{trial_idx}) || isempty(swn_bursts{trial_idx})
                continue;
            end
            for pls_burst_idx = 1:size(pls_bursts{trial_idx},1)
                pls_burst_start = pls_bursts{trial_idx}(pls_burst_idx,1);
                
                next_fsi_burst_idx = find(swn_bursts{trial_idx}(:,1) > pls_burst_start, 1);
                if isempty(next_fsi_burst_idx)
                    continue;
                else
                    next_fsi_burst_start = swn_bursts{trial_idx}(next_fsi_burst_idx, 1);
                end
                next_strio_burst_idx = find(strio_bursts{trial_idx}(:,1) > next_fsi_burst_start, 1);
                if isempty(next_strio_burst_idx)
                    continue;
                else
                    next_strio_burst_start = strio_bursts{trial_idx}(next_strio_burst_idx, 1);
                end
                if (next_fsi_burst_start - pls_burst_start) > min_fsi_excih_time ...
                && (next_fsi_burst_start - pls_burst_start) < max_fsi_excih_time ...
                && (next_strio_burst_start - next_fsi_burst_start) > min_strio_inhib_time
                    type_a_count(db) = type_a_count(db) + 1;
                end
                
                after_pls_strio_burst_idx = find(strio_bursts{trial_idx}(:,1) > pls_burst_start, 1);
                if isempty(after_pls_strio_burst_idx)
                    continue;
                else
                    after_pls_strio_burst_start = strio_bursts{trial_idx}(after_pls_strio_burst_idx, 1);
                end
                if (after_pls_strio_burst_start - pls_burst_start) > min_strio_excih_time ...
                && (after_pls_strio_burst_start - pls_burst_start) < max_strio_excih_time ...
                && next_fsi_burst_start > after_pls_strio_burst_start
                    type_c_count(db) = type_c_count(db) + 1;
                end
            end
        end
    end
end

total = type_a_count + type_c_count;
props = type_a_count./total;
ratio = type_a_count ./ type_c_count;
f = figure;
bar(ratio);
strs = {'Control', 'Stress', 'Stress2'};
set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
text(1,ratio(1)+.2,[num2str(type_a_count(1)) '/' num2str(type_c_count(1))]);
text(2,ratio(2)+.2,[num2str(type_a_count(2)) '/' num2str(type_c_count(2))]);
text(3,ratio(3)+.2,[num2str(type_a_count(3)) '/' num2str(type_c_count(3))]);
xlabel('Experimental Group'); ylabel('Ratio');
[h,p]=chi2test(type_a_count(1), total(1), type_a_count(2), total(2), type_a_count(3), total(3));
title({'Type A / Type C', ...
        ['Chi Square Test Comparing Type A / (Type A + Type C) p = ' num2str(p)]});
fig_dir = [ROOT_DIR 'Review/Patterns/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Proportion of Type A'], 'fig');
saveas(f,[fig_dir 'Proportion of Type A'], 'epsc2');
saveas(f,[fig_dir 'Proportion of Type A'], 'jpg');