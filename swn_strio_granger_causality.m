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
comparison_type = 'SWNs to Striosomes';
pls_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    pls_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        pls_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_swn_ids{db}]);
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
%% Run GC
% Parameters: Window Size, Bin Size, Amount to slide window by, method of
% combining trials, proportion over threshold or mean, spikes/bursts/method
% of binning bursts

min_time = -20; max_time = 20;
bin_size = 0.1;
window_size = 2.5;
window_shift_size = 1;
type = 'bursts';
connectivities = pairs_gc(twdbs, dbs, comparison_type, all_pairs, min_time, max_time, bin_size, window_size, window_shift_size, type);