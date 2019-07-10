function [ ] = GPS_gipsy_prep(fsiteName,flogName,network,endDStr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                               GPS_gipsy_prep.m
% (1) prepare 3 sta_info files needed for GIPSY/OASIS: sta_id, sta_pos, and sta_svec
% They are under $GOA_VAR/sta_info. To check format, see $GOA/file_formats/sta_info
% They are in inverse chronological order, so new info should be added to the top
% (2) prepare ocean loading model input
% Note: only works for SuGAr antennas
% (3) write out the input file for run_gd2p_mcore.py & run_gd2p_mpi.py
% (4) prepare file to generate absolute antenna corrections
%                                                                                                                   
% INPUT:
% (1) fsiteName - *.sites GPS location files
%     1      2              3             4    			           
%     Site   Lon	    Lat	          Height			           
%     ABGS   99.387520914   0.220824642   236.2533			           
%
% (2) flogName  - *.log GPS station instrumentation files
%     1      2              3             4            5	  6            7      
%     Site   StartDate      EndDate       Manufacturer Receiver   Antenna      Radome
%     PSKI   20020805       20070409      ASHTECH      MICROZ     ASH701945B_M SCIT
%     PSKI   20070410       20120131      TRIMBLE      NETRS      ASH701945B_M SCIT
%     PSKI   20120201       99999999      TRIMBLE      NETR9      ASH701945B_M SCIT
%                                                                                                                   
% (3) network
%     'SuGAr' or 'Nepal'
%
% (4) endDStr = 'YEAR-MM-DD';
%     e.g., '2014-12-31'
%                                                                                                                   
% OUTPUT:
% (1) sta_id
%    interface between the station identifiers in the database and the outside world
%    station identifier = station number (not used currently) + station name
%    (space)SITE(5 spaces)0(space)SITE NAME
%    ABGS     0 ABGS 2006 01 01 Air Bangis, Indonesia
%
% (2) sta_pos
%    file that associates station identifiers with coordinates & velocities
%    only one line per site; one space between each column
%    (s)SITE(s)YYYY(s)MM(s)DD(s)HH:MM:SS.SS(s)(Days)(s)(X-15)(s)(Y-14)(s)(Z-14)(s)(Vx-15)(s)(Vy-14)(s)(Vz-14)
%  (s): one space
% Days: the amount of time in days the position is valid for [1000001.00]
%    X: earth center position x [m] (15 spaces) 
%    Y: earth center position y [m] (14 spaces)              -8 zeros
%    Z: earth center position z [m] (14 spaces)              |      | 
%   Vx: earth velocity in x-direction [m/yr]; if unkonwn = 0.00000000E+00 (15 spaces)
%   Vy: earth velocity in y-direction [m/yr]; if unkonwn = 0.00000000E+00 (14 spaces)
%   Vz: earth velocity in z-direction [m/yr]; if unkonwn = 0.00000000E+00 (14 spaces)
%   a comment about the reference system can be appended
%
% (3) sta_svec
%    file that associates station identifiers with local site vector (antenna height) & antenna type
%    a new line must be added if the antenna type or height change; in a reverse chronological order
%       to     from
%    (s)SITE(s)SITE(s)YYYY(s)MM(s)DD(s)HH:MM:SS.SS(s)(Obs-12)(s)(Ant-9)(s)(Vx-11)(s)(Vy-10)(s)(Vz-10)(s)(H-10)(s)C
%    (s)YEAR DD MM #
%  Obs: the amount of time in seconds of the total occupation (12 spaces)
%       the time can be always more, but do not overlap into the next occupation time
%       one day = 86,400 secs
%  Ant: antenna code name (9 spaces; left-aligned) consistent with the pcenter file
%   Vx: velocity component x (11 spaces) [.0000 or 0.0000]
%   Vy: velocity component y (10 spaces) [.0000 or 0.0000]
%   Vz: velocity component z (10 spaces) [.0000 or 0.0000]
%    H: station site vector (antenna height) in m (10 spcaes)
%    C: l - locall NEH system; c - Cartesian coordinate
%  YEAR DD MM: date the site vector was issued, can be omitted
%  a comment can be appended
%  to-site and from-site are the same indicating site vector for offset between the antenna and monument
%
% (4) ocnld_coeffs input
%    one line for each site; use FES2004 for ocean loading model
%    (SITE-24)(s)(X-16)(Y-16)(Z-16)
%    X,Y,Z can be longitude, latitude and height [m]
%    Z or height does not matter for ocean loading models
%  Use the input file at http://holt.oso.chalmers.se/loading/
%    a. select FES2004 for ocean tide model                                                                                            
%    b. selcet YES for correcting for the centre of mass motion of the Earth due to the ocean tides
%    c. copy the email content to TextEditor                                                                                                                                 
%       Note: if copying to vim, manually adjust the format, it takes time!                                                                                        
%             Do not to save the email as a file, GIPSY doesn't like this!
%
% (5) run_gd2p_mcore.py & run_gd2p_mpi.py input
%    Network SITE START_DATE END_DATE [ gipsy flags ]
%    SuGAr BSAT 2009-01-01 2009-01-01 -type s -orb_clk flinnR -amb_res 1 -stacov -sta_info ../sta_info/
%    a. network & site names are case sensitive!
%    b. Both START_DATE & END_DATE inclusive
%    c. orb_clk
%       if orb_clk not specified, orbit & clock info will be directly downloaded from JPL ftp
%       if orb_clk specified, no need to specify the path
%       the default orbit & clock dir is /home/lfeng/gipsy/orbits/JPL_GPS_Products
%    d. goa_prod_here
%       if the orbit & clock files have been downloaded to the processing folder
%
% (6) create a script to generate antenna correction files (create_antvel.sh)
% for example:
% antex2xyz.py -antexfile igs08.atx -anttype  ASH701945B_M -radcode SCIT -recname ABGS -fel 0 -del 5 -daz 5 -extrap -xyzfile  ABGS.xyz
%
% Notes:
% (1) DO NOT use tabs to fill in the spaces. GIPSY doesn't like tabs.
% (2) Make sure that there no EXTRA LINES at the end of the file.
% (3) pcenter file is necessary. Its format is
%     1        2          3        4        5
%     Ant_type Phace_type Offset_E Offset_N Offset_U [m]
%     ROGUE    L1         0.0000   0.0000   0.0079    J.M. Tranquilla, UNB,
%     ROGUE    L2         0.0000   0.0000   0.0264    Dorne-Margolin C146-6-1
%     ROGUE    LC         0.0000   0.0000  -0.0207    from TOP of choke ring
%										 
% first created by Lujia Feng Fri Mar  8 17:32:38 SGT 2013                            
% added antenna types lfeng Mon May 11 13:56:58 SGT 2015
% added to work with multiple antennas lfeng Mon May 11 14:28:53 SGT 2015
% added complete gd2pStr lfeng Thu May 14 22:45:30 SGT 2015
% changed date for sta_pos lfeng Mon Jun 22 17:14:27 SGT 2015
% editted gd2pStr1 & gd2pStr2 lfeng Tue Jun 23 10:25:16 SGT 2015
% added TPSCR.G5 for Myanmar campaign lfeng Wed Mar 16 00:01:33 SGT 2016
% modified run_gd2p.in lfeng Wed Mar 16 00:23:28 SGT 2016
% added output antenna correction script lfeng Wed Mar 16 00:59:17 SGT 2016
% added TRM59800.80 for Japan GeoNet lfeng Fri May 20 14:14:08 SGT 2016
% last modified by Lujia Feng Fri May 20 14:15:52 SGT 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ siteList,locs ] = GPS_readsites(fsiteName);
[ stainfo ] = GPS_readlog(flogName);
siteNum = length(siteList);

