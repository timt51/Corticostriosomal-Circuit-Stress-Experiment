%% This script generates figures showing the response of striosomes and
%  SWNs to PLs stimulation in our model/simulation.

% PLs input type 2 specifies stimulation of duration (tmax-tmin)/5
pls_input_type = 2;
% The duration of the simulation to run
tmin = 0; %ms
tmax = 20; %ms

% Parameters of the model
num_pls = 7;
num_strio = 3;
num_swn = 1;
pls_strio_gsyn = .25;
pls_strio_gsyns = makedist('Normal','mu',pls_strio_gsyn,'sigma',pls_strio_gsyn/10);
pls_swn_gsyn = 1;
swn_strio_gsyn = 1.35;
pls_spikes = cell(1,length(dbs));
strio_spikes = cell(1, length(dbs));
swn_spikes = cell(1, length(dbs));
Ts = cell(1, length(dbs));

% Gsyn factors describes how much the stress model differs from the control
% model. Specifically, a factor of 30 means that the connection (gsyn)
% between PLs and SWN is reduced by a factor of 30 for the stress model.
gsyn_factors = [1, 30, 40];
Ts_interp = (0:.005:20)';
num_reps = 10;
for rep = 1:num_reps
    for db = 1:length(dbs)
        db_type = db;
        twdb = twdbs{db};
        [Ts_tmp, pls_spikes_tmp, strio_spikes_tmp, swn_spikes_tmp] = hh_model(pls_input_type, num_pls, num_strio, num_swn, ...
                                                                                pls_strio_gsyns, pls_swn_gsyn/gsyn_factors(db), swn_strio_gsyn, ...
                                                                                tmin, tmax, db_type, twdb, cb_pls_ids);
        Ts{db} = Ts_interp;
        pls_spikes{db} = [pls_spikes{db} pls_spikes_tmp];
        strio_spikes{db} = [strio_spikes{db} cellfun(@(x) interp1(Ts_tmp,x,Ts_interp),strio_spikes_tmp,'uni',false)];
        swn_spikes{db} = [swn_spikes{db} cellfun(@(x) interp1(Ts_tmp,x,Ts_interp),swn_spikes_tmp,'uni',false)];
    end
end

%% Make a histogram for each experimental group showing the delay between
%  PLs stimulation and striosomal response. The delay is defined to be the
%  first time the response to stimulation surpasses 80mV.
threshold = 80; %mv
for rep = 1:num_reps*num_strio
    for db = 1:length(dbs)
        strio_spike_regions = regionprops(strio_spikes{db}{rep}>threshold,'PixelIdxList');
        strio_spike_times = cellfun(@(x) Ts{db}(x(1)),{strio_spike_regions.PixelIdxList});
        strio_spikes{db}{rep} = strio_spike_times;
    end
end

f = figure;
subplot(2,2,1); histogram(cell2mat(strio_spikes{1}),0:.5:10);
xlabel('Time from Stimulation (ms)'); ylabel('Count');
title('Control');
subplot(2,2,3); histogram(cell2mat(strio_spikes{2}),0:.5:10);
xlabel('Time from Stimulation (ms)'); ylabel('Count');
title('Stress');
subplot(2,2,4); histogram(cell2mat(strio_spikes{3}),0:.5:10);
xlabel('Time from Stimulation (ms)'); ylabel('Count');
title('Stress 2');

fig_dir = [ROOT_DIR 'Model/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f, [fig_dir 'Electrical Stimulation'], 'fig');
saveas(f, [fig_dir 'Electrical Stimulation'], 'epsc2');
saveas(f, [fig_dir 'Electrical Stimulation'], 'jpg');