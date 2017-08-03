% arrayfun(@(x) length(sig_inhib_pair_nums{x})/size(hfn_strio_pairs{x},1), 1:length(dbs)) - row
% correlated_counts(:,1)./correlated_counts(:,2) - column

pls_swn_ratios = [];
pls_strio_ratios = [];
swn_strio_ratios = [];

for window_index = 0:37
    min_time = -20;
    max_time = min_time + 2.5;
    min_time = min_time + window_index;
    max_time = max_time + window_index;
    
    response_to_pl_phasic_activity_swn_master_script_baseline; close all;
    pls_swn_ratios = [pls_swn_ratios correlated_counts(:,1)./correlated_counts(:,2)];
    
    response_to_pl_phasic_activity_strio_master_script_baseline; close all;
    pls_strio_ratios = [pls_strio_ratios correlated_counts(:,1)./correlated_counts(:,2)];
    
    generate_strio_response_to_swn_baseline; close all;
    swn_strio_ratios = [swn_strio_ratios arrayfun(@(x) length(sig_inhib_pair_nums{x})/size(hfn_strio_pairs{x},1), 1:length(dbs))'];
end

figure;
plot(-20:17,smooth(pls_swn_ratios(1,:),1),-20:17,smooth(pls_swn_ratios(2,:),1),-20:17,smooth(pls_swn_ratios(3,:),1),'LineWidth',2);
legend('Control','Stress','Stress2');
line([-3 -3],[0 1],'Color','black','LineWidth',2);
title('PLs to SWNs');

figure;
plot(-20:17,smooth(pls_strio_ratios(1,:),1),-20:17,smooth(pls_strio_ratios(2,:),1),-20:17,smooth(pls_strio_ratios(3,:),1),'LineWidth',2);
legend('Control','Stress','Stress2');
line([-3 -3],[0 1],'Color','black','LineWidth',2);
title('PLs to Striosomes');

figure;
plot(-20:17,smooth(swn_strio_ratios(1,:),1),-20:17,smooth(swn_strio_ratios(2,:),1),-20:17,smooth(swn_strio_ratios(3,:),1),'LineWidth',2);
legend('Control','Stress','Stress2');
line([-3 -3],[0 1],'Color','black','LineWidth',2);
title('SWNs to Striosomes');