function [ ] = GPS_rneu2rate(fsitesName,frneuName,period,feulerin_name,subplot_var)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           	  GPS_rneu2rate.m				        % 
% linear fitting long-term trend through SITE.rneu data					%
% outliers are removed via two steps							%
%											%	
% INPUT: 										%
% (1) fsitesName - site location file							%
% 1      2      3     4 								%
% Site	 Lon	Lat   Height								%
%											%
% (2) frneuName - *.rneu all in [m]							%
% 1        2         3     4    5    6     7     8                                      %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                                  %
% Note: frneuName examples								%
% 'ACOS.rneu' or 'B*.rneu' Do not use ? in frneuName					%
% If frneuName = '', run this script for all *.rneu files in the current dir  		%
%											%
% (3) period - time period used 							%
% period = [ sta end ] in [decimal year]						%
% if period = [], all available data will be used					%
%											%
% (4) feulerin_name - a file storing an euler pole					%
% Two formats are supported								%
% a. euler pole without covariance							%
%    euler = [ pole_lat pole_lon omega ]					  	%		
%    omega - angular velocity [deg/Myr]							%
%    eg. CA-IGSb00 [ 37.6 -99.3 0.247 ] from Lopez_etal_GRL_2006 			%
%											%
% b. euler pole with covariance (5x3 matrix)						%
%    euler = [ pole_lat pole_lon omega ]     [deg/Myr]	       Note: Units different	%
%            [   Cxx     Cxy     Cxz   ] 						%
%      Cw  = [   Cyx     Cyy     Cyz   ]     [rad^2/Myr^2]                           	%
%            [   Czx     Czy     Czz   ]                                           	%
%    Trans = [   Tx	 Ty	 Tz    ]     [mm/yr]					%
%    Cw is the covariance matrix for angular velocity in xyz cartesian coordinate  	%
%        x - direction of (0N,0E) Greenwich						%
%        y - direction of (0N,90E)							%
%        z - direction of 90N								%
%        Cxx, Cyy, Czz - varicance  [rad^2/Myr^2]					%
%        Cxy, Cxz, Cyz - covariance [rad^2/Myr^2]					%
%    The ITRF geocentre CM (mass center including atmosphere, oceans, and ice sheets) 	%
%    is translating relative to the solid Earth centre CE                               %
% if feulerin_name = '', euler.vel will not be output					%
%											%
% (5) subplot_var - parameters for subplot						%
%                 = [ subplot_row subplot_col ] 					%	
% if subplot_var = [], do not do subplotting						%
%										        %
% OUTPUT: 									        %
% (1) *.vel for models								        %
%     1   2   3   4      5  6  7  8   9   10  11     12 13  14 15    16         	%
%     Sta Lon Lat Height VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D   Cne        	%
% Note: Cne is correlation coefficient between North and East uncertainties!		%
%											%
% (2) *.fitsum for fit summary							        %
%     1   2   3   4      5  6								%
%     Sta Lon Lat Height TT Days                                                        %
%     1   2     3  4   5     6     7    8                                               %
%     Sta North VN ErN w_amp f_amp wrms rchi2                                           %
%     1   2     3  4   5     6     7    8                                               %
%     Sta East  VE ErE w_amp f_amp wrms rchi2                                           %
%     1   2     3  4   5     6     7    8                                               %
%     Sta Up    VU ErU w_amp f_amp wrms rchi2                                           %
%											%
% (3) new rneu file after 								%
% a. removing outlies and 								%
% b. removing an euler motion if an euler pole is provided				%
% It does not change erros for each data point 						%
%											%
% (4) plots for individual sations 							%
% a. raw data with outliers and b. new rneu data with outliers                       	%
%											%
% (5) plots for all stations                                                            %
% a. raw data without outliers and b. new rneu data without outliers                    %
%											%
%										        %
% first created by lfeng Thu Oct 21 22:23:46 EDT 2010				        %
% considered error from euler vectors lfeng Thu Nov  4 02:24:21 EDT 2010		%
% corrected a bug with site name like "BALL" lfeng Mon Nov  8 15:36:44 EST 2010		%
% * could be used in frneuName								%
% incorporated covariance propagation lfeng Mon Feb 28 16:56:05 EST 2011		%
% added the ITRF translation relative to centre-of-mass lfeng Thu Mar3 21:04:38 EST 2011%
% added fitsum and subplot lfeng Sat Mar  5 12:27:36 EST 2011				%
% corrected the wrong alphabetic order lfeng Sat Mar  5 22:46:46 EST 2011		%
% added saving new rneu lfeng Fri Apr  1 21:21:34 EDT 2011				%
% removed Ceu Cnu lfeng Sun Apr  3 20:34:00 EDT 2011					%
% used '' to imply all files instead of 'all.rneu' Wed Jul 27 02:23:18 SGT 2011		%
% changed figh to figh_all and fixed delete(figh) lfeng Mon Aug 22 19:48:22 SGT 2011	%
% changed GPS_cleanup lfeng Mon Aug 29 12:54:50 SGT 2011				%
% added reading fsiteName lfeng Tue Jan  3 04:27:11 SGT 2012				%
% last modified by lfeng Tue Jan  3 04:50:17 SGT 2012					%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------------------------------
% read site file to get site location info
if isempty(fsitesName)
   error('GPS_rneu2rate ERROR: please provide a *.sites for site information!');
