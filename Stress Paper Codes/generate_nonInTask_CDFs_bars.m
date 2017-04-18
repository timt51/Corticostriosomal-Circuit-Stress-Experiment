%% This script generates CDFs and bar graphs of firing rate of neurons 
%  during the overall, baseline, and lick periods of the Cost Benefit Task.

% Neuron type activity is binned. The following variables correspond to the
% index of the windows corresponding the the baseline and lick periods.
BLstart = 60; BLend = 240;
LICKstart = 360; LICKend = 420;
window_starts = [316,316,321,321,310,310];
window_ends = [330,330,335,335,320,320];

% Initialize variables to store firing rates by neuron type
neuron_type_overall_FRs = cell(1,length(neuron_types));
neuron_type_baseline_FRs = cell(1,length(neuron_types));
neuron_type_lick_FRs = cell(1,length(neuron_types));

for neuron_type_idx = 1:length(neuron_types)
    % Initialize variables to store firing rates by database
    neuron_type_overall_FRs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_baseline_FRs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_lick_FRs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_ids = cb_ids{neuron_type_idx};
    
    for db = 1:length(dbs)
        for neuron_idx = 1:length(neuron_type_ids{db})
            % For each neuron, calculate firing rate during the baseline 
            % and lick periods.
            [~, ~, BLmean, ~, ~, ~] = quantify_neuron_activity(twdbs{db},...
                                    neuron_type_ids{db}(neuron_idx),'spikes',...
                                    BLstart,BLend,window_starts(neuron_type_idx),...
                                    window_ends(neuron_type_idx));
            neuron_type_baseline_FRs{neuron_type_idx}{db} = [neuron_type_baseline_FRs{neuron_type_idx}{db} BLmean];
            
            [~, ~, lick_mean, ~, ~, ~] = quantify_neuron_activity(twdbs{db},...
                                    neuron_type_ids{db}(neuron_idx),'spikes',...
                                    LICKstart,LICKend,window_starts(neuron_type_idx),...
                                    window_ends(neuron_type_idx));
            neuron_type_lick_FRs{neuron_type_idx}{db} = [neuron_type_lick_FRs{neuron_type_idx}{db} lick_mean];
        end
        % The overal firing rate is already stored in the database.
        neuron_type_overall_FRs{neuron_type_idx}{db} = [twdbs{db}(neuron_type_ids{db}).firing_rate];
    end
end

