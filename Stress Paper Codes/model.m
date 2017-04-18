%% This script generates and saves the spike times of striosomes and SWNs
%  in our model of the corticostriosomal circuit.
%% First, we restrict the set of PLs neurons that we use as input to the
%  model (we only keep PLs neurons active during the task)
cb_pls_ids_original = cb_pls_ids; % Save the original set of neurons so that we can restore it at the end of the function
corrected_control_cb_pls_ids = [8194,8192,8182,9521,9501,9495,7171,9466,11700,11061,8143,10688,9645,7229,7223,7181,7160,7092,7084,6721,6665,6664,6030,6183,6164];
cb_pls_ids{1} = corrected_control_cb_pls_ids;
%% Run model with real data
% Initialize parameters
pls_input_type = 3;
num_pls = 7;
num_strio = 3;
num_swn = 1;
disp(pls_strio_gsyn)
pls_strio_gsyns = makedist('Normal','mu',pls_strio_gsyn,'sigma',pls_strio_gsyn/10);
% Initiailize variables
pls_spikes = cell(1,length(dbs));
strio_spikes = cell(1, length(dbs));
swn_spikes = cell(1, length(dbs));
Ts = cell(1, length(dbs));
gsyn_factors = [1, stress_gsyn_factor, stress_gsyn_factor];
tmin = 17000; %ms
tmax = 26000; %ms
Ts_interp = (tmin:.005:tmax)';
% Run the model and store the results
for db = 1:length(dbs)
    twdb = twdbs{db};
    db_str = dbs{db};
    Ts_for_db = cell(1,num_reps);
    pls_spikes_for_db = cell(1,num_reps);
    strio_spikes_for_db = cell(1,num_reps);
    swn_spikes_for_db = cell(1,num_reps);
    for rep = 1:num_reps
        disp(['db: ' db_str ' rep: ' num2str(rep)]);
        
        db_type = db;
        [Ts_tmp, pls_spikes_tmp, strio_spikes_tmp, swn_spikes_tmp] = hh_model(pls_input_type, num_pls, num_strio, num_swn, pls_strio_gsyns, pls_swn_gsyn/gsyn_factors(db),...
            swn_strio_gsyn, tmin, tmax, db_type, twdb, cb_pls_ids);
        Ts_for_db{rep} = Ts_interp;
        pls_spikes_for_db{rep} = pls_spikes_tmp;
        strio_spikes_for_db{rep} = cellfun(@(x) interp1(Ts_tmp,x,Ts_interp),strio_spikes_tmp,'uni',false);
        swn_spikes_for_db{rep} = cellfun(@(x) interp1(Ts_tmp,x,Ts_interp),swn_spikes_tmp,'uni',false);
    end
    Ts{db} = Ts_for_db{1};
    pls_spikes{db} = pls_spikes_for_db;
    strio_spikes{db} = strio_spikes_for_db;
    swn_spikes{db} = swn_spikes_for_db;
end
%% Convert the output of the model (potential in mV) into spike timings, and save
% For striosomes
threshold = 80; %mv
for db = 1:length(dbs)
    for rep = 1:num_reps
        for strio_num = 1:num_strio
            strio_spike_regions = regionprops(strio_spikes{db}{rep}{strio_num}>threshold,'PixelIdxList');
            strio_spike_times = cellfun(@(x) Ts{db}(x(1)),{strio_spike_regions.PixelIdxList});
            strio_spikes{db}{rep}{strio_num} = strio_spike_times;
        end
    end
end
% For SWNs
threshold = 80; %mv
for db = 1:length(dbs)
    for rep = 1:num_reps
        for swn_num = 1:num_swn
            swn_spike_regions = regionprops(swn_spikes{db}{rep}{swn_num}>threshold,'PixelIdxList');
            swn_spike_times = cellfun(@(x) Ts{db}(x(1)),{swn_spike_regions.PixelIdxList});
            swn_spikes{db}{rep}{swn_num} = swn_spike_times;
        end
    end
end

save(['spike_times_' num2str(pls_swn_gsyn*1000) '_' num2str(stress_gsyn_factor) '.mat'], 'Ts', 'pls_spikes', 'strio_spikes', 'swn_spikes');
%% Restore indicies of PLs neurons
cb_pls_ids = cb_pls_ids_original;