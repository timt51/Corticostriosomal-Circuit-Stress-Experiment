function Y0 = hh_Y0(Nneur,Nsyn,SPN)
% Leif Gibb through 9/9/16

Y0 = [repmat([0.0003 0.0529 0.3177 0.5961],1,Nneur.total) zeros(1,Nsyn.total)];

end
