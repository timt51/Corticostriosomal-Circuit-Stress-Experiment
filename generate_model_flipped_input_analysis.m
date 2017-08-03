% % Get control input to stress 1 model data
% load('control_only_spike_times_1000_30.mat');
% pls_spikes_stress = pls_spikes{3};
% strio_spikes_stress = strio_spikes{3};
% swn_spikes_stress = swn_spikes{3};
% Ts_stress = Ts{3};
% % Get control input to stress 2 model data
% load('control_only_spike_times_1000_40.mat');
% % Replace control input to stress 2 model data with control input to stress
% % 1 data
% pls_spikes{2} = pls_spikes_stress;
% strio_spikes{2} = strio_spikes_stress;
% swn_spikes{2} = swn_spikes_stress;
% Ts{2} = Ts_stress;
% 
% % Analyze
% generate_model_analysis;

% Get stress 2 input to control model data
load('stress2_only_spike_times_1000_30.mat');
pls_spikes_stress = pls_spikes{1};
strio_spikes_stress = strio_spikes{1};
swn_spikes_stress = swn_spikes{1};
Ts_stress = Ts{1};
% Get stress 1 input to control model data
load('stress_only_spike_times_1000_40.mat');
% Get back the stress 2 input to control model data
pls_spikes{2} = pls_spikes_stress;
strio_spikes{2} = strio_spikes_stress;
swn_spikes{2} = swn_spikes_stress;
Ts{2} = Ts_stress;

% Analyze
generate_model_analysis;