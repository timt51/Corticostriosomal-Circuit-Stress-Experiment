%% This script plots, for each experimental group, a scatter plot of peak
%  to valley length versus firing rate for all DMS neurons.
%% Find MSNs, SWNs, and Unidentified in DMS
MSNs = cell(1,length(dbs));
TANs = cell(1,length(dbs));
SWNs = cell(1,length(dbs));
Unidentified = cell(1,length(dbs));
totals = zeros(1,length(dbs));

for db = 1:length(dbs)
    MSNs{db} = find(strcmp({twdbs{db}.neuron_type}, 'MSN') & strcmp({twdbs{db}.tetrodeType}, 'dms') & ~strcmp({twdbs{db}.peakToValley_length}, 'Not Measured - Does not pass SNR') & [twdbs{db}.final_michael_grade] >= 3);
    SWNs{db} = find(strcmp({twdbs{db}.neuron_type}, 'SWN') & strcmp({twdbs{db}.tetrodeType}, 'dms') & ~strcmp({twdbs{db}.peakToValley_length}, 'Not Measured - Does not pass SNR') & [twdbs{db}.final_michael_grade] >= 3);
    TANs{db} = find(strcmp({twdbs{db}.neuron_type}, 'Unidentified') & strcmp({twdbs{db}.tetrodeType}, 'dms') & ~strcmp({twdbs{db}.peakToValley_length}, 'Not Measured - Does not pass SNR') & [twdbs{db}.final_michael_grade] >= 3 & [twdbs{db}.sqr_neuron_type] == 2);
    Unidentified{db} = find(strcmp({twdbs{db}.neuron_type}, 'Unidentified') & strcmp({twdbs{db}.tetrodeType}, 'dms') & ~strcmp({twdbs{db}.peakToValley_length}, 'Not Measured - Does not pass SNR') & [twdbs{db}.final_michael_grade] >= 3 & [twdbs{db}.sqr_neuron_type] ~= 2);
    totals(db) = length(find(strcmp({twdbs{db}.tetrodeType}, 'dms')));
end
%% Plot peak to valley length
f = figure;
tim_FRs = cell(1,length(dbs));
for db = 1:length(dbs)
    for neuron_idx = 1:length(twdbs{db})
        tim_FR = mean((cell2mat(cellfun(@(x) diff(x),twdbs{db}(neuron_idx).trial_spikes,'uni',false))))/median((cell2mat(cellfun(@(x) diff(x),twdbs{db}(neuron_idx).trial_spikes,'uni',false))));
%         tim_FR = median((cell2mat(cellfun(@(x) diff(x),twdbs{db}(neuron_idx).trial_spikes,'uni',false))));
        tim_FRs{db} = [tim_FRs{db}, tim_FR];
    end
    
    subplot(2,2,db);
    hold on;
    s1 = scatter([twdbs{db}(MSNs{db}).peakToValley_length],(tim_FRs{db}(MSNs{db})), 5, 'blue', 'filled'); title([dbs{db}]);
    xlabel('peak to valley length (ms)'); ylabel('Median log ISI (s)');
    hold off;
    
    subplot(2,2,db);
    hold on;
    s2 = scatter([twdbs{db}(SWNs{db}).peakToValley_length],(tim_FRs{db}(SWNs{db})), 5, 'red', 'filled'); title([dbs{db}]);
    xlabel('peak to valley length (ms)'); ylabel('Median log ISI (s)');
    hold off;
    
    subplot(2,2,db);
    hold on;
    s4 = scatter([twdbs{db}(TANs{db}).peakToValley_length],(tim_FRs{db}(TANs{db})), 5, 'green', 'filled'); title([dbs{db}]);
    xlabel('peak to valley length (ms)'); ylabel('Median log ISI (s)');
    hold off;

    subplot(2,2,db);
    hold on;
    s3 = scatter([twdbs{db}(Unidentified{db}).peakToValley_length],(tim_FRs{db}(Unidentified{db})), 5, [.5 .5 .5], 'filled'); title([dbs{db}]);
    xlabel('peak to valley length (ms)'); ylabel('Median log ISI (s)');
    hold off;
        
	title(['total neurons analyzed ' num2str(totals(db))]);
    xlim([0 .7]); ylim([-5 4]);
end
suptitle('Red - SWN; Blue - MSN; Green - TAN; Grey - Unidentified');

fig_dir = [ROOT_DIR 'Classification/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f, [fig_dir 'Classification Peak To Valley Length vs Median log ISI'],'fig');
saveas(f, [fig_dir 'Classification Peak To Valley Length vs Median log ISI'],'epsc2');
saveas(f, [fig_dir 'Classification Peak To Valley Length vs Median log ISI'],'jpg');
