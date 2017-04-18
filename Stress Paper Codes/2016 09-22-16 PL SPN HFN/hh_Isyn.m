function post = hh_Isyn(post,syn)
% Leif Gibb through 9/9/16

post.Isyn = post.Isyn + syn.gsyn*syn.r*(post.u+post.Vshift-syn.Erev);

end