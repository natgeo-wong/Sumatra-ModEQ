function [ evar,wvar ] = EQ_mfit_pos (lmfitmat)



evec = lmfitmat(:,9);  [ evar.best,evar.ii ] = max(evec);
wvec = lmfitmat(:,11); [ wvar.best,wvar.ii ] = max(wvec);

evar.lon = lmfitmat(evar.ii,3); evar.lat = lmfitmat(evar.ii,4);
wvar.lon = lmfitmat(wvar.ii,3); wvar.lat = lmfitmat(wvar.ii,4);

end