else
   fprintf(1,'\n.......... reading %s ...........\n',fsitesName);
   [ siteList,locList ] = GPS_readsites(fsitesName);
   siteNum = size(locList,1);
end
   
%---------------------------------------------------------------------------------
% check period
if isempty(period) 
   period_name = '';
else
   period_name = [ '_' num2str(period(1)) '-' num2str(period(2)) ];
end
%---------------------------------------------------------------------------------
% for plotting sites together
if ~isempty(subplot_var)
   subplot_row = subplot_var(1); subplot_col = subplot_var(2); 
   subplot_num = subplot_row*subplot_col;
   subplot_x0 = 0.1;  subplot_y0 = 0.1; 
   subplot_dx = 0.05;  subplot_dy = 0.08;
   subplot_ww = (1-2*subplot_x0-(subplot_col-1)*subplot_dx)/subplot_col;
   subplot_hh = (1-2*subplot_y0-(subplot_row-1)*subplot_dy)/subplot_row;
   fig_num = 0;
   efig_num = 0;
end

%---------------------------------------------------------------------------------
% fit summary file
ffit_all_name = [ 'all' period_name '.fitsum' ];
ffit_all = fopen(ffit_all_name,'w');
fprintf(ffit_all,'# 1   2   3   4      5  6\n');
fprintf(ffit_all,'# Sta Lon Lat Height TT Days\n');
fprintf(ffit_all,'# 1   2     3  4   5     6     7    8\n');
fprintf(ffit_all,'# Sta North VN ErN w_amp f_amp wrms rchi2\n');
fprintf(ffit_all,'# 1   2     3  4   5     6     7    8\n');
fprintf(ffit_all,'# Sta East  VE ErE w_amp f_amp wrms rchi2\n');
fprintf(ffit_all,'# 1   2     3  4   5     6     7    8\n');
fprintf(ffit_all,'# Sta Up    VU ErU w_amp f_amp wrms rchi2\n');
fprintf(ffit_all,'# Height [m] TT [yrs] Rate & error [mm/yr] w_amp [mm] f_amp [mm/yr^0.25] wrms [mm]\n');
%---------------------------------------------------------------------------------
% velocity file relative to ITRF2005 (2010)
fout_all_name = [ 'all' period_name '.vel' ];
fout_all = fopen(fout_all_name,'w');
fprintf(fout_all,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
fprintf(fout_all,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
fprintf(fout_all,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
fprintf(fout_all,'# Cne is correlation coefficient between north and east uncertainties [unitless]\n');

% velocity file with an euler pole removed
euler = [];
if ~isempty(feulerin_name)
   [ euler ] = GPS_readeuler(feulerin_name);

   % prepare euler output
   pole_lat = euler(1,1); pole_lon = euler(1,2); omega = euler(1,3);
   feuler_name = [ 'euler' period_name '.vel' ]; 
   feuler = fopen(feuler_name,'w');
   fprintf(feuler,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
   fprintf(feuler,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
   fprintf(feuler,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
   fprintf(feuler,'# Cne is correlation coefficient between north and east uncertainties [unitless]\n');
   fprintf(feuler,'# Euler pole: Lat %6.2f Lon %6.2f Omega %8.3f [deg/Myr]\n',euler(1,:)');
   if isequal(size(euler),[5 3])
       Tx = euler(5,1); Ty = euler(5,2); Tz = euler(5,3);		% [mm/yr]
       fprintf(feuler,'# Covariance matrix: [deg^2/Myr^2]\n');
       fprintf(feuler,'# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n',euler(2:4,:)');
       fprintf(feuler,'# Translation: X = %6.2f Y = %6.2f Z = %6.2f  [mm/yr]\n',Tx,Ty,Tz);
   end
end
%---------------------------------------------------------------------------------

% do for all *.rneu files
if isempty(frneuName)
   all_name_struct = dir('*.rneu');	% not regexp \. here
else
   all_name_struct = dir(frneuName);	% * like linux system can be used in frneuName
end

fnum = length(all_name_struct);
if fnum==0  
   error('GPS_rneu2rate ERROR: no rneu files exist in the current directory satisfying input!'); 
end

for ii=1:fnum
   %fname = all_name_struct(ii).name;
   %site = strtok(fname,'.');	% noly works for names without "."
   %GD_name = strcat(site,'.GD');
   fname = all_name_struct(ii).name;
   site = '';
   for jj=1:siteNum
      siteNameStr = char(siteList(jj,:));		% convert from cell to character array
      if strfind(fname,siteNameStr)
         site = siteNameStr;
	 break
      end
   end
   if isempty(site)
      error('GPS_rneu2rate ERROR: site of %s is not in %s!',fname,fsitesName);
   end
   indSite = strcmpi(site,siteList);			% siteList is cell
   siteLoc = locList(indSite,1:3);
   lon0 = siteLoc(1); lat0 = siteLoc(2); hh0 = siteLoc(3);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n%s',site);
   fprintf(1,'\n.......... reading %s  ...........\n',fname);
   [ rneu ] = GPS_readrneu(fname,[],0.001);
   % select data needed for certain period
   if ~isempty(period)
      time = rneu(:,2); ind = [ find(time>=period(1)) ]; rneu = rneu(ind,:);
      time = rneu(:,2); ind = [ find(time<=period(2)) ]; rneu = rneu(ind,:);
      if isempty(rneu)  
         disp([fname ' does not have data between ' num2str(period(1)) ' and ' num2str(period(2))]); 
	 continue; 
      end
   end
   % convert from [m] to [mm] for velocity calculation
   rneu(:,3:8) = 1000*rneu(:,3:8);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% clean up data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n......... cleaning up time series .........\n');
   % remove outliers step 1
   [ ~,dflag ] = GPS_cleanup(rneu,3);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% fit data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n......... fitting time series .........\n');
   % remove more outliers while fitting (dflag modified while fitting) step 2
   [ x0,rate,rate_err,rchi2,wrms,w_amp,f_amp,num,TT,dflag ] = GPS_fitrneu_linear(rneu,dflag);

   %%%%%%%%%%%%%%%%%%%%% form covaricane matrix & correlation coefficient %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n......... calculating covariance matrix .........\n');
   [ covmat_data,cc_data ] = GPS_formcov(rneu,dflag,rate,rate_err);
   % note: only Cne - correlation coefficient between north and east noises used and output
  
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot individual site %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n......... plotting raw time series .........\n');
   plot_name = strcat(site,period_name,'.ps');
   GPS_plot3rates(site,x0,rate,rate_err,rchi2,wrms,w_amp,f_amp,num,TT,rneu,dflag,plot_name);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot all sites %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if ~isempty(subplot_var)
       % 1st site create a figure
       subplot_ind = mod(ii,subplot_num);
       if subplot_ind==1
           fig_num = fig_num + 1;
	   fig_name = [ 'all_sites_' num2str(fig_num) '.ps'];
           % create a figure without poping up the window
           figh_all = figure('Visible','off','PaperType','usletter');
       end
       % plot
       if subplot_ind==0, subplot_ind = subplot_num; end
       GPS_plot3rates_subplot(figh_all,subplot_row,subplot_col,subplot_x0,subplot_y0,subplot_ww,subplot_hh,subplot_dx,subplot_dy,subplot_ind,period,site,x0,rate,rneu,dflag);
       % last site save a figure
       if mod(ii,subplot_num)==0  
          print(figh_all,'-depsc',fig_name); 
	  delete(figh_all);		% only delete the figure pointed by figh_all; the variable figh_all still exists
	  figh_all = [];
       end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n......... saving results .........\n');
   ind = find(dflag); 			% exclude outliers
   sta_ind = ind(1); end_ind = ind(end);

   %%%%%%%%% save all.fitsum file %%%%%%%%%
   fprintf(ffit_all,'%4s %14.9f %14.9f %10.4f %10.4f %8d\n',site,lon0,lat0,hh0,TT,num);
   fprintf(ffit_all,'%4s North %8.2f %7.2f %8.3f %8.3f %10.3f %8.3f\n',site,rate(1),rate_err(1),w_amp(1),f_amp(1),wrms(1),rchi2(1));
   fprintf(ffit_all,'%4s East  %8.2f %7.2f %8.3f %8.3f %10.3f %8.3f\n',site,rate(2),rate_err(2),w_amp(2),f_amp(2),wrms(2),rchi2(2));
   fprintf(ffit_all,'%4s Up    %8.2f %7.2f %8.3f %8.3f %10.3f %8.3f\n\n',site,rate(3),rate_err(3),w_amp(3),f_amp(3),wrms(3),rchi2(3));

   %%%%%%%%% save individual site.vel file %%%%%%%%%
   fout_name = strcat(site,period_name,'.vel');
   fout = fopen(fout_name,'w');
   fprintf(fout,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
   fprintf(fout,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
   fprintf(fout,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
   fprintf(fout,'# Cne is correlation coefficient between north and east uncertainties [unitless]\n');
   fprintf(fout,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
           site,lon0,lat0,hh0,rate(2),rate(1),rate(3),rate_err(2),rate_err(1),rate_err(3),1.0,...
	   rneu(sta_ind,1),rneu(sta_ind,2),rneu(end_ind,1),rneu(end_ind,2),cc_data(1,2));
   fclose(fout);

   %%%%%%%%% save all.vel file %%%%%%%%%
   fprintf(fout_all,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
           site,lon0,lat0,hh0,rate(2),rate(1),rate(3),rate_err(2),rate_err(1),rate_err(3),1.0,...
	   rneu(sta_ind,1),rneu(sta_ind,2),rneu(end_ind,1),rneu(end_ind,2),cc_data(1,2));

   %%%%%%%%% save euler.vel file %%%%%%%%%
   % euler pole is given in a simple format; do not propagate covariance associated with the euler vector
   if isequal(size(euler),[1 3])
      fprintf(1,'\n......... simple euler pole .........\n');
      [ v_ns,v_ew,mov_v,mov_dir ] = Euler1(lat0,lon0,pole_lat,pole_lon,omega);
      rate(2) = rate(2)-v_ew; rate(1) = rate(1)-v_ns; 
      fprintf(feuler,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
              site,lon0,lat0,hh0,rate(2),rate(1),rate(3),rate_err(2),rate_err(1),rate_err(3),1.0,...
	      rneu(sta_ind,1),rneu(sta_ind,2),rneu(end_ind,1),rneu(end_ind,2),cc_data(1,2));
      %---------------------------------------------------------------------------------
      % create new rneu with euler pole removed
      t0 = rneu(1,2);	% the 1st record used as time origin
      rneu(:,3) = rneu(:,3)-(rneu(:,2)-t0)*v_ns;
      rneu(:,4) = rneu(:,4)-(rneu(:,2)-t0)*v_ew;
      x0(1) = x0(1)+t0*v_ns;
      x0(2) = x0(2)+t0*v_ew;
      %---------------------------------------------------------------------------------
      % plot individual site for new rneu
      fprintf(1,'\n......... plotting new time series .........\n');
      plot_name = strcat(site,period_name,'_euler.ps');
      GPS_plot3rates_clean(site,x0,rate,rate_err,num,TT,rneu,dflag,plot_name);

      %---------------------------------------------------------------------------------
      % plot all sites
      if ~isempty(subplot_var)
          % 1st site create a figure
          subplot_ind = mod(ii,subplot_num);
          if subplot_ind==1
              efig_num = efig_num + 1;
              efig_name = [ 'euler_sites_' num2str(efig_num) '.ps'];
              % create a figure without poping up the window
              efigh = figure('Visible','off','PaperType','usletter');
          end
          % plot
          if subplot_ind==0, subplot_ind = subplot_num; end
          GPS_plot3rates_subplot(efigh,subplot_row,subplot_col,subplot_x0,subplot_y0,subplot_ww,subplot_hh,subplot_dx,subplot_dy,subplot_ind,...
                                 period,site,x0,rate,rneu,dflag);
          % last site save a figure
          if mod(ii,subplot_num)==0  
             print(efigh,'-depsc',efig_name); 
             delete(efigh);	% only delete the figure pointed by figh; the variable figh still exists
	     efigh = [];
          end
      end
      %---------------------------------------------------------------------------------
      % save new rneu
      % convert back from [mm] to [m]
      rneu(:,3:8) = 1e-3*rneu(:,3:8);
      ind = find(dflag); rneu = rneu(ind,:);
      rneu_name = strcat(site,period_name,'_euler.rneu');
      fprintf(1,'\n.......... saving %s ...........\n',rneu_name);
      fout = fopen(rneu_name,'w');
      fprintf(fout,'# rneu converted from %s\n',fname);
      fprintf(fout,'# Euler pole: Lat %6.2f Lon %6.2f Omega %8.3f [deg/Myr]\n',euler(1,:)');
      fprintf(fout,'# 1        2         3     4    5    6     7     8\n# YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err  [m]\n');
      fprintf(fout,'%8d %14.6f %12.4f %12.4f %12.4f %12.4f %8.4f %8.4f\n',rneu');
      fclose(fout);
   end

   % euler pole is given in a full format; propagate covariance associated with the euler vector
   if isequal(size(euler),[5 3])
      fprintf(1,'\n......... full euler pole .........\n');
      %---------------------------------------------------------------------------------
      % calculate the plate motion from euler vector
      [ v_ns,v_ew,mov_v,mov_dir ] = GPS_euler2neu(lat0,lon0,hh0,pole_lat,pole_lon,omega);
      % convert translation from XYZ to NEU
      [ Tn,Te,Tu ] = XYZ2NEUd(lat0,lon0,Tx,Ty,Tz);
      % calculate new velocites
      ns = rate(1)-v_ns+Tn; ew = rate(2)-v_ew+Te; ud = rate(3)+Tu;
      %---------------------------------------------------------------------------------
      % calculate the covariance matrix from the angular velocity
      Cw = euler(2:4,1:3);	% covariance matrix for angular velocity
      [ covmat_euler ] = GPS_euler2neu_cov(lat0,lon0,hh0,Cw);	% height in [m]
      %[ v_err,dir_err ] = GPS_ne2mov_cov(v_ns,v_ew,covmat_euler);
      [ covmat,cc ] = GPS_neuneu_cov(covmat_data,covmat_euler);	% data - euler
      ns_err = sqrt(covmat(1,1));	ew_err = sqrt(covmat(2,2)); 	
      %---------------------------------------------------------------------------------
      fprintf(feuler,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
              site,lon0,lat0,hh0,ew,ns,ud,ew_err,ns_err,rate_err(3),1.0,...
	      rneu(sta_ind,1),rneu(sta_ind,2),rneu(end_ind,1),rneu(end_ind,2),cc(1,2));
      %---------------------------------------------------------------------------------
      % create new rneu with euler pole removed
      t0 = rneu(1,2);	% the 1st record used as time origin
      rneu(:,3) = rneu(:,3)-(rneu(:,2)-t0)*(v_ns-Tn);
      rneu(:,4) = rneu(:,4)-(rneu(:,2)-t0)*(v_ew-Te);
      rneu(:,5) = rneu(:,5)+(rneu(:,2)-t0)*Tu;
      x0(1) = x0(1)+t0*(v_ns-Tn);
      x0(2) = x0(2)+t0*(v_ew-Te);
      x0(3) = x0(3)-t0*Tu;
      %---------------------------------------------------------------------------------
      % plot individual site for new rneu
      fprintf(1,'\n......... plotting new time series .........\n');
      plot_name = strcat(site,period_name,'_euler.ps');
      rate = [ ns; ew; ud ]; rate_err = [ ns_err; ew_err; rate_err(3) ];
      GPS_plot3rates_clean(site,x0,rate,rate_err,num,TT,rneu,dflag,plot_name);

      %---------------------------------------------------------------------------------
      % plot all sites
      if ~isempty(subplot_var)
          % 1st site create a figure
          subplot_ind = mod(ii,subplot_num);
          if subplot_ind==1
              efig_num = efig_num + 1;
              efig_name = [ 'euler_sites_' num2str(efig_num) '.ps'];
              % create a figure without poping up the window
              efigh = figure('Visible','off','PaperType','usletter');
          end
          % plot
          if subplot_ind==0, subplot_ind = subplot_num; end
          GPS_plot3rates_subplot(efigh,subplot_row,subplot_col,subplot_x0,subplot_y0,subplot_ww,subplot_hh,subplot_dx,subplot_dy,subplot_ind,...
                                 period,site,x0,rate,rneu,dflag);
          % last site save a figure
          if mod(ii,subplot_num)==0  
             print(efigh,'-depsc',efig_name); 
             delete(efigh);	% only delete the figure pointed by figh; the variable figh still exists
	     efigh = [];
          end
      end
      %---------------------------------------------------------------------------------
      % save new rneu
      % convert back from [mm] to [m]
      rneu(:,3:8) = 1e-3*rneu(:,3:8);
      ind = find(dflag); rneu = rneu(ind,:);
      rneu_name = strcat(site,period_name,'_euler.rneu');
      fprintf(1,'\n.......... saving %s ...........\n',rneu_name);
      fout = fopen(rneu_name,'w');
      fprintf(fout,'# rneu converted from %s\n',fname);
      fprintf(fout,'# Euler pole: Lat %6.2f Lon %6.2f Omega %8.3f [deg/Myr]\n',euler(1,:)');
      % full euler only
      Tx = euler(5,1); Ty = euler(5,2); Tz = euler(5,3);		% [mm/yr]
      fprintf(fout,'# Covariance matrix: [deg^2/Myr^2]\n');
      fprintf(fout,'# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n',euler(2:4,:)');
      fprintf(fout,'# Translation: X = %6.2f Y = %6.2f Z = %6.2f  [mm/yr]\n',Tx,Ty,Tz);
      % rneu format
      fprintf(fout,'# 1        2         3     4    5    6     7     8\n# YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err  [m]\n');
      fprintf(fout,'%8d %14.6f %12.4f %12.4f %12.4f %12.4f %8.4f %8.4f\n',rneu');
      fclose(fout);
   end
end
fclose(fout_all); fclose(ffit_all);
% in case not enough sites to fill one page
if ~isempty(subplot_var) && ~isempty(figh_all)
   print(figh_all,'-depsc',fig_name); 
   delete(figh_all);
end
if ~isempty(subplot_var) && ~isempty(efigh) && ~isempty(euler)
   print(efigh,'-depsc',efig_name); 
   delete(efigh);
end
if ~isempty(feulerin_name), fclose(feuler); end;
