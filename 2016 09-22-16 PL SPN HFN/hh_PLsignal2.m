% Leif Gibb 7/5/15 through 9/19/16

function spike = hh_PLsignal2(timeline, spikedur, stimtime)

tspike = -spikedur-1;
spike = zeros(size(timeline));
for t = timeline
    i = t+1;
    if t >= stimtime && t <= stimtime + spikedur
        spike(i) = 1;
    else
        spike(i) = 0;
    end
end

% index = find(spike==1);
% spike(index+2) = 1;
% spike(index+4) = 1;
% 
% spike(index+6) = 1;
% spike(index+8) = 1;
% spike(index+10) = 1;

end