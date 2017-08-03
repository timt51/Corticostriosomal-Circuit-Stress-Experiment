%%
% close all
clear Nneur Nsyn
tic
rng('shuffle')

tmin = 0; % ms
tmax = 10; % 3000; % 10; % ms
timeline = tmin:tmax;
samppersec = 1000;

% Parameters of PL signals
clear PL
PL.signaltype = 2; % Case 1: PL neurons are sequentially active. Case 2: PL neurons are all stimulated at one timepoint.
Nneur.PL = 14;
PL.spikedur = 1; % ms
PL.stimtime = round(0.2*tmax); % ms
PL.phasicspikefreq = 10; % Hz
PL.tonicspikefreq = 0; % Hz
PL = repmat(PL,1,Nneur.PL);
for i = 1:Nneur.PL
    PL(i).phasicstart = ceil(((i-1)/Nneur.PL)*tmax); % ms
    PL(i).phasicend = floor(((i)/Nneur.PL)*tmax);
end

% Parameters of SPN neurons
clear SPN
Nneur.SPN = 6;
SPN.Isyn = 0; % uA/cm^2
SPN.IDC = 0; % uA/cm^2
SPN.ENa = 115; % mV
SPN.EK = -12; % mV
SPN.EL = 10.6; % mV
SPN.gNa = 120; % mS/cm^2
SPN.gK = 36; % mS/cm^2
SPN.gL = 0.3; % mS/cm^2
SPN.C = 1; % uF/cm^2
SPN.Vshift = -70; % mV

% Parameters of HFN neuron
clear HFN
Nneur.HFN = 2;
HFN.Isyn = 0; % uA/cm^2
HFN.IDC = SPN.IDC; % uA/cm^2
HFN.ENa = SPN.ENa; % mV
HFN.EK = SPN.EK; % mV
HFN.EL = SPN.EL; % mV
HFN.gNa = SPN.gNa; % mS/cm^2
HFN.gK = SPN.gK; % mS/cm^2
HFN.gL = SPN.gL; % mS/cm^2
HFN.C = SPN.C; % uF/cm^2
HFN.Vshift = SPN.Vshift; % mV

% Parameters of PL to SPN synapses
Nsyn.syn12 = Nneur.PL;
clear syn12
syn12.gsyn = 0.2; % 0.3; %0.2; % mS/cm^2
syn12.Tmax = 1.5; % mM
syn12.Erev = 0; % mV
syn12.alpha = 1.1; % 0.1; % 1.1; % mM^-1 ms^-1
syn12.beta = 0.19; % 0.01; % 0.19; % ms^-1

% Parameters of PL to HFN synapses
Nsyn.syn13 = Nneur.PL;
clear syn13
syn13.Tmax = syn12.Tmax; % mM
syn13.Vp = 2; % mV
syn13.Kp = 5; % mV
syn13.Erev = syn12.Erev; % mV
syn13.alpha = syn12.alpha; % mM^-1 ms^-1
syn13.beta = syn12.beta; % ms^-1
syn13.T = NaN;
syn13.rdot = NaN;
syn13 = repmat(syn13,1,Nsyn.syn13);
for i = 1:Nsyn.syn13
    syn13(i).gsyn = .1; % mS/cm^2
end

% Parameters of HFN to SPN synapses
Nsyn.syn32 = Nneur.HFN;
clear syn32
syn32.Tmax = syn13.Tmax; % mM
syn32.Vp = syn13.Vp; % mV
syn32.Kp = syn13.Kp; % mV
syn32.Erev = -80; % mV
syn32.alpha = 5.0; % 0.1; % 5.0; % mM^-1 ms^-1
syn32.beta = 0.18; % 0.01; % 0.18; % ms^-1
syn32.T = NaN;
syn32.rdot = NaN;
syn32 = repmat(syn32,1,Nsyn.syn32);
for i = 1:Nsyn.syn32
%     syn32.gsyn = 1.05; % 1.05; 0.1; % mS/cm^2
    syn32(i).gsyn = 1.05; % mS/cm^2
end

