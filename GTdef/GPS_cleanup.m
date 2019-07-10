function [ rneuKeep,rneuRemCell ] = GPS_cleanup(rneuRaw,errRatio)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_cleanup.m                                  %
% clean up GPS time series before fitting                                       %
% remove data points that have                                                  %
% (1) zero errors                                                               %
% (2) erros larger than 0.1                                                     %
% (3) errors larger than errRatio*mean(err)                                     %
%                                                                               %
% INPUT:                                                                        % 
% rneuRaw  = [ day time north east vert north_err east_err vert_err ]           %
% day,time,north,east,vert,north_err,east_err,vert_err are all column vectors   %
% errRatio - threshold for points being identified as outliers                  %
%          = 3 usually								%
%    if errRatio = [], not considered                                           %
%                                                                               %
% OUTPUT:                                                                       %
% rneuKeep    - data kept                                                       %
% rneuRemCell - data removed in steps                                           %
% dflag    - column vector (1 means data; 0 means outliers)                     %
%                                                                               %
% first created by Lujia Feng Fri Oct 22 08:01:58 EDT 2010                      %
% errRatio can be set by input lfeng Mon Aug 29 11:43:03 SGT 2011               %
% output rneuKeep lfeng Mon Aug 29 12:43:20 SGT 2011                            %
% added (2) lfeng Thu Mar 14 06:06:20 SGT 2013                                  %
% added output rneuRemv lfeng Wed Nov 27 13:42:54 SGT 2013                      %
% last modified by Lujia Feng Thu Nov 28 14:47:36 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize
dayNum   = size(rneuRaw,1);
indRem1  = false(dayNum,1);
indRem2  = false(dayNum,1);
indRem3  = false(dayNum,1);

% find out errors = 0, flag those data points
indRem1  = rneuRaw(:,1)==0 | rneuRaw(:,2)==0 | rneuRaw(:,6)==0 | rneuRaw(:,7)==0 | rneuRaw(:,8)==0;
rneuRem1 = rneuRaw(indRem1,:);

% find out errors > 0.01
err = 0.01;
err = 0.05;
indRem2  = rneuRaw(:,6)>err | rneuRaw(:,7)>err | rneuRaw(:,8)>err;
rneuRem2 = rneuRaw(indRem2,:);
  
% find out errors are ? times larger than the average errors 59% data points (2 sigma is 95% confidence level)
if ~isempty(errRatio) & errRatio>0
   ratio = 0.025; delNum = int32(dayNum*ratio);
   fprintf(1,'3*error bounds: ');
   for ii=6:8
      err0 = rneuRaw(:,ii); 
      err  = sort(err0); 
      err  = err(1+delNum:end-delNum);
      merr = errRatio*mean(err);
      fprintf(1,'%15.5f\t',merr);
      ind  = err0>merr & err0<=0.05;
      indRem3 = indRem3 | ind;
   end
   fprintf(1,'\n');
end
rneuRem3 = rneuRaw(indRem3,:);

indRem   = indRem1 | indRem2 | indRem3;
rneuRem  = rneuRaw(indRem,:);
rneuRemCell = {rneuRem1; rneuRem2; rneuRem3; rneuRem };
indKeep  = ~indRem;
rneuKeep = rneuRaw(indKeep,:);
