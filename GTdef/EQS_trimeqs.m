function [ eqs ] = EQS_trimeqs(eqsName,polyName,ymdRange,decyrRange,magRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                         EQS_trimeqs                                           %
% keep earthquakes                                                                              %
% (1) in a polygon  (2) in a time period (3) in a magnitude range                               % 
%                                                                                               %
% INPUT:                                                                                        %
% (1) eqsName: name for the earthquake catalog                                                  % 
% 1    2  3  4  5  6       7          8          9       10         11		12              %
% YEAR MO DY HR MI SS.SSSS LONGITUDE  LATITUDE   DEPTH   MAGNITUDE  EVENT ID    DECYR           %
% 2008 07 04 19 46 30.3100 -118.81384 37.57717   6.3500  0.86                                   %
% 2011 07 10 05 09 06.2600 95.09900    4.61800  35.3000  4.70    201107101008  2011.521918      %
%                                                                                               %
% (2) polyName: name for the polygon file specifying the region                                 %
%     poly = [ lon lat ]     (lon,lat are column vectors)                                       %
% (3) ymdRange   = [ min max ] (1x2 row vector)                                                 %
% (4) decyrRange = [ min max ] (1x2 row vector)                                                 %
% (5) magRange   = [ min max ] (1x2 row vector)                                                 %
%                                                                                               %
% OUTPUT:                                                                                       %
%                                                                                               %
% first created by Lujia Feng Tue Jul 12 09:37:07 SGT 2011                                      %
% added time range & magnitude range lfeng Tue Feb  4 17:48:02 SGT 2014                         %
% changed from EQS_inpoly.m to EQS_trimeqs.m lfeng Tue Feb  4 18:09:11 SGT 2014                 %
% last modified by Lujia Feng Tue Feb  4 18:31:37 SGT 2014                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% read in earthquake catalog %%%%%%%%%%
[ eqs ] = EQS_readeqs(eqsName);
yr  = eqs(:,1); mon = eqs(:,2); day = eqs(:,3);
ymd = yr*1e4+mon*1e2+day;
lon = eqs(:,7); lat = eqs(:,8); mag = eqs(:,10);
if size(eqs,2)==12
    decyr = eqs(:,12);
else
    decyr = [];
end

inInd  = true(size(yr));
ymdInd = inInd;
decInd = inInd;
magInd = inInd;

%%%%%%%%%%%% keep data in the specified region %%%%%%%%%
if ~isempty(polyName)
    [ polyLon,polyLat ] = readpoly(polyName);
    inInd = inpolygon(lon,lat,polyLon,polyLat);   	% inpoly returns the same size as lon,lat
end

%%%%%%%%%%%% keep data in the specified period %%%%%%%%%
if ~isempty(ymdRange)
    ymdInd = ymd>=ymdRange(1) & ymd<=ymdRange(2);
end
if ~isempty(decyrRange) && ~isempty(decyr)
    decInd = decyr>=decyrRange(1) & decyr<=decyrRange(2);
end

%%%%%%%%%%%% keep data in the magnitude range %%%%%%%%%
if ~isempty(magRange)
    magInd = mag>=magRange(1) & mag<=magRange(2);
end

ind = inInd & ymdInd & decInd & magInd;
eqs = eqs(ind,:);

%%%%%%%%%% write out earthquake catalog %%%%%%%%%%
if ~isempty(polyName)
    [ ~,basename,~ ] = fileparts(polyName);
else
    [ ~,basename,~ ] = fileparts(eqsName);
    basename = [ basename '_trim' ];
end

foutName = [ basename '.eqs' ]; 
EQS_saveeqs(eqs,foutName);