% Additional SPN neuron fields
SPN.SumI = NaN;
SPN.alphan = NaN;
SPN.alpham = NaN;
SPN.alphah = NaN;
SPN.betan = NaN;
SPN.betam = NaN;
SPN.betah = NaN;
SPN.mdot = NaN;
SPN.ndot = NaN;
SPN.hdot = NaN;
SPN.udot = NaN;

% Additional HFN neuron fields
HFN.SumI = NaN;
HFN.alphan = NaN;
HFN.alpham = NaN;
HFN.alphah = NaN;
HFN.betan = NaN;
HFN.betam = NaN;
HFN.betah = NaN;
HFN.mdot = NaN;
HFN.ndot = NaN;
HFN.hdot = NaN;
HFN.udot = NaN;

% Additional synapse fields
syn12.T = NaN;
syn12.rdot = NaN;

% SPN structure array
SPN = repmat(SPN,1,Nneur.SPN);
HFN = repmat(HFN,1,Nneur.HFN);

% Synapse structure arrays
syn12 = repmat(syn12,1,Nsyn.syn12);
syn32 = repmat(syn32,1,Nsyn.syn32);

Nneur.total = Nneur.SPN + Nneur.HFN;
Nsyn.total = Nsyn.syn12 + Nsyn.syn13 + Nsyn.syn32;
for i = 1:Nneur.PL
    if PL(i).signaltype == 1
        [PL(i).phasic,PL(i).spike] = hh_PLsignal1(timeline, samppersec, PL(i).spikedur, PL(i).phasicstart, PL(i).phasicend, PL(i).phasicspikefreq, PL(i).tonicspikefreq);
    elseif PL(i).signaltype == 2
        [PL(i).spike] = hh_PLsignal2(timeline, PL(i).spikedur, PL(i).stimtime);
    elseif PL(i).signaltype == 3
        db = 1; % Experimental group
        neuron_num = i+6;
        [PL(i).spike] = hh_PLsignal3(timeline, PL(i).spikedur, twdbs, db, cb_pls_ids, neuron_num);
    end
end
Y0 = hh_Y0(Nneur,Nsyn,SPN);
connected_SPN_idxs = arrayfun(@(x) randsample(1:Nsyn.syn12,3),1:Nneur.SPN,'uni',false);
[T,Y] = ode45(@hh_ode,[tmin tmax],Y0,[],timeline,Nneur,Nsyn,PL,SPN,HFN,syn12,syn13,syn32,connected_SPN_idxs);
[SPN,HFN,syn12,syn13,syn32] = hh_bigYmap(Y,Nneur,Nsyn,SPN,HFN,syn12,syn13,syn32);

toc

if PL(i).signaltype == 1 || PL(i).signaltype == 3
    figure; 
%     plot(timeline,syn12(1).Tmax.*PL(1).spike,timeline,syn12(2).Tmax.*PL(2).spike,timeline,syn12(3).Tmax.*PL(3).spike); 
    hold on;
    for neuron_num = 1:7
        plot(timeline,syn12(neuron_num).Tmax.*PL(neuron_num).spike + neuron_num*1.75);
    end
    hold off;
%     axis([T(1) T(end) -0.1 1.6])
    title('PLS Neurons'); legend('PLS # 1', 'PLS # 2', 'PLS # 3');
    
    figure; plot(T,SPN(1).u_all,T,SPN(2).u_all+100,T,SPN(3).u_all+200)
    figure; plot(T,HFN(1).u_all,T,HFN(2).u_all+100)
    
%     figure; plot(T,syn12(1).r_all,T,syn12(2).r_all,T,syn12(3).r_all)
%     figure; plot(T,syn13(1).r_all,T,syn13(2).r_all,T,syn13(3).r_all)
%     figure; plot(T,syn32(1).r_all,T,syn32(2).r_all,T,syn32(3).r_all)
elseif PL(i).signaltype == 2
    figure; plot(timeline,100.*PL(1).spike,T,SPN(2).u_all,T,HFN(1).u_all)
    legend('PLS', 'SPN', 'HFN')
end
