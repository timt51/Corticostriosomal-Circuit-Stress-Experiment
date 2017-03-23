function [SPN,HFN,syn12,syn13,syn32] = hh_ymap(y,Nneur,Nsyn,SPN,HFN,syn12,syn13,syn32)
% Leif Gibb through 9/9/16

for i = 1:Nneur.SPN
    SPN(i).u = y(4*i-3);
    SPN(i).m = y(4*i-2);
    SPN(i).n = y(4*i-1);
    SPN(i).h = y(4*i);
end

for i = 1:Nneur.HFN
    HFN(i).u = y(4*(Nneur.SPN + i) - 3);
    HFN(i).m = y(4*(Nneur.SPN + i) - 2);
    HFN(i).n = y(4*(Nneur.SPN + i) - 1);
    HFN(i).h = y(4*(Nneur.SPN + i));
end

for i = 1:Nsyn.syn12
    syn12(i).r = y(4*Nneur.total + i);
end

for i = 1:Nsyn.syn13
   syn13(i).r = y(4*Nneur.total + Nsyn.syn12 + i);
end

for i = 1:Nsyn.syn32
   syn32(i).r = y(4*Nneur.total + Nsyn.syn12 + Nsyn.syn13 + i);
end

end