%% This script analyzes data from the stimulation experiment.
bin_times = -.06 + 1/(2*750) : 1/(750) : .06 - 1/(2*750); % closest to 0 from negative side is bin 45
%% Plot firing rates aligned to PL stimulation event
% Initialize cell array of firing rates aligned to PL stimulation event
strio_firing_rates = cell(1,length(dbs));
                
% Get data on spikes aligned to PL stimulation event and convert to zscores
for db = 1:length(dbs)
    %% For striosomes
    strio_firing_rates{db} = cell(1,length(all_strio_ids{db})); % Record firing rates for each neuron
    
    for strio_id_num = 1:length(all_strio_ids{db})
        % Get stimulation spike data
        strio_id = all_strio_ids{db}(strio_id_num);
        spikes = twdbs{db}(strio_id).striosomality2_spikes_array;
        
        % Bin stimulation spike data in each trial
        for trial = 1:length(spikes)
            [bin_counts,~] = histcounts(spikes{trial},bin_times);
            strio_firing_rates{db}{strio_id_num}(trial,:) = bin_counts;
        end
        
        % Sum binned spikes per trial to normalize by neuron
        strio_firing_rates{db}{strio_id_num} = sum(strio_firing_rates{db}{strio_id_num},1);
        
        % If there were no spikes, ignore the neuron
        if sum(isnan(strio_firing_rates{db}{strio_id_num})) || sum(strio_firing_rates{db}{strio_id_num}) == 0
            strio_firing_rates{db}{strio_id_num} = [];
        end
        
        % Convert to zscores
        if ~isempty(strio_firing_rates{db}{strio_id_num})
            BLmean = mean(strio_firing_rates{db}{strio_id_num}(2:43)); BLstd = std(strio_firing_rates{db}{strio_id_num}(2:43));
            % Can't calculate zscore if the standard deviation is zero
            if BLstd ~= 0
                strio_firing_rates{db}{strio_id_num} = (strio_firing_rates{db}{strio_id_num} - BLmean) / BLstd;
            else
                strio_firing_rates{db}{strio_id_num} = [];
            end
        end
    end
    % Convert the cell array to matrix (easier to work with)
    % The size of the resulting matrix is - # rows: # analyzable neurons
    %                                     - # columns: # of bins
    strio_firing_rates{db} = reshape(cell2mat(strio_firing_rates{db}),[length(bin_times)-1 length(cell2mat(strio_firing_rates{db}))/(length(bin_times)-1)])';
