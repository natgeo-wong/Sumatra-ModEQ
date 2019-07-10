function EQ_print_pnt2 (finput,sites,vel)

%                              EQ_print_pnt3.m
%      EQ Function that Format Prints Type 3 GPS Data recorded by SuGAr
%                     Nathanael Wong Zhixin, Feng Lujia
%
% INPUT:
% -- finput
% -- imported GPS Data recorded by SuGAr stations (siteList, vel)
%    1) list of GPS stations (siteList)
%    2) data recorded by GPS stations (vel)
%
% OUTPUT:
% -- r : Number of SuGAr stations
% -- Formatted print (fprintf) of the GPS data of format type 3
%
% FORMAT OF CALL: EQ_print_pnt3 (finput, Stations, Data)
% 
% OVERVIEW:
% 1) This function will take as input imported GPS data of format type 3.
%
% 2) This function will then format print the header for the GPS data of
%    format type 3.
%
% 3) The function will then count the number of GPS stations that recorded
%    significant displacements from the earthquake event.
%
% 4) For each GPS station, the function will then read the imported GPS
%    data and save them into the point parameters.  These parameters are
%    defined by measurements of displacements of the respective SuGAr
%    stations affected by the individual events.
%
%    -- type   : type of GPS point data collected
%    -- name   : name of GPS station
%
%    -- lon    : longitude of GPS station (?)
%    -- lat    : latitude of GPS station (?)
%    -- z      : elevation of GPS station wrt sea-level (m)
%
%    -- Ue     : easting displacement measured by GPS station (m)
%    -- Un     : northing displacement measured by GPS station (m)
%    -- Uz     : vertical displacement measured by GPS station (m)
%
%    -- eUe    : error in measured easting displacement (m)
%    -- eUn    : error in measured northing displacement (m)
%    -- eUz    : error in measured vertical displacement (m)
%
%    -- weight : reliability of GPS station (m)
%
% 5) It will then format print all these input parameters into an input
%    file that is defined by finput.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(finput,'# point type   name');
fprintf(finput,'   ');
fprintf(finput,'lon (d)    lat (d)    z (m)');
fprintf(finput,'     ');
fprintf(finput,'Ue (m)     Un (m)');
fprintf(finput,'     ');
fprintf(finput,'eUe (m)    eUn (m)');
fprintf(finput,'    ');
fprintf(finput,'weight\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOOP PRINT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ r,~ ] = size(vel);

for i = 1:r
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    site = sites{i};        loc = vel(i,1:3);
    disp = vel(i,4:5)/1000; err = vel(i,6:7)/1000; 
    wgt  = vel(i,8);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf(finput,'  point 3      %s',site);
    fprintf(finput,'   ');
    fprintf(finput,'%-10.5f %-10.5f %-7.3f',loc);
    fprintf(finput,'   ');
    fprintf(finput,'%-8.5f   %-8.5f',disp);
    fprintf(finput,'   ');
    fprintf(finput,'%-7.5f    %-7.5f',err);
    fprintf(finput,'    ');
    fprintf(finput,'%-3.1f\n',wgt);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

fprintf (finput, ' \n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end