fid   = fopen('sta_id','w');
fpos  = fopen('sta_pos','w'); 
fvec  = fopen('sta_svec','w');
focn  = fopen('ocnld_coeffs.in','w');
fgd2p = fopen('run_gd2p.in','w');
fant  = fopen('create_antcal.sh','w');
antH     = 0.0;
sec30yrs = 946080000;  % sec in 30 years
sec1day  = 86400;  % sec in 1 day
%------------- basic solution -------------
%gd2pStr = '-type s -orb_clk flinnR -amb_res 1 -stacov -sta_info /home/lfeng/gipsy/SuGAr/sta_info/';
%------------- add ocnld -------------
%gd2pStr = '-type s -orb_clk flinnR -amb_res 1 -stacov -sta_info /home/lfeng/gipsy/SuGAr/sta_info/ -add_ocnld " -c /home/lfeng/gipsy/SuGAr/sta_info/ocnld_coeffs" -OcnldCpn';
%------------- add ocnld & trop -------------
%gd2pStr = '-type s -orb_clk flinnR -amb_res 1 -stacov -sta_info /home/lfeng/gipsy/SuGAr/sta_info/ -trop_map GMF -add_ocnld " -c /home/lfeng/gipsy/SuGAr/sta_info/ocnld_coeffs" -OcnldCpn';
%------------- used -------------
gd2pStr1 = [ '-type s -orb_clk flinnR_nf -amb_res 2 -stacov -sta_info /home/lfeng/gipsy/' network '/sta_info/ -AntCal /home/lfeng/gipsy/' network '/sta_info/' ];
gd2pStr2 = [ ' -trop_map VMF1GRID -vmf1dir /home/lfeng/gipsy/trops/VMF1GRID -add_ocnld " -c /home/lfeng/gipsy/' network '/sta_info/ocnld_coeffs" -OcnldCpn -tides WahrK1 PolTid FreqDepLove OctTid -trop_z_rw 5e-8 -wetzgrad 5e-9 -w_elmin 7 -post_wind 5e-3 5e-5 -pb_min_slip 10e-5' ];

