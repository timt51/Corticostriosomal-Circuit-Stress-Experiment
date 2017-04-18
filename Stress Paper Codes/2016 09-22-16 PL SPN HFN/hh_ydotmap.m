function ydot = hh_ydotmap(Nneur,Nsyn,SPN,HFN,syn12,syn13,syn32)
% Leif Gibb through 9/9/16

for i = 1:Nneur.SPN
    ydot(4*i-3,1) = SPN(i).udot;
    ydot(4*i-2,1) = SPN(i).mdot;
    ydot(4*i-1,1) = SPN(i).ndot;
    ydot(4*i,1) = SPN(i).hdot;
end

for i = 1:Nneur.HFN
    ydot(4*(Nneur.SPN+i)-3,1) = HFN(i).udot;
    ydot(4*(Nneur.SPN+i)-2,1) = HFN(i).mdot;
    ydot(4*(Nneur.SPN+i)-1,1) = HFN(i).ndot;
    ydot(4*(Nneur.SPN+i),1) = HFN(i).hdot;
end

for i = 1:Nsyn.syn12
   ydot(4*Nneur.total+i,1) = syn12(i).rdot;
end

for i = 1:Nsyn.syn13
   ydot(4*Nneur.total+Nsyn.syn12+i,1) = syn13(i).rdot;
end

for i = 1:Nsyn.syn32
   ydot(4*Nneur.total+Nsyn.syn12+Nsyn.syn13+i,1) = syn32(i).rdot;
end

end