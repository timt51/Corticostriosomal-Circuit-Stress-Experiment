function plot_triplet(db, triplet)

figure;
subplot(3,1,1);
plot_single_neuron(db, triplet(1))
title(['PLs; id=' num2str(triplet(1))])

subplot(3,1,2);
plot_single_neuron(db, triplet(3))
title(['FSI; id=' num2str(triplet(3))])

subplot(3,1,3);
plot_single_neuron(db, triplet(2))
title(['SVN; id=' num2str(triplet(2))])

end

