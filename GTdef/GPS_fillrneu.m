function [ rneuFill ] = GPS_fillrneu(rneu,ymdRange,decyrRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_fillrneu.m                             %
% fill rneu date gaps, fill nans for no data                            %
%                                                                       %
% INPUT:                                                                %
%          1        2         3     4    5    6     7     8             %
% rneu = [ YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err ]       %
% --------------------------------------------------------------------- %
% ymdRange   = [ min max ] {1x2 row vector}                             %
% decyrRange = [ min max ] {1x2 row vector}                             %
% Note: if ymdRange & decyrRange both provided,                         %
%       rneu is filled according to the widest range                    %
%       NaN indicates no filling & using data length                    %
%                                                                       %
% OUTPUT:                                                               %
% rneu filled with date gaps                                            %
%                                                                       %
% first created by Lujia Feng Mon Dec  9 16:36:53 SGT 2013              %
% added ymdRange & decyrRange lfeng Wed Jan  8 11:49:20 SGT 2014        %
% last modified by Lujia Feng Thu Jan  9 17:02:10 SGT 2014              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yearmmdd = rneu(:,1);

% data range
ymdStart = rneu(1,1);
ymdEnd   = rneu(end,1);

% YEARMMDD range
if ~isempty(ymdRange)
    if ymdRange(1)<ymdStart
        ymdStart = ymdRange(1);
    end
    if ymdRange(2)>ymdEnd
        ymdEnd   = ymdRange(2);
    end
end

% Decimal year range
if ~isempty(decyrRange)
    [ ymd1,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(decyrRange(1));
    [ ymd2,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(decyrRange(2));
    if ymd1<ymdStart
        ymdStart = ymd1;
    end
    if ymd2>ymdEnd
        ymdEnd   = ymd2;
    end
end

% start
yearStart = floor(ymdStart*1e-4); 
monStart  = floor((ymdStart-yearStart*1e4)*1e-2);
dayStart  = ymdStart-yearStart*1e4-monStart*1e2;
% end
yearEnd = floor(ymdEnd*1e-4); 
monEnd  = floor((ymdEnd-yearEnd*1e4)*1e-2);
dayEnd  = ymdEnd-yearEnd*1e4-monEnd*1e2;

dateStart = datenum(yearStart,monStart,dayStart);
dateEnd   = datenum(yearEnd,monEnd,dayEnd);

interval   = 1; % one day
datenumber = dateStart:interval:dateEnd;
[yy,mm,dd,~,~,~] = datevec(datenumber);
yearmmddFill = yy*1e4+mm*1e2+dd;
daynumFill   = length(yearmmddFill);
decyrFill    = zeros(size(yearmmddFill));
for ii=1:daynumFill
    [ ~,~,decyrFill(ii) ] = GPS_YEARMMDDtoDCMLYEAR(yearmmddFill(ii));
end
rneuFill = NaN(daynumFill,8);
rneuFill(:,1) = yearmmddFill;
rneuFill(:,2) = decyrFill;

[ ~,locb ] = ismember(yearmmdd,yearmmddFill);
rneuFill(locb,:) = rneu;
