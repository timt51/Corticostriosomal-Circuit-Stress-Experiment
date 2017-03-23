function ydot = hh_ode(t,y,timeline,Nneur,Nsyn,PL,SPN,HFN,syn12,syn13,syn32,connected_SPN_idxs)
% Hodgkin-Huxley circuit model implemented by Leif Gibb 6/28/15 through 9/9/16

[SPN,HFN,syn12,syn13,syn32] = hh_ymap(y,Nneur,Nsyn,SPN,HFN,syn12,syn13,syn32);

% for i = 1:Nneur.SPN
%     SPN(i) = hh_Isyn(SPN(i),syn12(i));
%     for j = 1:Nsyn.syn32
%         SPN(i) = hh_Isyn(SPN(i),syn32(j));
%     end
%     SPN(i) = hh_neurdot(SPN(i),t,timeline);
% end

for i = 1:Nneur.SPN
    % PLS connections
    for j = connected_SPN_idxs{i}
        SPN(i) = hh_Isyn(SPN(i),syn12(j));
    end
    % HFN connections
    for j = 1:Nsyn.syn32
        SPN(i) = hh_Isyn(SPN(i),syn32(j));
    end

    SPN(i) = hh_neurdot(SPN(i),t,timeline);
end

for i = 1:Nneur.HFN
    for j = 1:Nsyn.syn13
        HFN(i) = hh_Isyn(HFN(i),syn13(j));
    end
    HFN(i) = hh_neurdot(HFN(i),t,timeline);
end

for i = 1:Nsyn.syn12
    syn12(i) = hh_syndot(syn12(i),PL(i),t,timeline);
end

for i = 1:Nsyn.syn13
    syn13(i) = hh_syndot(syn13(i),PL(i),t,timeline);
end

for i = 1:Nsyn.syn32
    syn32(i) = hh_syndot(syn32(i),HFN(i),t,timeline);
end

ydot = hh_ydotmap(Nneur,Nsyn,SPN,HFN,syn12,syn13,syn32);

end