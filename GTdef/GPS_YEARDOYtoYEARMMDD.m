function [ yearmmdd,mm,dd,decyr ] = GPS_YEARDOYtoYEARMMDD(year,doy)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          GPS_YEARDOYtoYEARMMDD.m                              %
% convert time from year & doy to YEARMMDD                                      %
% noon is used to represent each day                                            %
% works only for one day                                                        %
%                                                                               %
% INPUT:                                                                        %
% year, doy                                                                     %
%                                                                               %
% OUTPUT:                                                                       %
% yearmmdd - YEARMMDD e.g. 20090101 [int32]                                     %
% mm, dd                                                                        %
% decyr - decimal year e.g. 2009.00137                                          %
%                                                                               %
% first created by Lujia Feng Fri Nov 15 16:53:17 SGT 2013                      %
% last modified by Lujia Feng Fri Nov 15 16:56:05 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%---------------------- leap year or not ----------------------------
leap = 0;		% default is not a leap year
if mod(year,400)==0  
   leap = 1;
elseif (mod(year,100)~=0) && (mod(year,4)==0)
   leap = 1; 
end 

%%--------------------------------------------------------------------
% not a leap year
if leap==0
   allday = 365;
   oneday = 1.0/allday;
   decyr  = year+(doy-1+0.5)*oneday;
   if doy <= 31
      mm = 1; mday = 0;
   elseif doy <= 59
      mm = 2; mday = 31;
   elseif doy <= 90
      mm = 3; mday = 59;
   elseif doy <= 120
      mm = 4; mday = 90;
   elseif doy <= 151
      mm = 5; mday = 120;
   elseif doy <= 181
      mm = 6; mday = 151;
   elseif doy <= 212
      mm = 7; mday = 181;
   elseif doy <= 243
      mm = 8; mday = 212;
   elseif doy <= 273
      mm = 9; mday = 243;
   elseif doy <= 304
      mm = 10; mday = 273;
   elseif doy <= 334
      mm = 11; mday = 304;
   else
      mm = 12; mday = 334;
   end
% a leap yar
else
   allday = 366;
   oneday = 1.0/allday;
   decyr  = year+(doy-1+0.5)*oneday;
   if doy <= 31
      mm = 1; mday = 0;
   elseif doy <= 60
      mm = 2; mday = 31;
   elseif doy <= 91
      mm = 3; mday = 60;
   elseif doy <= 121
      mm = 4; mday = 91;
   elseif doy <= 152
      mm = 5; mday = 121;
   elseif doy <= 182
      mm = 6; mday = 152;
   elseif doy <= 213
      mm = 7; mday = 182;
   elseif doy <= 244
      mm = 8; mday = 213;
   elseif doy <= 274
      mm = 9; mday = 244;
   elseif doy <= 305
      mm = 10; mday = 274;
   elseif doy <= 335
      mm = 11; mday = 305;
   else
      mm = 12; mday = 335;
   end
end
% since the first day is alway 0, I use different oneday lengths for non-leap or leap years
dd = doy - mday;
yearmmdd = int32(str2num([ num2str(year,'%4d') num2str(mm,'%02d') num2str(dd,'%02d')]));
