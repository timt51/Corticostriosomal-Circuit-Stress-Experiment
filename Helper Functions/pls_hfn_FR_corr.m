function [p_value, slope, cor] = pls_hfn_FR_corr(pls_BL_FRs,swn_BL_FRs,pls_counts,swn_counts,min_per_session,min_swn_FR,take_log,neuron_type,pls_activity_type, swn_activity_type, to_plot)

    cs = [[1,0,0];[0,1,0];[0,0,1]];
    colors = [];
    for db = 1:length(pls_BL_FRs)
        pls_BL_FRs{db} = pls_BL_FRs{db}(pls_counts{db} >= min_per_session & swn_counts{db} >= min_per_session & swn_BL_FRs{db} > min_swn_FR);
        swn_BL_FRs{db} = swn_BL_FRs{db}(pls_counts{db} >= min_per_session & swn_counts{db} >= min_per_session & swn_BL_FRs{db} > min_swn_FR);
        
        colors = [colors; repmat(cs(db,:), [length(pls_BL_FRs{db}),1])];
    end
    
    % Flatten cell array of firing rates
    pls_BL_FRs = cell2mat(pls_BL_FRs);
    if take_log
        swn_BL_FRs = log10(cell2mat(swn_BL_FRs));
    else
        swn_BL_FRs = cell2mat(swn_BL_FRs);
    end

    % Plot firing rates; bin and take mean
    % Calulate means
    means = [];
    pls_FR_bins = 0:1:max(pls_BL_FRs);
    [~,~,pls_bin] = histcounts(pls_BL_FRs, pls_FR_bins);
    for bin_num = 1:length(pls_FR_bins)-1
        means = [means mean(swn_BL_FRs(pls_bin==bin_num))];
    end
    
    % Plot
    if to_plot
        hold on;
        scatter(pls_BL_FRs, swn_BL_FRs, 8, colors, 'filled');
%         p1=plot(.5:1:4.5,means);
        [r,m,b]=regression(pls_BL_FRs, swn_BL_FRs);
        [cor,p_value]=corr(pls_BL_FRs', swn_BL_FRs');
        X = 0:.01:max(pls_BL_FRs);
        Y = m*X+b;
        p2=plot(X,Y,'black');
        hold off;
        % Figure axes, title, legend
        xlabel(['PLs ' pls_activity_type ' (Hz)']);
        ylabel(['log ' neuron_type ' ' swn_activity_type ' (Hz)']);
        title({['PLs vs ' neuron_type ' Correlation'], ...
                ['Pearson Correlation Coefficient = ' num2str(cor) ', p = ' num2str(p_value)]});
%         legend([p1,p2], 'Means Calculated by Binning PL Baseline FR', 'Regression Line','Location','SouthEast');
    end
    [r,slope,b]=regression(pls_BL_FRs, swn_BL_FRs);
    [cor,p_value]=corr(pls_BL_FRs', swn_BL_FRs');
    
%     figure;
%     errors = swn_BL_FRs - (m*pls_BL_FRs + b);
%     scatter(pls_BL_FRs,errors)
end