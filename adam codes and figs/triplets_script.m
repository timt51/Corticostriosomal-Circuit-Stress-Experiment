%% control / type (a) response
plot_triplet(twdb_control, [7223, 7190, 7187]);
saveas(gcf, 'triplet_type_a_control', 'fig')
saveas(gcf, 'triplet_type_a_control', 'eps')

%% stress / type (c) response
plot_triplet(twdb_stress, [6625, 6611, 6591]);
saveas(gcf, 'triplet_type_c_stress', 'fig')
saveas(gcf, 'triplet_type_c_stress', 'eps')

