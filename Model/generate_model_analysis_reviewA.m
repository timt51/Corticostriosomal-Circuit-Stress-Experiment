%% This script analyzes the model data the same way it analyzes the real data.

% Initialize variables and parameters
to_plot = true;
percentiles = [80,80,80,80,80,80];
all_times_of_max = cell(1,length(neuron_types));
window_starts = cell(1,length(neuron_types));
window_ends = cell(1,length(neuron_types));
all_window_starts = cell(1,length(neuron_types));
all_window_ends = cell(1,length(neuron_types));
entropies = cell(1,length(neuron_types));

tmin = 17000;
tmax = 26000;
num_reps = 40;
num_strio = 3;
num_swn = 1;

ts = -3+.06:.06:6;
sig_std = 3;
%% Analyze striosomes with line plots
bin_size = 60; %ms
bin_edges = tmin:bin_size:tmax;
all_strio_spikes = cell(1,length(dbs));
times_of_max = cell(1,length(dbs));
event_times = cell(1,length(dbs));
fs = [];
for db = 1:length(dbs)
    f1 = figure;
    fs = [fs; f1];
    
    all_strio_spikes{db} = zeros(1,length(bin_edges)-1);

    for rep = 1:num_reps
        for strio_num = 1:num_strio
            spikes = histcounts(strio_spikes{db}{rep}{strio_num}, bin_edges);
            all_strio_spikes{db} = all_strio_spikes{db}+spikes;
            to_plot = true;
            if db == 1
                % Do cascade analysis with inhibition data, but do line
                % plot analysis with excitation data.
                [times_of_max_ratio_scale_tmp, event_times_tmp] = ...
                        make_peak_activity_line_plot_helper_inhib(rep*num_strio + strio_num, ts, spikes, sig_std, false);
                 make_peak_activity_line_plot_helper(rep*num_strio + strio_num, ts, spikes, sig_std, to_plot);
            else
                [times_of_max_ratio_scale_tmp, event_times_tmp] = ...
                        make_peak_activity_line_plot_helper(rep*num_strio + strio_num, ts, spikes, sig_std, to_plot);
            end
            times_of_max{db} = [times_of_max{db} times_of_max_ratio_scale_tmp]; 
            event_times{db} = [event_times{db}; event_times_tmp]; 
        end
    end
    num_samples = num_reps*strio_num;
    line([ts(50) ts(50)], [2 num_samples+5], 'Color', [0 0 0], 'LineWidth', 1);
    line([ts(75) ts(75)], [2 num_samples+5], 'Color', [0 0 0], 'LineWidth', 1);
    line([ts(100) ts(100)], [2 num_samples+5], 'Color', [0 0 0], 'LineWidth', 1);
    title(['db: ' dbs{db} ' striosomes']);
    xlim([-3 6]);
end

neuron_type_idx = 3;

