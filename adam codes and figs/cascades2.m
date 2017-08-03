for i = 1:length(dbs)
    
    unique_fsis = unique(all_triplets{i}(:, 3));
    timings = zeros(length(unique_fsis), 3);
    for j = 1:length(unique_fsis)
        timings(j, 2) = get_max_activation(twdbs{i}, unique_fsis(j));
    end
    
    pls_ts = zeros(length(unique_fsis), 2);
    s = size(pls_fsi_pairs{i});
    for j = 1:s(1)
        index = find(unique_fsis==pls_fsi_pairs{i}(j, 2));
        pls_id = pls_fsi_pairs{i}(j, 1);
        timing = get_max_activation(twdbs{i}, pls_id);
        if timing < timings(index, 2)
            pls_ts(index, 1) = pls_ts(index, 1) + timing;
            pls_ts(index, 2) = pls_ts(index, 2) + 1;
        end
    end
    timings(:, 1) = pls_ts(:, 1) ./ pls_ts(:, 2);
    
    svn_ts = zeros(length(unique_fsis), 2);
    s = size(fsi_svn_pairs{i});
    for j = 1:s(1)
        index = find(unique_fsis==fsi_svn_pairs{i}(j, 1));
        svn_id = fsi_svn_pairs{i}(j, 2);
        timing = get_max_activation(twdbs{i}, svn_id);
        if timing > timings(index, 2)
            svn_ts(index, 1) = svn_ts(index, 1) + timing;
            svn_ts(index, 2) = svn_ts(index, 2) + 1;
        end
    end
    timings(:, 3) = svn_ts(:, 1) ./ svn_ts(:, 2);
    
    timings = sortrows(timings, [2, 1, 3]);
    
    figure;
    hold all;
    title([dbs{i}, ' cascades']);
    index = 1;
    s = size(timings);
    for j = 1:s(1)
        t_pls = timings(j, 1);
        t_fsi = timings(j, 2);
        t_svn = timings(j, 3);
        
        if (t_pls < t_fsi) || (t_fsi < t_svn)
            scatter(t_fsi, index, 18, 'red', 'filled');
            
            if (t_pls < t_fsi)
                line([t_pls, t_fsi], [index, index], 'Color', 'black', 'LineStyle', ':');
                scatter(t_pls, index, 18, 'green', 'filled');
            end
            
            if t_fsi < t_svn
                line([t_svn, t_fsi], [index, index], 'Color', 'black', 'LineStyle', ':');
                scatter(t_svn, index, 18, 'blue', 'filled');
            end
            
            index = index + 1;
        end
    end
    ylim([0, index])
    xlim([-0.5, 2.5])
    saveas(gcf, [dbs{i}, '_cascades'], 'fig')
    saveas(gcf, [dbs{i}, '_cascades'], 'eps')
end