function [  ] = GMT_writecont(fcontName,lon,lat,height)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GMT_writecont				        %
% save an ASCII xyz contour file  						%
%										%
% INPUT:                                                        		%
%   lon, lat  									%
%   height - normally negative meaning below sea level				%
%   all in column vectors							%
%										%
% OUTPUT: 									%
%   1     2       3    								% 
%   LON   LAT     DEPTH     							%
%   contour line divider is '>'							%
%   patch divider is '> -Z 0.0'							%
%										%
% first created by lfeng Thu Oct 13 06:40:02 SGT 2011				%
% modified to write gmt patch lfeng Fri Jun 26 12:25:36 SGT 2015                %
% last modified by lfeng Thu Nov 15 15:32:32 SGT 2012                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% open the file %%%%%%%%%%
fcont = fopen(fcontName,'w');
fprintf(fcont,'#contour line in region of interest output by GMT_writecont.m\n');

%%%%%%%%%% output contour line %%%%%%%%%%
pntNum   = length(lon);
newcurve = 0;	% new curve flag
for ii=1:pntNum
   if isnan(lon(ii))
      if newcurve==1 
         newcurve = 0;
	 if isnan(height(ii))
            fprintf(fcont,'>\n'); 
	 else
            fprintf(fcont,'> -Z %f\n',height(ii)); 
	 end
      end
   else
      if newcurve==0  
         newcurve = 1; 
      end
      fprintf(fcont,'%15.9f %15.9f %15.6e\n',lon(ii),lat(ii),height(ii)); 
   end
end

fclose(fcont);
