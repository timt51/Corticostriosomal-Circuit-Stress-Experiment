%% This script generates figures showing the proportion of striosomes that
%  have activity that correlate with PLs activity.
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
%% Find all PLS and Striosomes in each session
comparison_type = 'PLS to Striosomes';
pls_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    pls_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        pls_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_pls_ids{db}]);
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_strio_ids{db}]);
    end
end
%% Get pairs
all_pairs = cell(1,length(dbs));
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        all_pairs{db} = [all_pairs{db}; allcomb(pls_neurons{db}{sessionDir_idx},strio_neurons{db}{sessionDir_idx})];
    end
end
%% Plot - find periods of phasic activity (bursts) based on ISIs; find next phasic event
debug_thresholds = false;           % debug phasic activity detection algorithm
min_ISIs_per_neuron = 15;           % minimum number of ISIs needed to find phasic periods
method = 'Tim';                     % Method for finding bursts ('Tim' or 'AH')

debug_delays = false;              % debug time delays algorithm (finds all striosome bursts after a pls burst; within the min and max delay)
                                   % false - no plot
                                   % number 1-40 -> # of trials to plot
min_delay = .004; max_delay = 1.5; % Min and max delay considered for algorithm
min_time = -3; max_time = 2.5;     % (Trial time period) to look for time delays; ie. look from -3s to 2.5s for pls bursts and striosome bursts after those pls bursts

phasic_time_delays = cell(1,length(dbs));       % record time delays
response_probabilities = cell(1,length(dbs));   % record probability of striosome burst as response to pls burst

for db = 1:length(dbs)
    twdb = twdbs{db};
    skipped_pairs = []; % Record pairs that are skipped because bursts cannot be found
    phasic_time_delays{db} = cell(1,size(all_pairs{db},1));
    response_probabilities{db} = zeros(1,size(all_pairs{db},1)); % record for each pair
    
    for pair_num = 1:size(all_pairs{db},1)
        disp([db pair_num]);
        %% Get time delays
        % Get pair ids and get pair spikes and bursts
        pls_id = all_pairs{db}(pair_num,1);     
        strio_id = all_pairs{db}(pair_num,2);
        pls_spikes = twdb(pls_id).trial_spikes;        ah_pls_bursts = twdb(pls_id).trial_bursts;
        strio_spikes = twdb(strio_id).trial_spikes;    ah_strio_bursts = twdb(strio_id).trial_bursts;
   
        % Find bursts
        smooth_factor = 3; % For finding thresholds
        pls_bursts = find_phasic_periods(pls_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, ah_pls_bursts, method, debug_thresholds);
        strio_bursts = find_phasic_periods(strio_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, ah_strio_bursts, method, debug_thresholds);
        
        % Skip neurons with not enough data to calculate threshold
        if ~iscell(pls_bursts) || ~iscell(strio_bursts)            
            skipped_pairs = [skipped_pairs, pair_num];
            continue
        end
        
        % Find time delays
        [phasic_time_delays{db}{pair_num}, ~, response_probabilities{db}(pair_num)] = find_phasic_time_delays(pls_spikes, strio_spikes, pls_bursts, strio_bursts, ...
                                                            min_delay, max_delay, min_time, max_time, debug_delays);
    end
    % Remove skipped pairs from analysis
    phasic_time_delays{db}(skipped_pairs) = [];
    response_probabilities{db}(skipped_pairs) = [];
    all_pairs{db}(skipped_pairs,:) = [];
end
close all;
%% Compare distribution of time delays (for each pair) to a uniform distrbution using kstest
% Comparison is done by looking at time delays between 0s to .5s,
%                                                      0s to 1s,
%                                                  and 0s to 1.5s.
min_time_delays = 15;
max_delays = [.5,1,1.5];
skipped_pairs = cell(1,length(dbs));
original_ps = cell(1,length(dbs));
for db = 1:length(dbs)
    skipped_pairs{db} = [];
    
    for pair_num = 1:length(phasic_time_delays{db})
        disp([db pair_num]);
        if length(phasic_time_delays{db}{pair_num}) > min_time_delays            
            original_ps_tmp = zeros(1,length(max_delays));
            for max_delay_idx = 1:length(max_delays)
                max_delay = max_delays(max_delay_idx);
                                
                delays = phasic_time_delays{db}{pair_num}(phasic_time_delays{db}{pair_num} < max_delay & phasic_time_delays{db}{pair_num} ~= 0);
                if ~isempty(delays)
                    test_cdf = [delays; cdf('unif',delays,0,max_delay)]';
                    [~, p] = kstest(delays,'CDF',test_cdf);
                else
                    p = 1;
                end
                                
                original_ps_tmp(max_delay_idx) = p;
            end
            
            % Save p values
            original_ps{db} = [original_ps{db}; original_ps_tmp];
        else
            skipped_pairs{db} = [skipped_pairs{db}, pair_num];
        end
    end
    disp(all_pairs); disp(response_probabilities);
    all_pairs{db}(skipped_pairs{db},:) = [];
    phasic_time_delays{db}(skipped_pairs{db}) = [];
    response_probabilities{db}(skipped_pairs{db}) = [];
