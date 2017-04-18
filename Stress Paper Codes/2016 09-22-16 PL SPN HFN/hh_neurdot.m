function neur = hh_neurdot(neur,t,timeline)
% Leif Gibb through 9/9/16

neur.SumI = neur.gL*(neur.u-neur.EL) + neur.gNa*neur.m^3*neur.h*(neur.u-neur.ENa) + neur.gK*neur.n^4*(neur.u-neur.EK);
neur.alphan = (0.1-0.01*neur.u)/(exp(1-0.1*neur.u)-1);
neur.alpham = (2.5-0.1*neur.u)/(exp(2.5-0.1*neur.u)-1);
neur.alphah = 0.07*exp(-neur.u/20);
neur.betan = 0.125*exp(-neur.u/80);
neur.betam = 4*exp(-neur.u/18);
neur.betah = 1/(exp(3-0.1*neur.u)+1);
neur.mdot = neur.alpham*(1-neur.m) - neur.betam*neur.m;
neur.ndot = neur.alphan*(1-neur.n) - neur.betan*neur.n;
neur.hdot = neur.alphah*(1-neur.h) - neur.betah*neur.h;

if isfield(neur,'Isyn') && ~isnan(neur.Isyn) && neur.Isyn
    neur.SumI = neur.SumI + neur.Isyn;
end

if isfield(neur,'IDC') && neur.IDC
    neur.udot = (-neur.SumI + interp1(timeline,neur.IDC,t))/neur.C;
else
    neur.udot = -neur.SumI/neur.C;
end

end