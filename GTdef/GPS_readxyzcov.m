function [ yearmmdd,XX,YY,ZZ,XXErr,YYErr,ZZErr,corXY,corXZ,corYZ ] = GPS_readxyzcov(finName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_readxyzcov                                   %
% read *.xyzcov files                                                           %
% *.xyzcov files are cat from gipsy output xyzcov_final for all days            %
%                                                                               %
% INPUT:                                                                        %
% finName - SITE.xyzcov                                                         %
% *.xyzcov FORMAT                                                               %
% 1         2   3   4   5      6      7      8      9      10                   %
% YEARMMDD  XX  YY  ZZ  XXErr  YYErr  ZZErr  corXY  corXZ  corYZ                %
% distance in meter                                                             %
% XXErr,YYErr,ZZErr - standard deviation                                        %
% corXY,corXZ,corYZ - correlation                                               %
%              covXY                                                            %
% corXY = ----------------                                                      %
%            XXErr*YYErr                                                        %
%                                                                       	%
% OUTPUT:                                                                       %
% yearmmdd,XX,YY,ZZ,XXErr,YYErr,ZZErr,corXY,corXZ,corYZ [ column vectors ]      %
%                                                                               %
% first created by Lujia Feng Thu Mar 14 01:23:07 SGT 2013                      %
% changed from *.stacov to *.xyzcov to avoid conflict with GIPSY stacov format  %
% last modified by Lujia Feng Fri Mar 22 10:25:32 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if xyzcov file exists %%%%%%%%%%
if ~exist(finName,'file')  
    error('GPS_readxyzcov ERROR: %s does not exist!',finName); 
end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(finName,'r');
staCell  = textscan(fin,'%f %f %f %f %f %f %f %f %f %f','CommentStyle','#');	% Delimiter default White Space
xyzcov   = cell2mat(staCell);
yearmmdd = xyzcov(:,1);
XX       = xyzcov(:,2); 
YY       = xyzcov(:,3); 
ZZ       = xyzcov(:,4); 
XXErr    = xyzcov(:,5);
YYErr    = xyzcov(:,6);
ZZErr    = xyzcov(:,7);
corXY    = xyzcov(:,8);
corXZ    = xyzcov(:,9);
corYZ    = xyzcov(:,10);
fclose(fin);