end
%% Draw figures
str = {'Control', 'Stress', 'Stress2'};
bin_times = -.06 + 1/(2*750) : 1/(750) : .06 - 1/(2*750); % closest to 0 from negative side is bin 45
bin_times = bin_times(1:end-1); % Each time point represents the time interval [bin_time(k), bin_time(k) + 1/750]
%% Striosomes
% SNR: Only consider neurons with a response greater than a certain
% threshold
strio_firing_rates{1} = strio_firing_rates{1}(max(strio_firing_rates{1}')>10,:);
strio_firing_rates{2} = strio_firing_rates{2}(max(strio_firing_rates{2}')>10,:);
strio_firing_rates{3} = strio_firing_rates{3}(max(strio_firing_rates{3}')>10,:);

% Plot each individual neuron and the time of peak rise found
strio_peak_times = cell(1,length(dbs));
f = figure;
for db = 1:length(dbs)
    for strio_id = 1:size(strio_firing_rates{db},1)
        clf; 
        hold on;
        % Determine time of rise and fall (first time zscore is greater than 1, after time 0 (PL stim))
        I1 = find(strio_firing_rates{db}(strio_id,ceil(length(bin_times)/2)+1:end) >= 1, 1, 'first') + ceil(length(bin_times)/2); % Time of rise
        I2 = find(strio_firing_rates{db}(strio_id,I1:end) <= 1, 1, 'first') + I1 - 1; % Time of fall
        
        strio_peak_times{db} = [strio_peak_times{db} bin_times(I1)];
    end
end

fig_dir = [ROOT_DIR 'Response To Stimulation'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
% Boxplot of peak rise times
f = figure;
g = [repmat({'Control'},[length(strio_peak_times{1}),1]);repmat({'Stress'},[length(strio_peak_times{2}),1]);repmat({'Stress2'},[length(strio_peak_times{3}),1])]; g = flipud(g);
boxplot(gca,fliplr(cell2mat(strio_peak_times)),g,'Orientation', 'Horizontal');
p1 = ranksum(strio_peak_times{1}, strio_peak_times{2});
p2 = ranksum(strio_peak_times{1}, strio_peak_times{3});
ylabel('Experimental Group'); xlabel('Time of Peak Rise After Stimulation');
title({'Striosomes - Time of Peak Rise After Stimulation of PL', ...
        ['Control vs Stress Wilcoxon Rank Sum Test p = ' num2str(p1)], ...
        ['Control vs Stress2 Wilcoxon Rank Sum Test p = ' num2str(p2)]});
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Boxplot of Peak Rise Times.fig']);
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Boxplot of Peak Rise Times.eps'],'epsc2');

% Histogram of peak rise times
f = figure;
subplot(3,1,1); [N, centers] = hist(strio_peak_times{1},-.01:.05/(5*8):.04);
bar(centers,N/sum(N)); xlim([0 .015]);
title('Control'); xlabel('Time (s)'); ylabel('PDF of Peak Rise Times');
subplot(3,1,2); [N, centers] = hist(strio_peak_times{2},-.01:.05/(5*8):.04);
bar(centers,N/sum(N)); xlim([0 .015]);
title('Stress'); xlabel('Time (s)'); ylabel('PDF of Peak Rise Times');
subplot(3,1,3); [N, centers] = hist(strio_peak_times{3},-.01:.05/(5*8):.04);
bar(centers,N/sum(N)); xlim([0 .015]);
title('Stress2'); xlabel('Time (s)'); ylabel('PDF of Peak Rise Times');
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Histogram of Peak Rise Times.fig']);
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Histogram of Peak Rise Times.eps'],'epsc2');

% Bar graph of peak rise times
f = figure;
strio_peak_time_means = cellfun(@mean, strio_peak_times,'uni',false); 
strio_peak_time_stderrs = cellfun(@(x) std(x)/sqrt(size(x,1)), strio_peak_times,'uni',false);
[~,p1] = ttest2(strio_peak_times{1}, strio_peak_times{2});
[~,p2] = ttest2(strio_peak_times{1}, strio_peak_times{3});
barwitherr(cell2mat(strio_peak_time_stderrs), cell2mat(strio_peak_time_means));
set(gca, 'XTickLabel',str, 'XTick',1:numel(str));
xlabel('Experimental Group'); ylabel('Time of Peak Rise After Stimulation');
title({'Striosomes - Time of Peak Rise After Stimulation of PL', ...
        ['Control vs Stress ttest2 p = ' num2str(p1)], ...
        ['Control vs Stress2 ttest2 p = ' num2str(p2)]});
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Bar Graph of Peak Rise Times.fig']);
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Bar Graph of Peak Rise Times.eps'],'epsc2');

% Histogram of response to stimulation zscores
f = figure; hold all;
strio_means = cellfun(@mean, strio_firing_rates,'uni',false); 
strio_stderrs = cellfun(@(x) std(x)/sqrt(size(x,1)), strio_firing_rates,'uni',false);
[hp1, hL1] = dg_plotShadeCL(gca, [bin_times;strio_means{1}-strio_stderrs{1};strio_means{1}+strio_stderrs{1};strio_means{1}]', ...
                    'Color', [0 0 0], 'FaceColor', 'r', 'LineWidth', 2);
[hp2, ~] = dg_plotShadeCL(gca, [bin_times;strio_means{2}-strio_stderrs{2};strio_means{2}+strio_stderrs{2};strio_means{2}]', ...
                    'Color', [0 0 0], 'FaceColor', 'b', 'LineWidth', 2);
[hp3, ~] = dg_plotShadeCL(gca, [bin_times;strio_means{3}-strio_stderrs{3};strio_means{3}+strio_stderrs{3};strio_means{3}]', ...
                    'Color', [0 0 0], 'FaceColor', 'g', 'LineWidth', 2);

legend([hp1,hp2,hp3],['Control N = ' num2str(size(strio_firing_rates{1},1))],...
                    ['Stress N = ' num2str(size(strio_firing_rates{2},1))],...
                    ['Stress2 N = ' num2str(size(strio_firing_rates{3},1))]);
xlim([0-.002 .02]); xlabel('Time (s)'); ylabel('Z Score of Firing Rate');
uistack(hp1,'top'); uistack(hL1,'top');
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Plot of Zscores of Firing Rates Over Time.fig']);
saveas(f, [ROOT_DIR 'Response To Stimulation/Striosomes Plot of Zscores of Firing Rates Over Time.eps'],'epsc2');
%% Generate a plot comparing the proportion of SWNs responding to stimulation
%  across experimental groups.

% Find SWNs that respond to stimulation
control_swn_ids = twdb_lookup(twdb_control, 'index', 'key', 'tetrodeType', 'dms', 'grade', 'striosomality2_type', 4, 5, 'grade', 'striosomality2_grade', 2, NaN, 'key', 'neuron_type', 'SWN', 'grade', 'final_michael_grade', 1, 5, 'grade');
stress_swn_ids = twdb_lookup(twdb_stress, 'index', 'key', 'tetrodeType', 'dms', 'grade', 'striosomality2_type', 4, 5, 'grade', 'striosomality2_grade', 2, NaN, 'key', 'neuron_type', 'SWN', 'grade', 'final_michael_grade', 1, 5, 'grade');
stress2_swn_ids = twdb_lookup(twdb_stress2, 'index', 'key', 'tetrodeType', 'dms', 'grade', 'striosomality2_type', 4, 5, 'grade', 'striosomality2_grade', 2, NaN, 'key', 'neuron_type', 'SWN', 'grade', 'final_michael_grade', 1, 5, 'grade');
swn_ids = {control_swn_ids, stress_swn_ids, stress2_swn_ids};
swn_ids = cellfun(@(x) cellfun(@str2num, x), swn_ids, 'uni', false);
% Calculate the chi square statistic
total_swns = cellfun(@length,all_swn_ids);
swn_ids = cellfun(@(x) x', swn_ids,'uni',false);
[h,p] = chi2test(size(swn_ids{1},1),total_swns(1), ...
                size(swn_ids{2},1),total_swns(2), ...
                size(swn_ids{3},1),total_swns(3));
disp('# SWNs Responding To Stimulation/# SWNs');
disp(['Control: ' num2str(size(swn_ids{1},1)) '/' num2str(total_swns(1)) ' (' num2str(size(swn_ids{1},1)/total_swns(1)) ')']);
disp(['Stress : ' num2str(size(swn_ids{2},1)) '/' num2str(total_swns(2)) '  (' num2str(size(swn_ids{2},1)/total_swns(2)) ')']);
disp(['Stress2: ' num2str(size(swn_ids{3},1)) '/' num2str(total_swns(3)) ' (' num2str(size(swn_ids{3},1)/total_swns(3)) ')']);
disp(['Chi Square Test p = ' num2str(p)]);
% Make a bar graph showing the results
f = figure;
bar([size(swn_ids{1},1)/total_swns(1),...
    size(swn_ids{2},1)/total_swns(2),...
    size(swn_ids{3},1)/total_swns(3)]);
text(1, size(swn_ids{1},1)/total_swns(1)+.01, [num2str(size(swn_ids{1},1)) '/' num2str(total_swns(1)) ' (' num2str(size(swn_ids{1},1)/total_swns(1)) ')']);
text(2, size(swn_ids{2},1)/total_swns(2)+.01, [num2str(size(swn_ids{2},1)) '/' num2str(total_swns(2)) ' (' num2str(size(swn_ids{2},1)/total_swns(2)) ')']);
text(3, size(swn_ids{3},1)/total_swns(3)+.01, [num2str(size(swn_ids{3},1)) '/' num2str(total_swns(3)) ' (' num2str(size(swn_ids{3},1)/total_swns(3)) ')']);
strs = {'Control', 'Stress', 'Stress2'};
set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
ylim([0 .08]);
xlabel('Experimental Group'); ylabel('# SWNs Responding to Stimulation/# SWNs');
title({'Proportion of SWNs Responding to Stimulation',...
        ['Chi Square Test p = ' num2str(p)]});
saveas(f, [ROOT_DIR 'Response To Stimulation/Proportion of SWNs Responding to Stimulation'], 'fig');
saveas(f, [ROOT_DIR 'Response To Stimulation/Proportion of SWNs Responding to Stimulation'], 'epsc2');
saveas(f, [ROOT_DIR 'Response To Stimulation/Proportion of SWNs Responding to Stimulation'], 'jpg');
%% Generate a plot comparing the proportion of striosomes neurons responding to stimulation
%  across experimental groups

% Calculate the chi square statistic
totals = zeros(1,length(dbs));
for db = 1:length(dbs)
    totals(db) = length(find(strcmp({twdbs{db}.tetrodeType}, 'dms')));
end
[h,p] = chi2test(size(all_strio_ids{1},2),totals(1), ...
                size(all_strio_ids{2},2),totals(2), ...
                size(all_strio_ids{3},2),totals(3));
disp('# MSNs Responding To Stimulation/# MSNs');
disp(['Control: ' num2str(size(all_strio_ids{1},2)) '/' num2str(totals(1)) ' (' num2str(size(all_strio_ids{1},1)/totals(1)) ')']);
disp(['Stress : ' num2str(size(all_strio_ids{2},2)) '/' num2str(totals(2)) '  (' num2str(size(all_strio_ids{2},1)/totals(2)) ')']);
disp(['Stress2: ' num2str(size(all_strio_ids{3},2)) '/' num2str(totals(3)) ' (' num2str(size(all_strio_ids{3},1)/totals(3)) ')']);
disp(['Chi Square Test p = ' num2str(p)]);
% Make a bar graph showing the results
f = figure;
bar([size(all_strio_ids{1},2)/totals(1),...
    size(all_strio_ids{2},2)/totals(2),...
    size(all_strio_ids{3},2)/totals(3)])
text(1, size(all_strio_ids{1},2)/totals(1)+.01, [num2str(size(all_strio_ids{1},2)) '/' num2str(totals(1)) ' (' num2str(size(all_strio_ids{1},2)/totals(1)) ')']);
text(2, size(all_strio_ids{2},2)/totals(2)+.01, [num2str(size(all_strio_ids{2},2)) '/' num2str(totals(2)) ' (' num2str(size(all_strio_ids{2},2)/totals(2)) ')']);
text(3, size(all_strio_ids{3},2)/totals(3)+.01, [num2str(size(all_strio_ids{3},2)) '/' num2str(totals(3)) ' (' num2str(size(all_strio_ids{3},2)/totals(3)) ')']);
strs = {'Control', 'Stress', 'Stress2'};
set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
ylim([0 .08]);
xlabel('Experimental Group'); ylabel('# MSNs Responding to Stimulation/# MSNs');
title({'Proportion of MSNs Responding to Stimulation',...
        ['Chi Square Test p = ' num2str(p)]});
saveas(f, [ROOT_DIR 'Response To Stimulation/Proportion of MSNs Responding to Stimulation'], 'fig');
saveas(f, [ROOT_DIR 'Response To Stimulation/Proportion of MSNs Responding to Stimulation'], 'epsc2');
saveas(f, [ROOT_DIR 'Response To Stimulation/Proportion of MSNs Responding to Stimulation'], 'jpg');
