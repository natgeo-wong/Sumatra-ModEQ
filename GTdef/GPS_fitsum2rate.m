function [ ] = GPS_fitsum2rate(fitsumName,scaleErr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         GPS_fitsum2rate.m                          % 
% extract background linear rates from *.fitsum                      %
% NOTE: rates converted from m/yr to mm/yr!!!!                       %
%                                                                    %	
% INPUT:                                                             %
% fitsumName - *.fitsum or *_1site.fitsum                            %
%            = '' means all *.fitsum in the current directory        %
% scaleErr   - errors multiplied by scaleErr                         %
%                                                                    %	
% OUTPUT:                                                            %
% *.vel format                                                       %
% 1   2   3   4    5  6  7  8   9   10  11     12 13  14 15    16    %
% Sta Lon Lat Elev VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D   Cne   %
% linear.vel - long-term background linear rates                     %
%                                                                    %	
% related to GPS_extract_GPSfitsum.m                                 %
% only works for files in current folder                             %
% first created by Lujia Feng Wed Nov 28 12:35:20 SGT 2012           %
% last modified by Lujia Feng Tue Dec  3 13:34:58 SGT 2013           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scale2mm = 1e3;

if isempty(fitsumName)
    nameStruct = dir('*.fitsum');      % not regexp \. here
else
    nameStruct = dir(fitsumName);      % * like linux system can be used in frneuName
end

fnum = length(nameStruct);
if fnum==0  
    error('GPS_fitsum2rate ERROR: no fitsum files exist in the current directory satisfying input!'); 
end

% coseismic
flinName = 'linear.vel';
flin     = fopen(flinName,'w');
fprintf(flin,'# Rates extracted from fitsum files by GPS_fitsum2rate.m\n');
fprintf(flin,'# 1   2   3   4    5  6  7  8   9   10  11      12 13  14 15    16\n');
fprintf(flin,'# Sta Lon Lat Elev VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
fprintf(flin,'# Elev in [m] Rate in [mm/yr] error in [mm/yr]\n');

wgt = 1;
for ii=1:fnum
    fname = nameStruct(ii).name
    [ ~,basename,~ ] = fileparts(fname);
    site = basename(1:4);
    [ fitsum ] = GPS_readfitsum(fname,'',1);
    T1 = fitsum.rateRow(1); [ D1,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(T1);
    T2 = fitsum.rateRow(2); [ D2,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(T2);
    fstind    = 2;
    nnRate    = fitsum.rateRow(fstind+2)*scale2mm; 
    eeRate    = fitsum.rateRow(fstind+4)*scale2mm; 
    uuRate    = fitsum.rateRow(fstind+6)*scale2mm;
    fstind    = 8;
    nnRateErr = fitsum.rateRow(fstind+2)*scale2mm*scaleErr; 
    eeRateErr = fitsum.rateRow(fstind+4)*scale2mm*scaleErr; 
    uuRateErr = fitsum.rateRow(fstind+6)*scale2mm*scaleErr;
    errs = [nnRateErr eeRateErr uuRateErr];
    if any(isinf(errs)) || min(errs)<1e-20
        fprintf(flin,'#%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
                site,fitsum.loc,eeRate,nnRate,uuRate,eeRateErr,nnRateErr,uuRateErr,wgt,D1,T1,D2,T2,0.0);
    else
        fprintf(flin,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
                site,fitsum.loc,eeRate,nnRate,uuRate,eeRateErr,nnRateErr,uuRateErr,wgt,D1,T1,D2,T2,0.0);
    end
end

fclose(flin);
