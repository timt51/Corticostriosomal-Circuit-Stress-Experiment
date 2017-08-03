%% Load all of the code and data into memory
if ~exist('loaded','var')
    addpath(genpath('../'),'-end');
    load('twdbs.mat');
    loaded = true;
end
dbs = {'control', 'stress', 'stress2'}; strs = {'Control', 'Stress', 'Stress2'}; 
twdbs = {twdb_control, twdb_stress, twdb_stress2};
neuron_types = {'PL Neurons', 'PLS Neurons', 'Striosomes', 'Matrix Neurons', 'HFNs', 'SWNs'};
clearvars -except min_num twdb_control twdb_stress twdb_stress2 dbs loaded dbs twdbs neuron_types strs
%% Root location of figures
ROOT_DIR = '../Final Stress Figures/';
%% Find indices in database (twdbs) corresponding to PL Neurons, PLs Neurons, 
%  Striosomes, Matrix Neurons, Short Width Neurons, and HFNs. 
%  We find indices corresponding to neurons recorded during any task ('all_ids')
%     and we find indices corresponding to neurons recorded only during the
%     cost benefit task ('cb_ids')
%  Indicies are stored in groups in the order dictacted by 'neuron_types'.
%     i.e. cb_ids{1} corresponds to indicies of PL Neurons in the CB task.
%  Additionally, neuron indices are segmented across experimental groups.
%  The order is the same as in 'dbs'.
%     i.e. cb_ids{6}{2} corresponds to indicies of HFNs in CB and in the
%     Stress (immobilization) group.

% The following variables indicate the minimum Final Michael Grade of each
% neuron type that we will analyze.
min_pls_fmg = -Inf;
min_plNotS_fmg = min_pls_fmg;
min_strio_fmg = -Inf;
min_matrix_fmg = min_strio_fmg;
min_hfn_fmg = 1;

% Find indices corresponding to each neuron type
[all_pls_ids, all_plNotS_ids, all_strio_ids, all_matrix_ids, ...
           all_swn_ids, all_swn_not_hfn_ids, all_hfn_ids] ...
           = find_neuron_ids(twdbs, 'ALL', [min_pls_fmg,min_plNotS_fmg,min_strio_fmg,min_matrix_fmg,min_hfn_fmg]);
[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
           cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
           = find_neuron_ids(twdbs, 'CB', [min_pls_fmg,min_plNotS_fmg,min_strio_fmg,min_matrix_fmg,min_hfn_fmg]);  
all_pl_ids = arrayfun(@(x) [all_pls_ids{x} all_plNotS_ids{x}],1:length(dbs),'uni',false);
cb_pl_ids = arrayfun(@(x) [cb_pls_ids{x} cb_plNotS_ids{x}],1:length(dbs),'uni',false);

% Combine the lists of indices into one cell array with indices for all
% neuron types.
all_ids = {all_pl_ids, all_pls_ids, all_strio_ids, all_matrix_ids, all_hfn_ids, all_swn_ids};
cb_ids = {cb_pl_ids, cb_pls_ids, cb_strio_ids, cb_matrix_ids, cb_hfn_ids, cb_swn_ids};
%% Do analysis here
% The above operations take a while, so it is recommended that you only run
% the code above once. So, when debugging, only run the code below (as long as
% 'cb_ids', 'all_ids', and 'twdbs' are not mutated in the code below).

for neuron_type_index = 1:length(neuron_types)                             % PL, PLS, Striosomes, ...
    for db = 1:length(dbs)                                                 % Control, Stress, Stress2
        neuron_type_ids = cb_ids{neuron_type_index}{db};
        for neuron_index = 1:length(neuron_type_ids)
            % This gives you the spikes of a neuron during each trial
            % To get spikes on a neuron level (averaging spikes across trials)
            % either use one of your ah binning functions or bin them
            % directly here. There is no standard here in terms of bin size
            % or smoothing these parameters can vary between analyses.
            neuron_spikes = twdbs{db}(neuron_index).trial_spikes;
        end
    end
end

%% If you want to get pairs of neurons, such as PLs and SWNs/FSIs in the same session,
% the code below stores the indicies of the pairs in the variable 'all_pairs'
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
comparison_type = 'PLS to SWNs';
pls_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    pls_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    
    % Here we decide which pairs we want i.e. PLS and SWN
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        pls_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_pls_ids{db}]);
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_swn_ids{db}]);
    end
end
%% Get pairs
all_pairs = cell(1,length(dbs));
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        all_pairs{db} = [all_pairs{db}; allcomb(pls_neurons{db}{sessionDir_idx},strio_neurons{db}{sessionDir_idx})];
    end
end
