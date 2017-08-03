%% This script compares the model with the real data.
% First, we compare the mean time that neurons are most active.

% Load the data
dbs = {'control', 'stress', 'stress2'};
load('all_times_of_max_real.mat');
load('all_times_of_max_review_model_floor_effect.mat');
bins = -3:.5:6;

% Collect the real and model data for striosomes into one matrix
bar_err = zeros([3,2]);
bar_y = zeros([3,2]);
for db = 1:length(dbs)
    bar_err(db,1) = std(all_times_of_max_real{3}{db})/sqrt(length(all_times_of_max_real{3}{db}));
    bar_y(db,1) = mean(all_times_of_max_real{3}{db});
end
for db = 1:length(dbs)
    bar_err(db,2) = std(all_times_of_max_model{3}{db})/sqrt(length(all_times_of_max_model{3}{db}));
    bar_y(db,2) = mean(all_times_of_max_model{3}{db});
end

% Run the statistical test and plot the results
[~,p1] = ttest2(all_times_of_max_real{3}{1}, all_times_of_max_model{3}{1});
[~,p2] = ttest2(all_times_of_max_real{3}{2}, all_times_of_max_model{3}{2});
[~,p3] = ttest2(all_times_of_max_real{3}{3}, all_times_of_max_model{3}{3});
f=figure; barwitherr(bar_err, bar_y);
legend('Real', 'Model');
xlabel('Experimental Group');
ylabel('Time (s)');
title({'Mean Time of Peak Activity of Active Striosomes Relative to Click Time',...
        ['Control: ttest2 p =' num2str(p1)], ...
        ['Stress: ttest2 p =' num2str(p2)], ...
        ['Stress2: ttest2 p =' num2str(p3)]});
fig_dir = [ROOT_DIR 'Review/Model Floor Effect/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f, [fig_dir 'Striosomes Mean Time of Peak Activity'], 'fig');
saveas(f, [fig_dir 'Striosomes Mean Time of Peak Activity'], 'epsc2');
saveas(f, [fig_dir 'Striosomes Mean Time of Peak Activity'], 'jpg');

% Do the same for SWNs
bar_err = zeros([3,2]);
bar_y = zeros([3,2]);
for db = 1:length(dbs)
    bar_err(db,1) = std(all_times_of_max_real{6}{db})/sqrt(length(all_times_of_max_real{6}{db}));
    bar_y(db,1) = mean(all_times_of_max_real{6}{db});
end
for db = 1:length(dbs)
    bar_err(db,2) = std(all_times_of_max_model{6}{db})/sqrt(length(all_times_of_max_model{6}{db}));
    bar_y(db,2) = mean(all_times_of_max_model{6}{db});
end

[~,p1] = ttest2(all_times_of_max_real{6}{1}, all_times_of_max_model{6}{1});
[~,p2] = ttest2(all_times_of_max_real{6}{2}, all_times_of_max_model{6}{2});
[~,p3] = ttest2(all_times_of_max_real{6}{3}, all_times_of_max_model{6}{3});
f=figure; barwitherr(bar_err, bar_y);
legend('Real', 'Model');
xlabel('Experimental Group');
ylabel('Time (s)');
title({'Mean Time of Peak Activity of Active SWNs Relative to Click Time',...
        ['Control: ttest2 p =' num2str(p1)], ...
        ['Stress: ttest2 p =' num2str(p2)], ...
        ['Stress2: ttest2 p =' num2str(p3)]});
    
fig_dir = [ROOT_DIR 'Review/Model Floor Effect/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f, [fig_dir 'SWNs Mean Time of Peak Activity'], 'fig');
saveas(f, [fig_dir 'SWNs Mean Time of Peak Activity'], 'epsc2');
saveas(f, [fig_dir 'SWNs Mean Time of Peak Activity'], 'jpg');

%% Next, we compare the zscore of striosomes during the task.
% Load data
dbs = {'control', 'stress', 'stress2'};
load('neuron_type_zscores_real.mat');
load('neuron_type_zscores_review_model_floor_effect.mat');
neuron_type_zscores_model = cell(1,length(dbs));
neuron_type_zscores_model{3} = all_zscores{1};
neuron_type_zscores_model{6} = all_zscores{2};

% Put the real and model data into one matrix.
bar_err = zeros([3,2]);
bar_y = zeros([3,2]);
for db = 1:length(dbs)
    bar_err(db,1) = std(neuron_type_zscores{3}{db})/sqrt(length(neuron_type_zscores{3}{db}));
    bar_y(db,1) = mean(neuron_type_zscores{3}{db});
end
for db = 1:length(dbs)
    % Clean data
    neuron_type_zscores_model{3}{db} = neuron_type_zscores_model{3}{db}(~isnan(neuron_type_zscores_model{3}{db}) & ...
                                                                        ~isinf(neuron_type_zscores_model{3}{db}));
    bar_err(db,2) = std(neuron_type_zscores_model{3}{db})/sqrt(length(neuron_type_zscores_model{3}{db}));
    bar_y(db,2) = mean(neuron_type_zscores_model{3}{db});
end

% Run the statistical tests and plot the results
[~,p1] = ttest2(neuron_type_zscores{3}{1}, neuron_type_zscores_model{3}{1});
[~,p2] = ttest2(neuron_type_zscores{3}{2}, neuron_type_zscores_model{3}{2});
[~,p3] = ttest2(neuron_type_zscores{3}{3}, neuron_type_zscores_model{3}{3});
f=figure; barwitherr(bar_err, bar_y);
legend('Real', 'Model', 'Location', 'northwest');
xlabel('Experimental Group');
ylabel('Zscore');
title({'Striosome Zscore of Firing Rate During Task',...
        ['Control: ttest2 p =' num2str(p1)], ...
        ['Stress: ttest2 p =' num2str(p2)], ...
        ['Stress2: ttest2 p =' num2str(p3)]});
fig_dir = [ROOT_DIR 'Review/Model Floor Effect/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f, [fig_dir 'Striosomes Zscore During Task'], 'fig');
saveas(f, [fig_dir 'Striosomes Zscore During Task'], 'epsc2');
saveas(f, [fig_dir 'Striosomes Zscore During Task'], 'jpg');