lick_times=arrayfun(@(x) event_times{x}(~isnan(times_of_max{x}),3),1:length(event_times),'uni',false);
times_of_max=arrayfun(@(x) times_of_max{x}(~isnan(times_of_max{x}))',1:length(times_of_max),'uni',false);
all_times_of_max{neuron_type_idx} = times_of_max;
times_of_max=arrayfun(@(x) times_of_max{x}(times_of_max{x}>=-3&times_of_max{x}<=lick_times{x})',1:length(dbs),'uni',false);

% Find region of max intensity of black dots
intensities = cell(length(dbs),1);
for db = 1:length(dbs)
    times_of_max{db} = sort(times_of_max{db});
    for idx1 = 1:length(times_of_max{db})
        for idx2 = (idx1+1):length(times_of_max{db})
            prop_black_dots = (idx2-idx1+1)/length(event_times{db});
            time = times_of_max{db}(idx2) - times_of_max{db}(idx1);
            if ~isinf(prop_black_dots/time)
                intensities{db} = [intensities{db}; times_of_max{db}(idx1), times_of_max{db}(idx2), prop_black_dots/time];
            end
        end
    end
end
intensities_mat = cell2mat(intensities); intensities_mat = log(intensities_mat(:,3));
intensities = cellfun(@(x) [x(:,1:2) log(x(:,3))], intensities,'uni',false);

high_intensity_windows = cellfun(@(x) x(x(:,3)>=prctile(x(:,3),percentiles(neuron_type_idx)),1:2),intensities,'uni',false);

window_starts{neuron_type_idx} = cell(1,length(dbs));
window_ends{neuron_type_idx} = cell(1,length(dbs));
all_window_starts{neuron_type_idx} = cell(1,length(dbs));
all_window_ends{neuron_type_idx} = cell(1,length(dbs));
for db = 1:length(dbs)    
    for window_idx = 1:size(high_intensity_windows{db},1)
        window_start = high_intensity_windows{db}(window_idx,1);
        window_end = high_intensity_windows{db}(window_idx,2);
        if sum(times_of_max{db}>=window_start & times_of_max{db}<=window_end) > .125*length(event_times{db})
            
            window_starts{neuron_type_idx}{db} = [window_starts{neuron_type_idx}{db}, window_start];
            window_ends{neuron_type_idx}{db} = [window_ends{neuron_type_idx}{db}, window_end];
        end
    end
    all_window_starts{neuron_type_idx}{db} = window_starts{neuron_type_idx}{db};
    all_window_ends{neuron_type_idx}{db} = window_ends{neuron_type_idx}{db};
    window_starts{neuron_type_idx}{db} = mean(window_starts{neuron_type_idx}{db});
    window_ends{neuron_type_idx}{db} = mean(window_ends{neuron_type_idx}{db});
    disp([window_starts{neuron_type_idx}{db} window_ends{neuron_type_idx}{db}])
    if ~isnan(window_starts{neuron_type_idx}{db})
        figure(fs(db));
        entropy = sum(times_of_max{db}>=window_starts{neuron_type_idx}{db}&times_of_max{db}<=window_ends{neuron_type_idx}{db})/length(event_times{db})/(window_ends{neuron_type_idx}{db}-window_starts{neuron_type_idx}{db});
        arrow([window_starts{neuron_type_idx}{db} num_samples+8], [window_ends{neuron_type_idx}{db}, num_samples+8]);
        entropies{neuron_type_idx}(db) = entropy;
    end
end
disp([window_starts{neuron_type_idx}]);
fig_dir = [ROOT_DIR 'Review/Model No Floor Effect/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(fs(1), [fig_dir 'Control Striosomes Line Plot'], 'fig');
saveas(fs(1), [fig_dir 'Control Striosomes Line Plot'], 'epsc2');
saveas(fs(1), [fig_dir 'Control Str Moreiosomes Line Plot'], 'jpg');
saveas(fs(2), [fig_dir 'Stress Striosomes Line Plot'], 'fig');
saveas(fs(2), [fig_dir 'Stress Striosomes Line Plot'], 'epsc2');
saveas(fs(2), [fig_dir 'Stress Striosomes Line Plot'], 'jpg');
saveas(fs(3), [fig_dir 'Stress2 Striosomes Line Plot'], 'fig');
saveas(fs(3), [fig_dir 'Stress2 Striosomes Line Plot'], 'epsc2');
saveas(fs(3), [fig_dir 'Stress2 Striosomes Line Plot'], 'jpg');

% Get zscores of striosomes during the task
fig = figure;
zscores = cell(1,length(dbs));
for db = 1:length(dbs)
    for rep = 1:num_reps
        for strio_num = 1:num_strio            
            spikes = histcounts(smooth(strio_spikes{db}{rep}{strio_num}), bin_edges);
            spikes = smooth(spikes,25);
            mean_BL_FR = mean(spikes(1:40) / bin_size * 1000);
            std_BL_FR = std(spikes(1:40) / bin_size * 1000);
            mean_task_FR = mean(spikes(67:79) / bin_size * 1000);
            
            zscores{db} = [zscores{db} (mean_task_FR - mean_BL_FR) / std_BL_FR];
        end
    end
end
strio_zscores = zscores;

%% Analyze SWNs with line plots
sig_std = 2;
bin_size = 60; %ms
bin_edges = tmin:bin_size:tmax;
all_swn_spikes = cell(1,length(dbs));
times_of_max = cell(1,length(dbs));
event_times = cell(1,length(dbs));
fs = [];
for db = 1:length(dbs)
    f1 = figure;
    fs = [fs; f1];
    all_swn_spikes{db} = zeros(1,length(bin_edges)-1);

    for rep = 1:num_reps
        for swn_num = 1:num_swn                        
            spikes = histcounts(swn_spikes{db}{rep}{swn_num}, bin_edges);
            all_swn_spikes{db} = all_swn_spikes{db}+spikes;
            to_plot = true;
            [times_of_max_tmp, event_times_tmp] = ...
                make_peak_activity_line_plot_helper(rep*num_swn + swn_num, ts, spikes, sig_std, to_plot);
            times_of_max{db} = [times_of_max{db} times_of_max_tmp];
            event_times{db} = [event_times{db}; event_times_tmp];
        end
    end
        num_samples = num_reps*num_swn;
    line([ts(50) ts(50)], [1 num_samples+3], 'Color', [0 0 0], 'LineWidth', 1);
    line([ts(75) ts(75)], [1 num_samples+3], 'Color', [0 0 0], 'LineWidth', 1);
    line([ts(100) ts(100)], [1 num_samples+3], 'Color', [0 0 0], 'LineWidth', 1);
    title(['db: ' dbs{db} ' swns']);
    xlim([-3 6]);
end


percentiles = [60,60,80,80,50,50];
neuron_type_idx = 6;

turn_times=arrayfun(@(x) event_times{x}(~isnan(times_of_max{x}),2),1:length(event_times),'uni',false);
lick_times=arrayfun(@(x) event_times{x}(~isnan(times_of_max{x}),3),1:length(event_times),'uni',false);
times_of_max=arrayfun(@(x) times_of_max{x}(~isnan(times_of_max{x}))',1:length(times_of_max),'uni',false);
times_of_max=arrayfun(@(x) times_of_max{x}(times_of_max{x}>=-3&times_of_max{x}<=6)',1:length(dbs),'uni',false);
all_times_of_max{neuron_type_idx} = times_of_max;

% Find region of max intensity of black dots
intensities = cell(length(dbs),1);
for db = 1:length(dbs)
    times_of_max{db} = sort(times_of_max{db});
    for idx1 = 1:length(times_of_max{db})
        for idx2 = (idx1+1):length(times_of_max{db})
            prop_black_dots = (idx2-idx1+1)/length(event_times{db});
            time = times_of_max{db}(idx2) - times_of_max{db}(idx1);
            if ~isinf(prop_black_dots/time)
                intensities{db} = [intensities{db}; times_of_max{db}(idx1), times_of_max{db}(idx2), prop_black_dots/time];
            end
        end
    end
end
intensities_mat = cell2mat(intensities); intensities_mat = log(intensities_mat(:,3));
for db = 1:length(dbs)
    if isempty(intensities{db})
            intensities{db} = [0 0 0];
    end
end
intensities = cellfun(@(x) [x(:,1:2) log(x(:,3))], intensities,'uni',false);

high_intensity_windows = cellfun(@(x) x(x(:,3)>=prctile(x(:,3),percentiles(neuron_type_idx)),1:2),intensities,'uni',false);

window_starts{neuron_type_idx} = cell(1,length(dbs));
window_ends{neuron_type_idx} = cell(1,length(dbs));
all_window_starts{neuron_type_idx} = cell(1,length(dbs));
all_window_ends{neuron_type_idx} = cell(1,length(dbs));
for db = 1:length(dbs)    
    for window_idx = 1:size(high_intensity_windows{db},1)
        window_start = high_intensity_windows{db}(window_idx,1);
        window_end = high_intensity_windows{db}(window_idx,2);
        if sum(times_of_max{db}>=window_start & times_of_max{db}<=window_end) > .15*length(event_times{db})
            
            window_starts{neuron_type_idx}{db} = [window_starts{neuron_type_idx}{db}, window_start];
            window_ends{neuron_type_idx}{db} = [window_ends{neuron_type_idx}{db}, window_end];
        end
    end
    all_window_starts{neuron_type_idx}{db} = window_starts{neuron_type_idx}{db};
    all_window_ends{neuron_type_idx}{db} = window_ends{neuron_type_idx}{db};
    window_starts{neuron_type_idx}{db} = mean(window_starts{neuron_type_idx}{db});
    window_ends{neuron_type_idx}{db} = mean(window_ends{neuron_type_idx}{db});
    disp([window_starts{neuron_type_idx}{db} window_ends{neuron_type_idx}{db}])
    if ~isnan(window_starts{neuron_type_idx}{db})
        figure(fs(db));
        entropy = sum(times_of_max{db}>=window_starts{neuron_type_idx}{db}&times_of_max{db}<=window_ends{neuron_type_idx}{db})/length(event_times{db})/(window_ends{neuron_type_idx}{db}-window_starts{neuron_type_idx}{db});
        arrow([window_starts{neuron_type_idx}{db} num_samples+8], [window_ends{neuron_type_idx}{db}, num_samples+8]);
        entropies{neuron_type_idx}(db) = entropy;
    end
end
disp([window_starts{neuron_type_idx}]);
fig_dir = [ROOT_DIR 'Review/Model No Floor Effect/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(fs(1), [fig_dir 'Control SWNs Line Plot'], 'fig');
saveas(fs(1), [fig_dir 'Control SWNs Line Plot'], 'epsc2');
saveas(fs(1), [fig_dir 'Control SWNs Line Plot'], 'jpg');
saveas(fs(2), [fig_dir 'Stress SWNs Line Plot'], 'fig');
saveas(fs(2), [fig_dir 'Stress SWNs Line Plot'], 'epsc2');
saveas(fs(2), [fig_dir 'Stress SWNs Line Plot'], 'jpg');
saveas(fs(3), [fig_dir 'Stress2 SWNs Line Plot'], 'fig');
saveas(fs(3), [fig_dir 'Stress2 SWNs Line Plot'], 'epsc2');
saveas(fs(3), [fig_dir 'Stress2 SWNs Line Plot'], 'jpg');

swn_zscores = [];
all_zscores = {strio_zscores, swn_zscores};
save('neuron_type_zscores_review_model_no_floor_effect.mat', 'all_zscores');

all_times_of_max_model = all_times_of_max;
save('all_times_of_max_review_model_no_floor_effect.mat', 'all_times_of_max_model');