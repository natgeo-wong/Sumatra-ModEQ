function [ indKeep,indRem ] = GPS_lsqnonlin_1site_outlier_Chauvenet(rneuRes)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       GPS_lsqnonlin_1site_outlier_Chauvenet                       %
% use Chauvenet's Criterion to detect and exclude outliers                          %
%                                                                                   %
% INPUT:                                                                            %
% rneuRes   - (data-model) residuals [dayNum*8]                                     %
%           = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                           %
%                                                                                   %
% OUTPUT:                                                                           %
% rneuKeep  - data kept as data                                                     %
% rneuOut   - data removed as outliers                                              %
%                                                                                   %
% first created by Lujia Feng Mon Nov 25 15:45:09 SGT 2013                          %
% last modified by Lujia Feng Mon Nov 25 16:16:05 SGT 2013                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% exame outliers by looping through residuals of N,E,U components 
pntNum = size(rneuRes,1);
indRem = false(pntNum,1);
for ii=1:3
   res     = rneuRes(:,2+ii);
   resAve  = mean(res);
   resStd  = std(res);
   tt      = abs(res-resAve)/resStd;
   % probability outside tt
   prob0   = normcdf(-tt); % probability of <=-tt
   prob1   = normcdf(tt);  % probability of <=tt
   probin  = prob1-prob0;  % probability of (-tt tt]
   probout = 1-probin;
   nn      = pntNum*probout;
   % reject if nn<0.5, 0.5 number of points is a little arbitrary
   indRem  = indRem | (nn<0.5);
end

% flag outliers as long as one component meets Chauvenet's Criterion
outNum   = sum(indRem);
fprintf(1,'removed %d days\n\n',outNum);
indKeep  = ~indRem;
