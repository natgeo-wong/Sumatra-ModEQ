function [ evar,wvar ] = EQ_mfit_pos (mfit)

%                                EQ_mfit.m
%     EQ Function that finds the bestfit position from the misfit data
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function finds the bestfit model from the gridsearch based on the
% misfit data.
%
% INPUT:
% -- mfit : misfit data array
%
% OUTPUT:
% -- evar : structure containing information about bestfit model according
%           to the variance explained
% -- wvar : structure containing information about bestfit model according
%           to the weighted variance explained
%
% FORMAT OF CALL: EQ_mfit_pos (misfit)
%
% OVERVIEW:
% 1) This function take in as input the misfit data structure and reads in
%    the variance explained and weighted variance explained
%
% 2) The function then proceeds to find the bestfit according to the
%    highest value for both variance explained and weighted variance
%    explained and extracts the relevant data
%
% 3) The function then exports the information to the parent function.
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

evec = mfit(:,9);  [ evar.best,evar.ii ] = max(evec);
wvec = mfit(:,11); [ wvar.best,wvar.ii ] = max(wvec);

evar.lon = mfit(evar.ii,3); evar.lat = mfit(evar.ii,4);
wvar.lon = mfit(wvar.ii,3); wvar.lat = mfit(wvar.ii,4);

end