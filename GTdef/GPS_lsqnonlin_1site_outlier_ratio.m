function [ rneuRes,rneuKeep,rneuOut ] = ...
         GPS_lsqnonlin_1site_outlier_ratio(rneu,rneuModel,rneuOut,xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         GPS_lsqnonlin_1site_outlier_ratio                         %
% calculate standard deviation from residual scatters in order to detect outliers   %
%                                                                                   %
% INPUT:                                                                            %
% rneu      - a rneu dayNum*8 matrix to store data                                  %
%           = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                           %
% rneuModel - model prediction                                                      %
%           = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                           %
% rneuOut   - rneu data that have been removed as outliers                          %
%                                                                                   %
% outRatio  - residuals larger than outRatio*s are specified as outliers            %
%    s = sqrt(sum(ri)^2/dofNum)                                                     %
%    usually outRatio = 3                                                           %
%                                                                                   %
% xx        - unknown parameters that need to be estimated 		            %
%                                                                                   %
% OUTPUT:                                                                           %
% rneuRes   - (data - model) residuals                                              %
% rneuKeep  - data kept as data                                                     %
%   if rneuKeep = [], no more iterations are needed!                                %
% rneuOut   - data removed as outliers                                              %
%                                                                                   %
% first created by Lujia Feng Mon May 13 11:11:47 SGT 2013                          %
% last modified by Lujia Feng Mon May 13 16:03:45 SGT 2013                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outRatio = 3;
% calculate residuals
rneuRes  = rneu;
rneuRes(:,3:5) = rneu(:,3:5)-rneuModel(:,3:5);
% Note: different from residuals output from lsqnonlin
nnRes    = abs(rneuRes(:,3)); 
eeRes    = abs(rneuRes(:,4)); 
uuRes    = abs(rneuRes(:,5)); 

dayNum   = size(rneu,1);
xxNum    = length(xx);           % number of unknown paramters
dofNum1  = dayNum-xxNum;         % degree of freedom for each component

nnStd    = sqrt(sum(nnRes.^2)/dofNum1);
eeStd    = sqrt(sum(eeRes.^2)/dofNum1);
uuStd    = sqrt(sum(uuRes.^2)/dofNum1);

nnStdN   = nnStd*outRatio*ones(size(nnRes));
eeStdN   = eeStd*outRatio*ones(size(eeRes));
uuStdN   = uuStd*outRatio*ones(size(uuRes));

% flag as outliers as long as one component exceed the residual shreshold
indRemv  = nnRes>=nnStdN | eeRes>=eeStdN | uuRes>=uuStdN;
outNum   = length(find(indRemv>0));
fprintf(1,'removed %d days\n\n',outNum);
indKeep  = ~indRemv;

if sum(indRemv)>0
   rneuOut  = [ rneuOut; rneu(indRemv,:) ];
   rneuKeep = rneu(indKeep,:);
else
   rneuKeep = [];
end
