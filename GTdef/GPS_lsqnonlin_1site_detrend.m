function [ rneuNrate ] = GPS_lsqnonlin_1site_detrend(rneu,xx,tt0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         GPS_lsqnonlin_1site_detrend                         %
% Remove background rates for one station                                     %
%                                                                             %
% INPUT:                                                                      %
% rneu - data marix (dayNum*8)                                                %
%      = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                          %
% xx   - unknown parameters that need to be estimated                         %
% tt0     - time reference point                                              %
%         = [] means using the first point as reference                       %
%                                                                             %
% OUTPUT:                                                                     %
% rneuNrate - data with background rates removed                              %
%             errors are kept the same                                        %
%                                                                             %
% first created by Lujia Feng Mon Oct 22 18:55:42 SGT 2012                    %
% added time reference tt0 lfeng Wed Jan  8 12:58:10 SGT 2014                 %
% last modified by Lujia Feng Wed Jan  8 14:08:18 SGT 2014                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(tt0)
    % time reference to the 1st observation point
    tt = rneu(:,2) - rneu(1,2);        
else
    tt = rneu(:,2) - tt0;
end

nn = rneu(:,3);
ee = rneu(:,4);
uu = rneu(:,5);

% base model = intercept + rate
xx1st = 0; 
nnLinear = xx(xx1st+1) + xx(xx1st+2)*tt;
eeLinear = xx(xx1st+3) + xx(xx1st+4)*tt;
uuLinear = xx(xx1st+5) + xx(xx1st+6)*tt;

rneuNrate = rneu;
rneuNrate(:,3:5) = [ nn-nnLinear ee-eeLinear uu-uuLinear ];