end
%% Find proportions of correlated pairs
% Considered significant if any of the 3 kstests are signicant.
sig_pairs = cell(1,length(dbs)); % Record pairs that are significantly correlated
for db = 1:length(dbs)
    sig_threshold = .05; % Threshold considered significant.
    sig_time_delays = any(original_ps{db}(:,:) <= sig_threshold,2); % (:,:) can specify which range(s) of time delays to consider
    sig_pairs{db} = sig_time_delays;
end

% Count proportion of correlated pairs, including pairs that do not have
% enough data for kstest (which are clearly not correlated)
correlated_counts = [];
for db = 1:length(dbs)
    correlated_counts = [correlated_counts; sum(sig_pairs{db}(:,1)) length(sig_pairs{db}(:,1))+length(skipped_pairs{db})];
end

f = figure;
bar(correlated_counts(:,1)./correlated_counts(:,2));
strs = {'Control', 'Stress', 'Stress2'};
set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
xlabel('Experimental Group'); ylabel('Proportion');

[~,p] = chi2test(correlated_counts(1,1), correlated_counts(1,2), ...
                                                correlated_counts(2,1), correlated_counts(2,2), ...
                                                correlated_counts(3,1), correlated_counts(3,2));
                                            
title({'Proportion of Correlated Pairs Based On Time Delays', ...
        ['Chi Square Test p = ' num2str(p)]});
for db = 1:length(dbs)
    text(db-.2, correlated_counts(db,1)./correlated_counts(db,2)+.05, [num2str(correlated_counts(db,1)) '/' num2str(correlated_counts(db,2)) ' (' num2str(correlated_counts(db,1)/correlated_counts(db,2)) ')']);
end
ylim([0 max(correlated_counts(:,1)./correlated_counts(:,2))+.1]);

fig_dir = [ROOT_DIR 'Correlation Using Phasic Activity/' comparison_type '/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir)
end
saveas(f, [fig_dir 'Proportion of Correlated Pairs'], 'fig');
saveas(f, [fig_dir 'Proportion of Correlated Pairs'], 'jpg');
saveas(f, [fig_dir 'Proportion of Correlated Pairs'], 'epsc2');


%% Based on timing, get significant pairs
% For these pairs, find peak time delay
peak_time_delays = cell(1,length(dbs));
sig_threshold = .05;
time_delay_bins = 0:.5/20:.5;
for db = 1:length(dbs)
    correlated_pairs = find(any(original_ps{db} <= sig_threshold,2));
    for pair_num = 1:length(correlated_pairs)
        correlated_pair_num = correlated_pairs(pair_num);
        [N,centers] = hist(phasic_time_delays{db}{correlated_pair_num}(phasic_time_delays{db}{correlated_pair_num} ~=0 & phasic_time_delays{db}{correlated_pair_num} < .5),time_delay_bins);
                
        peak_time_delay_idx = find(N >= mean(N)+std(N),1,'first');
        if ~isempty(peak_time_delay_idx)
            peak_time_delays{db} = [peak_time_delays{db} centers(peak_time_delay_idx)];
        end
    end
end

f = figure;
subplot(3,1,1); [N, centers] = hist(peak_time_delays{1},time_delay_bins); bar(centers,N);
xlabel('"Most Common Time Delay"'); ylabel('Count'); title('Control'); ylim([0 5]);
subplot(3,1,2); [N, centers] = hist(peak_time_delays{2},time_delay_bins); bar(centers,N);
xlabel('"Most Common Time Delay"'); ylabel('Count'); title('Stress'); ylim([0 5]);
subplot(3,1,3); [N, centers] = hist(peak_time_delays{3},time_delay_bins); bar(centers,N);
xlabel('"Most Common Time Delay"'); ylabel('Count'); title('Stress2'); ylim([0 5]);

fig_dir = [ROOT_DIR 'Correlation Using Phasic Activity/' comparison_type '/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir)
end
saveas(f, [fig_dir 'Peak of Time Delays'], 'fig');
saveas(f, [fig_dir 'Peak of Time Delays'], 'jpg');
saveas(f, [fig_dir 'Peak of Time Delays'], 'epsc2');