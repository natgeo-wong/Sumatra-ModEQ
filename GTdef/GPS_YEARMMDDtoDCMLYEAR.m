function [ year,doy,decyr ] = GPS_YEARMMDDtoDCMLYEAR(yearmmdd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_YEARMMDDtoDCMLYEAR                              %
% convert time from YEARMODY and YEAR.DCML 					%	
% noon is used to represent each day                                            %
% works only for one day                                                        %
%                                                                               %
% INPUT:									%
% yearmmdd - YEARMMDD e.g. 19960215                                             %
%    can be string or scalar                                                    %
%                                                                               %
% OUTPUT:									%
% year, doy, decyr                                                              %
%                                                                               %
% modified on GPS_YYMONDDtoYEARMMDD.m Lujia Feng Wed Jul 27 19:01:47 SGT 2011   %
% added output year & doy lfeng Tue Sep 13 14:20:02 SGT 2011                    %
% last modified by Lujia Feng Tue Sep 13 15:07:34 SGT 2011                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% subdivide string yearmmdd into year, mm, and dd
if isscalar(yearmmdd)
   yearmmdd = num2str(yearmmdd,'%8.0f');
elseif ~ischar(yearmmdd)
   error('GPS_YEARMMDDtoDCMLYEAR ERROR: yearmmdd should be either a scalar number or string!');
end
year = str2num(yearmmdd(1,1:4)); mm = str2num(yearmmdd(1,5:6)); dd = str2num(yearmmdd(1,7:8));

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
   %$oneday = 1/365.2425;	% the average day length; counts for leap years
   oneday = 1/365;
   switch mm
      case 1  
      	mday = 0;
      case 2  
      	mday = 31;
      case 3    
      	mday = 59;
      case 4    
      	mday = 90;
      case 5    
      	mday = 120;	           
      case 6    
      	mday = 151;	           
      case 7    
      	mday = 181;	           
      case 8    
      	mday = 212;	           
      case 9    
      	mday = 243;	           
      case 10  
      	mday = 273;	            
      case 11  
      	mday = 304;	            
      case 12  
      	mday = 334;                    
    end
% a leap yar
else
   oneday = 1/366;
   switch mm
      case 1   
      	mday = 0;
      case 2   
      	mday = 31;	
      case 3   
      	mday = 60; 	
      case 4   
      	mday = 91;	
      case 5   
      	mday = 121;	
      case 6   
      	mday = 152;	
      case 7   
      	mday = 182;	
      case 8   
      	mday = 213;	
      case 9   
      	mday = 244;	
      case 10  
      	mday = 274;	
      case 11  
      	mday = 305;	
      case 12  
      	mday = 335;
   end
end
% since the first day is alway 0, I use different oneday lengths for non-leap or leap years
% use the middle of day to present each day
doy = mday+dd;
decyr = year+(doy-1+0.5)*oneday;
