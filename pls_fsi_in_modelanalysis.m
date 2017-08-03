%% Load Data
% Setup
addpath(genpath('../'),'-end');
load('spike_times_1000_30.mat');
pls_spikes_stress = pls_spikes{2};
strio_spikes_stress = strio_spikes{2};
swn_spikes_stress = swn_spikes{2};
Ts_stress = Ts{ 2};
load('spike_times_1000_40.mat');
pls_spikes{2} = pls_spikes_stress;
strio_spikes{2} = strio_spikes_stress;
swn_spikes{2} = swn_spikes_stress;
Ts{2} = Ts_stress;

%% Setup
dbs = {'control', 'stress', 'stress2'};
tmin = 17000;
tmax = 26000;
num_reps = 40;
num_pls = 7;
num_strio = 3;
num_swn = 1;

%% Summary...
% db = 1, rep = [1,3,10,24,30,38]
% db = 2, rep = [11,15,16,18,21,23,24,27,28,30,33];
% db = 3, rep = [1,12,14,32,33,35,40]
for db = 2
    for rep = [15,30]
        figure; 
        subplot(5,1,[4,1]);
        for pls_num = 1:num_pls
            hold on;
            pls_spikes_to_plot = smooth(pls_spikes{db}{rep}{pls_num} + 2*pls_num,1);
            plot(pls_spikes_to_plot);
            line([20000-tmin, 20000-tmin], [0 16], 'LineWidth', 2, 'Color', 'black');
            line([21500-tmin, 21500-tmin], [0 16], 'LineWidth', 2, 'Color', 'black');
            line([23000-tmin, 23000-tmin], [0 16], 'LineWidth', 2, 'Color', 'black');
            hold off;
            title(['db: ' dbs{db} ' rep: ' num2str(rep)]);
        end
        xlim([0 tmax-tmin]); ylim([0 16]);

        subplot(5,1,5);
        if ~isempty(swn_spikes{db}{rep}{1}')
%             bin_size = 60;
%             bins = tmin:bin_size:tmax;
%             spikes = histcounts(swn_spikes{db}{rep}{1}',bins); spikes = smooth(spikes,5);
%             centers= (bins(1:end-1)+bins(2:end)) / 2;
%             plot(centers, spikes, 'Color','red','LineWidth',2);
%             
%             sig_std = 2;
%             avg = mean(spikes(1:40));
%             stddev = std(spikes(1:40));
%             threshold = avg + sig_std*stddev;
%             line([tmin tmax], [threshold threshold], 'Color', 'black', 'LineWidth', 2);
            
            line([swn_spikes{db}{rep}{1}' swn_spikes{db}{rep}{1}'], [0, 1],'Color','red');
        end
        xlim([tmin tmax]);
        set(gcf, 'Position', get(0,'Screensize'));
    end
end
