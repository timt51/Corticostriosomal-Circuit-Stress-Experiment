%% Visualization of Type A
f = figure;
max_delay = .02;

% Plot first PLs burst
pls_burst1_start = .3;
pls_burst1_end = .305;
pls_burst1_num_spikes = 20;
pls_burst1 = linspace(pls_burst1_start, pls_burst1_end,pls_burst1_num_spikes)';

pls_spikes = pls_burst1;
line([pls_spikes, pls_spikes]', repmat([1-.4; 1-.1],[1,length(pls_spikes)]),'Color','black');

patch([pls_burst1_start, pls_burst1_end, pls_burst1_end, pls_burst1_start],...
    [1-.4, 1-.4, 1-.1, 1-.1], 'red', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth',2)

patch([pls_burst1_start, pls_burst1_start+max_delay, pls_burst1_start+max_delay, pls_burst1_start],...
    [1-.4, 1-.4, 1-.9, 1-.9], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',1);

% Plot first correlated striosomal burst
strio_burst1_start = .32-.005;
strio_burst1_end = .322-.005;
strio_burst1_num_spikes = 10;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [1-.9, 1-.9, 1-.6, 1-.6], 'red', 'FaceColor', 'none', 'EdgeColor', 'green', 'LineWidth',2);
line([pls_burst1_start, pls_burst1_start], [1-.4, 1-.6], 'Color','black', 'LineWidth',2);
arrow([pls_burst1_start,1-.6], [strio_burst1_start, 1-.6],'LineWidth',2);

% Plot strio firing rate
X = 0.3:.005:0.335;
Y = ([3, 3, 2.5, 3, 1.5, 1, 1, 1]-3)/5;
hold on;
patch([strio_burst1_start, strio_burst1_start+.5, strio_burst1_start+.5, strio_burst1_start],...
    [0, 0, -.4, -.4], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',1);
stairs(X,Y, 'Color', 'blue', 'LineWidth', 2);
hold off;
xlim([.295 .331])

fig_dir = [ROOT_DIR 'Review/Patterns/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Example of Type A'], 'fig');
saveas(f,[fig_dir 'Example of Type A'], 'epsc2');
saveas(f,[fig_dir 'Example of Type A'], 'jpg');

%% Type C
f = figure;
% Plot first PLs burst
pls_burst1_start = .3;
pls_burst1_end = .305;
pls_burst1_num_spikes = 20;
pls_burst1 = linspace(pls_burst1_start, pls_burst1_end,pls_burst1_num_spikes)';

pls_spikes = pls_burst1;
line([pls_spikes, pls_spikes]', repmat([1-.4; 1-.1],[1,length(pls_spikes)]),'Color','black');

patch([pls_burst1_start, pls_burst1_end, pls_burst1_end, pls_burst1_start],...
    [1-.4, 1-.4, 1-.1, 1-.1], 'red', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth',2)

patch([pls_burst1_start, pls_burst1_start+max_delay, pls_burst1_start+max_delay, pls_burst1_start],...
    [-.5, -.5, 0, 0], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',1);

% Plot first correlated striosomal burst
strio_burst1_start = .32-.005;
strio_burst1_end = .322-.005;
strio_burst1_num_spikes = 10;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

% patch([pls_burst1_end, strio_burst1_start, strio_burst1_start, pls_burst1_end],...
%     [-.4, -.4, -.9, -.9], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',1);

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([0; -.5],[1,length(strio_spikes)]),'Color','black');

patch([pls_burst1_start, strio_burst1_start, strio_burst1_start, pls_burst1_start],...
    [.1, .1, .6, .6], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',2);

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [-.5, -.5, 0, 0], 'red', 'FaceColor', 'none', 'EdgeColor', 'blue', 'LineWidth',2);
line([pls_burst1_start, pls_burst1_start], [.6, 0], 'Color','black', 'LineWidth',2);
arrow([pls_burst1_start,0], [strio_burst1_start, 0],'LineWidth',2);

% SWN burst...
strio_burst1_start = .325;
strio_burst1_end = .325 + .01*2/3;
strio_burst1_num_spikes = 20;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

% patch([pls_burst1_end, strio_burst1_start, strio_burst1_start, pls_burst1_end],...
%     [-.4, -.4, -.9, -.9], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',1);

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([.4; .1],[1,length(strio_spikes)]),'Color','black');

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [.4, .4, .1, .1], 'red', 'FaceColor', 'none', 'EdgeColor', 'green', 'LineWidth',2);

xlim([.295 .333])

fig_dir = [ROOT_DIR 'Review/Patterns/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Example of Type C'], 'fig');
saveas(f,[fig_dir 'Example of Type C'], 'epsc2');
saveas(f,[fig_dir 'Example of Type C'], 'jpg');