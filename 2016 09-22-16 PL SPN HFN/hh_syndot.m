function syn = hh_syndot(syn,pre,t,timeline)
% Leif Gibb through 9/9/16

if isfield(pre,'spike')
    syn.T = syn.Tmax*interp1(timeline,pre.spike,t);
else
    syn.T = syn.Tmax/(1+exp(-(pre.u+pre.Vshift-syn.Vp)/syn.Kp));
end

syn.rdot = syn.alpha*syn.T*(1-syn.r) - syn.beta*syn.r;

end