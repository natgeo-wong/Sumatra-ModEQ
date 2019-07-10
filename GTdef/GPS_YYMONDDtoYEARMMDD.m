function [ yearmmdd,decyr ] = GPS_YYMONDDtoYEARMMDD(yymondd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_YYMONDDtoYEARMMDD.m				%
% convert time from YYMONDD (used by gd or GD files) 				%
% to YEARMODY and YEAR.DCML 							%
% noon is used to represent each day						%
% works only for one day							%
% 										%
% INPUT:									%
% yymondd - DDMONYY e.g. 96FEB15 ( a char string)				%
%										%
% OUTPUT:									%
% yearmmdd - YEARMMDD e.g. 19960215						%
% time    - YEAR.DCML e.g. 1996.122951 						%
%										%
% first created by lfeng Thu Mar  3 02:15:47 EST 2011				%
% use midday/noon for each day lfeng Wed Jul 27 19:27:14 SGT 2011		%
% last modified by lfeng Wed Jul 27 19:28:02 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% subdivide string yymondd into yy, mon, and dd
yy=str2num(yymondd(1,1:2)); mon=yymondd(1,3:5); dd=str2num(yymondd(1,6:7));

% from 2-digit yy to 4-digit year
if yy>70, year=1900+yy; else year=2000+yy; end

% convert letter month to number month
switch mon
   case 'JAN'  
        mm = 1;
   case 'FEB'  
        mm = 2;
   case 'MAR'  
   	mm = 3;
   case 'APR'  
   	mm = 4;
   case 'MAY'  
   	mm = 5;
   case 'JUN'  
   	mm = 6;
   case 'JUL'  
   	mm = 7;
   case 'AUG' 
   	mm = 8;
   case 'SEP' 
   	mm = 9;
   case 'OCT' 
   	mm = 10;
   case 'NOV' 
   	mm = 11;
   case 'DEC' 
   	mm = 12;
   otherwise error('Month conversion is wrong!');
end
yearmmdd=int32(year*10000+mm*100+dd);

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
decyr = year+(mday+dd-1+0.5)*oneday;
