% Leif Gibb 7/5/15 through 9/10/16

function [phasic,spike] = hh_PLsignal1(timeline, samppersec, spikedur, phasicstart, phasicend, phasicspikefreq, tonicspikefreq)

phasic = zeros(size(timeline));
phasic(1000*(phasicstart:phasicend)/samppersec + 1) = 1;

tspike = -spikedur-1;
spike = zeros(size(timeline));
phasicflag = false;
tonicflag = false;
for t = timeline
    i = t+1;
    if phasic(i)
        if ~phasicflag
            spikefreq = phasicspikefreq;
            spikeprob = spikefreq / samppersec;
            phasicflag = true;
            tonicflag = false;
        end
        if rand < spikeprob
            tspike = t;
        end
        if t - tspike <= spikedur
            spike(i) = 1;
        else
            spike(i) = 0;
        end
    else
        if ~tonicflag
            spikefreq = tonicspikefreq;
            spikeprob = spikefreq / samppersec;
            tonicflag = true;
            phasicflag = false;
        end
        if rand < spikeprob
            tspike = t;
        end
        if t - tspike <= spikedur
            spike(i) = 1;
        else
            spike(i) = 0;
        end
    end
end

end