%---------------------- antcal script ----------------------%
fprintf(fant,'#!/bin/bash\n');

% loop through sites
for ii = 1:siteNum
   site   = siteList{ii};
   lon    = locs(ii,1);
   lat    = locs(ii,2);
   height = locs(ii,3);
   [ xx,yy,zz ] = LL2XYZd(lat,lon,height);
   ind = strcmp(site,stainfo.name);
   if any(ind)
      recNum = sum(ind);
      period = stainfo.time(ind,:);
      antenn = stainfo.ant(ind,:);
      radome = stainfo.dom(ind,:);
      if recNum>1
         [period,periodInd] = sortrows(period,-1);
	 antenn             = antenn(periodInd);
	 radome             = radome(periodInd);
      end
      startY    = num2str(period(end,1),'%8d');
      startyear = startY(1:4);
      startmm   = startY(5:6);
      startdd   = startY(7:8);

      fprintf(1,'processing %s\n',site);
      %---------------------- sta_id ----------------------%
      fprintf(fid,' %4s     0 %4s\n',site,site);

      %---------------------- sta_pos ----------------------%
      fprintf(fpos,' %4s %4s %2s %2s 00:00:00.00 1000001.00 %15.4f %14.4f %14.4f  0.00000000e+00 0.00000000e+00 0.00000000e+00\n',...
              site,startyear,startmm,startdd,xx,yy,zz);

      %---------------------- ocnld_coeffs input ----------------------%
      fprintf(focn,'%-24s %16.4f%16.4f%16.4f\n',site,xx,yy,zz);

      for jj=1:recNum
         startyrStr = num2str(period(jj,1),'%8d');
	 startyr    = startyrStr(1:4);
	 startmm    = startyrStr(5:6);
	 startdd    = startyrStr(7:8);
	 startyrStr = [ startyr '-' startmm '-' startdd ];
	 if period(jj,2)==99999999
             endyrStr = endDStr;
	     secs = sec30yrs;
	 else
	     endyrStr = num2str(period(jj,2),'%8d');
	     endyrStr = [ endyrStr(1:4) '-' endyrStr(5:6) '-' endyrStr(7:8) ];
	     secs = sec1day*(datenum(endyrStr)-datenum(startyrStr));
	 end

         ant = antenn{jj};
	 dom = radome{jj};
         if strcmp(ant,'ASH700228A'),     antcode = '700228A'; end
         if strcmp(ant,'ASH700936A_M'),   antcode = '700936A_M'; end
         if strcmp(ant,'ASH701945B_M'),   antcode = '701945B_M'; end
         if strcmp(ant,'ASH701945E_M'),   antcode = '701945E_M'; end
         if strcmp(ant,'TRM14532.00'),    antcode = 'TRM14532.'; end
         if strcmp(ant,'TRM23903.00'),    antcode = 'TRM23903.'; end
         if strcmp(ant,'TRM29659.00'),    antcode = 'TRM29659.'; end
         if strcmp(ant,'TRM41249.00'),    antcode = 'TRM41249.'; end
         if strcmp(ant,'TRM57971.00'),    antcode = 'TRM57971.'; end
         if strcmp(ant,'TRM59800.80'),    antcode = 'TRM59800.'; end  % There are TRM59800.80 & TRM59800.00, almost the same
         if strcmp(ant,'TRM22020.00+GP'), antcode = 'TRM22020.'; end
         if strcmp(ant,'TPSCR.G5'),       antcode = 'TPSCR.G5';  end

         xyzfile = [ site '_' ant '.xyz' ];
         %---------------------- antcal script ----------------------%
         fprintf(fant,'antex2xyz.py -antexfile igs08.atx -anttype %-20s -radcode %s -recname %s -fel 0 -del 5 -daz 5 -extrap -xyzfile %s\n',...
	         ant,dom,site,xyzfile);

         %---------------------- run_gd2p input ----------------------%
         fprintf(fgd2p,'%s %s %s %s %s%s%s\n',network,site,startyrStr,endyrStr,gd2pStr1,xyzfile,gd2pStr2);

         %---------------------- sta_svec ----------------------%
         fprintf(fvec,' %4s %4s %4s %2s %2s 00:00:00.00 %012.2f %-9s %11.4f %10.4f %10.4f %10.4f l\n',...
                 site,site,startyr,startmm,startdd,secs,antcode,0,0,0,antH);
      end
   else
      fprintf(1,'not processing %s\n',site);
   end
end

fclose(fid); fclose(fpos); fclose(fvec); fclose(focn); fclose(fgd2p); fclose(fant);