for neuron_type_idx = 1:length(neuron_types)
    disp(['CDFs of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx}]);
    fig_dir = [ROOT_DIR '/Firing Rate CDFs/Overall/' neuron_types{neuron_type_idx} '/'];
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir)
    end
    
    % Make CDF graph
    f = figure;
    hold on;
    cdfplot(neuron_type_overall_FRs{neuron_type_idx}{1});
    cdfplot(neuron_type_overall_FRs{neuron_type_idx}{2});
    cdfplot(neuron_type_overall_FRs{neuron_type_idx}{3});
    hold off;
    xlim([0 12]); ylim([0 1]);
    legend('Control', 'Stress', 'Stress2');
    
    % Run kstest2
    [~,p1,~] = kstest2(neuron_type_overall_FRs{neuron_type_idx}{1}, neuron_type_overall_FRs{neuron_type_idx}{2});
    [~,p2,~] = kstest2(neuron_type_overall_FRs{neuron_type_idx}{1}, neuron_type_overall_FRs{neuron_type_idx}{3});
    
    % Make title and save
    title({['CDF of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], ...
            ['Control vs Stress kstest2 p = ' num2str(p1)], ...
            ['Control vs Stress2 kstest2 p = ' num2str(p2)]});
    saveas(f, [fig_dir 'CDF of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx}],'fig');
    saveas(f, [fig_dir 'CDF of Overall Firing Rates In CBC Tasks For All ' neuron_types{neuron_type_idx}],'epsc2');
    saveas(f, [fig_dir 'CDF of Overall Firing Rates In CBC Tasks For All ' neuron_types{neuron_type_idx}],'jpg');
    
    % Make bar graph
    f = figure;
    means = cellfun(@(x) mean(x(~isnan(x))),neuron_type_overall_FRs{neuron_type_idx});
    stderrs = cellfun(@(x) std(x(~isnan(x)))/sqrt(length(x(~isnan(x)))),neuron_type_overall_FRs{neuron_type_idx});
    barwitherr(stderrs,means);
    strs = {'Control', 'Stress', 'Stress2'};
    set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
    
    %Run ttest2
    [~,p1,~] = ttest2(neuron_type_overall_FRs{neuron_type_idx}{1}, neuron_type_overall_FRs{neuron_type_idx}{2});
    [~,p2,~] = ttest2(neuron_type_overall_FRs{neuron_type_idx}{1}, neuron_type_overall_FRs{neuron_type_idx}{3});
    
    title({['Mean Overall Firing Rates of ' neuron_types{neuron_type_idx} ' Across Experimental Groups'], ...
        ['Control vs Stress ttest2 p = ' num2str(p1)], ...
        ['Control vs Stress2 ttest2 p = ' num2str(p2)]});
    saveas(f, [fig_dir 'Bar Graph of Overall Firing Rate of ' neuron_types{neuron_type_idx}], 'fig');
    saveas(f, [fig_dir 'Bar Graph of Overall Firing Rate of ' neuron_types{neuron_type_idx}], 'epsc2');
    saveas(f, [fig_dir 'Bar Graph of Overall Firing Rate of ' neuron_types{neuron_type_idx}], 'jpg');
end

for neuron_type_idx = 1:length(neuron_types)
    disp(['CDFs of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}]);
    fig_dir = [ROOT_DIR '/Firing Rate CDFs/Baseline/' neuron_types{neuron_type_idx} '/'];
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir)
    end
    
    % Make CDF graph
    f = figure;
    hold on;
    cdfplot(neuron_type_baseline_FRs{neuron_type_idx}{1});
    cdfplot(neuron_type_baseline_FRs{neuron_type_idx}{2});
    cdfplot(neuron_type_baseline_FRs{neuron_type_idx}{3});
    hold off;
    xlim([0 12]); ylim([0 1]);
    legend('Control', 'Stress', 'Stress2');
    
    % Run kstest2
    [~,p1,~] = kstest2(neuron_type_baseline_FRs{neuron_type_idx}{1}, neuron_type_baseline_FRs{neuron_type_idx}{2});
    [~,p2,~] = kstest2(neuron_type_baseline_FRs{neuron_type_idx}{1}, neuron_type_baseline_FRs{neuron_type_idx}{3});
    
    % Make title and save
    title({['CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], ...
            ['Control vs Stress kstest2 p = ' num2str(p1)], ...
            ['Control vs Stress2 kstest2 p = ' num2str(p2)]});
    saveas(f, [fig_dir 'CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}],'fig');
    saveas(f, [fig_dir 'CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}],'epsc2');
    saveas(f, [fig_dir 'CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}],'jpg');
    
    % Make bar graph
    f = figure;
    means = cellfun(@(x) mean(x(~isnan(x))),neuron_type_baseline_FRs{neuron_type_idx});
    stderrs = cellfun(@(x) std(x(~isnan(x)))/sqrt(length(x(~isnan(x)))),neuron_type_baseline_FRs{neuron_type_idx});
    barwitherr(stderrs,means);
    strs = {'Control', 'Stress', 'Stress2'};
    set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
    
    %Run ttest2
    [~,p1,~] = ttest2(neuron_type_baseline_FRs{neuron_type_idx}{1}, neuron_type_baseline_FRs{neuron_type_idx}{2});
    [~,p2,~] = ttest2(neuron_type_baseline_FRs{neuron_type_idx}{1}, neuron_type_baseline_FRs{neuron_type_idx}{3});

    title({['Mean Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], ...
            ['Control vs Stress ttest2 p = ' num2str(p1)], ...
            ['Control vs Stress2 ttest2 p = ' num2str(p2)]});
    saveas(f, [fig_dir 'Bar Graph of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], 'fig');
    saveas(f, [fig_dir 'Bar Graph of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], 'epsc2');
    saveas(f, [fig_dir 'Bar Graph of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], 'jpg');
end


for neuron_type_idx = 1:length(neuron_types)
    disp(['CDFs of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}]);
    fig_dir = [ROOT_DIR '/Firing Rate CDFs/Lick/' neuron_types{neuron_type_idx} '/'];
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir)
    end
    
    % Make CDF graph
    f = figure;
    hold on;
    cdfplot(neuron_type_lick_FRs{neuron_type_idx}{1});
    cdfplot(neuron_type_lick_FRs{neuron_type_idx}{2});
    cdfplot(neuron_type_lick_FRs{neuron_type_idx}{3});
    hold off;
    xlim([0 12]); ylim([0 1]);
    legend('Control', 'Stress', 'Stress2');
    
    % Run kstest2
    [~,p1,~] = kstest2(neuron_type_lick_FRs{neuron_type_idx}{1}, neuron_type_lick_FRs{neuron_type_idx}{2});
    [~,p2,~] = kstest2(neuron_type_lick_FRs{neuron_type_idx}{1}, neuron_type_lick_FRs{neuron_type_idx}{3});
    
    % Make title and save
    title({['CDF of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], ...
            ['Control vs Stress kstest2 p = ' num2str(p1)], ...
            ['Control vs Stress2 kstest2 p = ' num2str(p2)]});
    saveas(f, [fig_dir 'CDF of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}],'fig');
    saveas(f, [fig_dir 'CDF of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}],'epsc2');
    saveas(f, [fig_dir 'CDF of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}],'jpg');
    
    % Make bar graph
    f = figure;
    means = cellfun(@(x) mean(x(~isnan(x))),neuron_type_lick_FRs{neuron_type_idx});
    stderrs = cellfun(@(x) std(x(~isnan(x)))/sqrt(length(x(~isnan(x)))),neuron_type_lick_FRs{neuron_type_idx});
    barwitherr(stderrs,means);
    strs = {'Control', 'Stress', 'Stress2'};
    set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
    
    %Run ttest2
    [~,p1,~] = ttest2(neuron_type_lick_FRs{neuron_type_idx}{1}, neuron_type_lick_FRs{neuron_type_idx}{2});
    [~,p2,~] = ttest2(neuron_type_lick_FRs{neuron_type_idx}{1}, neuron_type_lick_FRs{neuron_type_idx}{3});

    title({['Mean Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], ...
            ['Control vs Stress ttest2 p = ' num2str(p1)], ...
            ['Control vs Stress2 ttest2 p = ' num2str(p2)]});
    saveas(f, [fig_dir 'Bar Graph of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], 'fig');
    saveas(f, [fig_dir 'Bar Graph of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], 'epsc2');
    saveas(f, [fig_dir 'Bar Graph of Lick Firing Rates In CBC For All ' neuron_types{neuron_type_idx}], 'jpg');
end
%% Per Rat Firing Rates - do the same as above, but split the data by rat
BLstart = 60; BLend = 240;
window_starts = [316,316,321,321,310,310];
window_ends = [330,330,335,335,320,320];
neuron_type_overall_FRs = cell(1,length(neuron_types));
neuron_type_baseline_FRs = cell(1,length(neuron_types));

for neuron_type_idx = 1:length(neuron_types)
    neuron_type_overall_FRs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_baseline_FRs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_ids = cb_ids{neuron_type_idx};
    
    for db = 1:length(dbs)
        ratIDs = unique({twdbs{db}.ratID});
        neuron_type_overall_FRs{neuron_type_idx}{db} = cell(1,length(ratIDs));
        neuron_type_baseline_FRs{neuron_type_idx}{db} = cell(1,length(ratIDs));
        
        for rat_idx = 1:length(ratIDs)
            ids_of_rat = neuron_type_ids{db}(strcmp({twdbs{db}(neuron_type_ids{db}).ratID},ratIDs{rat_idx}));
            
            for neuron_idx = 1:length(ids_of_rat)
                [zscore, ~, BLmean, ~, FR, ~] = quantify_neuron_activity(twdbs{db},...
                                        ids_of_rat(neuron_idx),'spikes',...
                                        BLstart,BLend,window_starts(neuron_type_idx),...
                                        window_ends(neuron_type_idx));
                neuron_type_baseline_FRs{neuron_type_idx}{db}{rat_idx} = [neuron_type_baseline_FRs{neuron_type_idx}{db}{rat_idx} BLmean];
            end
            neuron_type_overall_FRs{neuron_type_idx}{db}{rat_idx} = [twdbs{db}(ids_of_rat).firing_rate];
        end
    end
end

% Remove empty cells
for neuron_type_idx = 1:length(neuron_types)
    for db = 1:length(dbs)
        neuron_type_overall_FRs{neuron_type_idx}{db}(cellfun(@isempty,...
                                                    neuron_type_overall_FRs{neuron_type_idx}{db})) = [];
        neuron_type_baseline_FRs{neuron_type_idx}{db}(cellfun(@isempty,...
                                                    neuron_type_baseline_FRs{neuron_type_idx}{db})) = [];
    end
end

% Convert lists of zscores and firing rates into CDFs
neuron_type_overall_cdfs = cell(1,length(neuron_types));
neuron_type_baseline_cdfs = cell(1,length(neuron_types));
for neuron_type_idx = 1:length(neuron_types)
    neuron_type_overall_cdfs{neuron_type_idx} = cell(1,length(dbs));
    neuron_type_baseline_cdfs{neuron_type_idx} = cell(1,length(dbs));
    
    for db = 1:length(dbs);
        neuron_type_overall_cdfs{neuron_type_idx}{db} = reshape(cell2mat(cellfun(@(x) histcdf(x,-1:10/1000:9), ...
                                                                    neuron_type_overall_FRs{neuron_type_idx}{db},'uni',false)), ...
                                                        [1000 length(neuron_type_overall_FRs{neuron_type_idx}{db})])';
        neuron_type_baseline_cdfs{neuron_type_idx}{db} = reshape(cell2mat(cellfun(@(x) histcdf(x,-1:10/1000:9), ...
                                                                    neuron_type_baseline_FRs{neuron_type_idx}{db},'uni',false)), ...
                                                        [1000 length(neuron_type_baseline_FRs{neuron_type_idx}{db})])';
    end
end

for neuron_type_idx = 1:length(neuron_types)
    disp(['CDFs of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat']);
    fig_dir = [ROOT_DIR '/Firing Rate CDFs/Overall/' neuron_types{neuron_type_idx} '/'];
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir)
    end

    % Make graph and save
    f = figure;
    means = cellfun(@mean, neuron_type_overall_cdfs{neuron_type_idx}, 'uni', false);
    stderrs = cellfun(@(x) std(x)/sqrt(size(x,1)), neuron_type_overall_cdfs{neuron_type_idx}, 'uni', false);
    [hp1, ~] = dg_plotShadeCL(gca, [-1:10/1000:9-10/1000;means{1}-stderrs{1};means{1}+stderrs{1};means{1}]', ...
                        'Color', [0 0 0], 'FaceColor', 'b', 'LineWidth', 2);
    [hp2, ~] = dg_plotShadeCL(gca, [-1:10/1000:9-10/1000;means{2}-stderrs{2};means{2}+stderrs{2};means{2}]', ...
                        'Color', [0 0 0], 'FaceColor', 'r', 'LineWidth', 2);
    [hp3, ~] = dg_plotShadeCL(gca, [-1:10/1000:9-10/1000;means{3}-stderrs{3};means{3}+stderrs{3};means{3}]', ...
                        'Color', [0 0 0], 'FaceColor', 'y', 'LineWidth', 2);
    legend([hp1, hp2, hp3], 'Control', 'Stress', 'Stress2');
    title(['CDF of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' (Per Rat)']);
    xlabel('Firing Rate'); ylabel('Probability'); ylim([0 1]);
    saveas(f, [fig_dir 'Mean CDF of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat'], 'fig');
    saveas(f, [fig_dir 'Mean CDF of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat'], 'epsc2');
    saveas(f, [fig_dir 'Mean CDF of Overall Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat'], 'jpg');
end

for neuron_type_idx = 1:length(neuron_types)
    disp(['CDFs of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat']);
    fig_dir = [ROOT_DIR '/Firing Rate CDFs/Baseline/' neuron_types{neuron_type_idx} '/'];
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir)
    end

    % Make graph and save
    f = figure;
    means = cellfun(@mean, neuron_type_baseline_cdfs{neuron_type_idx}, 'uni', false);
    stderrs = cellfun(@(x) std(x)/sqrt(size(x,1)), neuron_type_baseline_cdfs{neuron_type_idx}, 'uni', false);
    [hp1, ~] = dg_plotShadeCL(gca, [-1:10/1000:9-10/1000;means{1}-stderrs{1};means{1}+stderrs{1};means{1}]', ...
                        'Color', [0 0 0], 'FaceColor', 'b', 'LineWidth', 2);
    [hp2, ~] = dg_plotShadeCL(gca, [-1:10/1000:9-10/1000;means{2}-stderrs{2};means{2}+stderrs{2};means{2}]', ...
                        'Color', [0 0 0], 'FaceColor', 'r', 'LineWidth', 2);
    [hp3, ~] = dg_plotShadeCL(gca, [-1:10/1000:9-10/1000;means{3}-stderrs{3};means{3}+stderrs{3};means{3}]', ...
                        'Color', [0 0 0], 'FaceColor', 'y', 'LineWidth', 2);
    legend([hp1, hp2, hp3], 'Control', 'Stress', 'Stress2');
    title(['CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' (Per Rat)']);
    xlabel('Firing Rate'); ylabel('Probability'); ylim([0 1]);
    saveas(f, [fig_dir 'Mean CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat'], 'fig');
    saveas(f, [fig_dir 'Mean CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat'], 'epsc2');
    saveas(f, [fig_dir 'Mean CDF of Baseline Firing Rates In CBC For All ' neuron_types{neuron_type_idx} ' Per Rat'], 'jpg');
end
