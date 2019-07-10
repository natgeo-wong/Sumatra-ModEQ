function [ ] = GPS_rneu2postseismic(frneuName,Deq,comps,ext)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      GPS_rneu2postseismic.m                        % 
% Convert rneu format to RELAX postseismic format                    %
% Earthquake time is 0                                               %
% It contains the postseismic component only.                        %
% Input file names can be mb_SITE_GPS.rneu or SITE_*.rneu            %
%--------------------------------------------------------------------%
% The format of *.rneu is [m]                                        %
% 1        2         3     4    5    6     7     8                   %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err               %
%--------------------------------------------------------------------%
% The format of RELAX SITE.txt file is [m]                           %
% 1         2     3    4    5     6     7                            %
% YEAR.DCML NORTH EAST VERT N_err E_err V_err                        %
%--------------------------------------------------------------------%
% INPUT:                                                             %
% frneuName - *.rneu                                                 %
%           = [  north east up ]                                     %
% Deq       - earthquake YEARMODY                                    %
% comps     - components                                             %
%     'enu' = [  east north up ]                                     %
%     'en'  = [  east north 0  ]                                     %
%     'Enu' = [ -east north up ]                                     %
%     ''    = no change                                              %
% ext       - extension for output files e.g. '.txt' or ''           %
%                                                                    %
% OUTPUT:                                                            %
% a SITEext file                                                     %
%                                                                    %
% old name GPS_rneu2relax.m                                          %
% first created by Lujia Feng Wed Oct 17 15:26:38 SGT 2012           %
% postseismic starts from 0 lfeng Thu Oct 18 16:47:23 SGT 2012       %
% added multiple files processing lfeng Mon May 20 14:11:29 SGT 2013 %
% added comps for different formats lfeng Thu Oct 3 10:47:29 SGT 2013%
% added ext lfeng Thu Oct  3 10:50:13 SGT 2013                       %
% added fmodel for errors lfeng Fri Dec  4 11:26:04 SGT 2015         %
% removed base error models lfeng Thu Apr  7 14:40:20 SGT 2016       %
% last modified by Lujia Feng Thu Apr  7 14:40:27 SGT 2016           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(frneuName)
   error('GPS_rneu2postseismic ERROR: specify rneu files to be converted to RELAX format!'); 
else
   nameStruct = dir(frneuName);      % * like linux system can be used in frneuName
end

fnum = length(nameStruct);
if fnum==0  
   error('GPS_rneu2postseismic ERROR: no rneu files exist in the current directory satisfying input!'); 
end

mbflag  = '^mb_[A-Za-z0-9]{4}_GPS.rneu$';
fitflag = '^[A-Za-z0-9]{4}_';
for ii=1:fnum
   fname = nameStruct(ii).name;
   % find site name 
   ismb  = regexp(fname,mbflag,'match');
   isfit = regexp(fname,fitflag,'match'); 
   if ~isempty(ismb)
      site = fname(4:7);
      foutName = [ site ext ];
   elseif ~isempty(isfit)
      site = fname(1:4);
      foutName = [ site ext ];
   else    
      error('GPS_rneu2postseismic ERROR: input rneu files are not recognized!');
   end
   % read in data
   fprintf(1,'\n.......... reading %s ...........\n',fname);
   [ rneu ] = GPS_readrneu(fname,1,1);
   % read in model prediciton with errors
   [ ~,basename,~ ] = fileparts(fname);
   fmodel = [ basename '_2model.rneu' ];
   if exist(fmodel,'file')
      [ rneuMod ] = GPS_readrneu(fmodel,1,1);
   else
      rneuMod = [];
   end

   % time reference to EQ 
   indEQ = rneu(:,1)==Deq;
   if any(indEQ)
      Teq = rneu(indEQ,2);
   else
      [ ~,~,Teq ] = GPS_YEARMMDDtoDCMLYEAR(Deq);
   end
   indEQ = rneu(:,2)>=Teq;
   ymd   = rneu(indEQ,1);
   time  = rneu(indEQ,2) - Teq;
   nn    = rneu(indEQ,3); nnErr = rneu(indEQ,6);
   ee    = rneu(indEQ,4); eeErr = rneu(indEQ,7);
   uu    = rneu(indEQ,5); uuErr = rneu(indEQ,8);

   % error propagated from models
   if ~isempty(rneuMod)
      for kk=1:length(ymd)
          ind       = rneuMod(:,1)==ymd(kk);
	  nnErr(kk) = rneuMod(ind,6);
	  eeErr(kk) = rneuMod(ind,7);
	  uuErr(kk) = rneuMod(ind,8);
      end
   end

   if time(1)~=0
      time = [ 0; time ];
      nn   = [ 0; nn ]; nnErr = [ 0; nnErr ];
      ee   = [ 0; ee ]; eeErr = [ 0; eeErr ];
      uu   = [ 0; uu ]; uuErr = [ 0; uuErr ];
   else
      nn(1) = 0; ee(1) = 0; uu(1) = 0;
   end

   % form output according to comps
   out = zeros(length(time),7);
   if isempty(comps)
      out = [ time nn ee -uu nnErr eeErr uuErr ];
   else
      out(:,1) = time;
      % east
      ind = strfind(comps,'e'); 
      if ~isempty(ind) 
         out(:,[ 1+ind 4+ind ]) = [  ee eeErr ];
      end
      ind = strfind(comps,'E'); 
      if ~isempty(ind) 
         out(:,[ 1+ind 4+ind ]) = [ -ee eeErr ];
      end
      % north
      ind = strfind(comps,'n'); 
      if ~isempty(ind) 
         out(:,[ 1+ind 4+ind ]) = [  nn nnErr ];
      end
      ind = strfind(comps,'N'); 
      if ~isempty(ind) 
         out(:,[ 1+ind 4+ind ]) = [ -nn nnErr ];
      end
      % up
      ind = strfind(comps,'u'); 
      if ~isempty(ind) 
         out(:,[ 1+ind 4+ind ]) = [ uu uuErr ];
      end
      ind = strfind(comps,'U'); 
      if ~isempty(ind) 
         out(:,[ 1+ind 4+ind ]) = [ -uu uuErr ];
      end
   end

   % save time series files
   fout = fopen(foutName,'w');
   if ~exist(foutName,'file')
      error('GPS_rneu2postseismic ERROR: %s does not exist!',foutName);
   end
   fprintf(fout,'# converted from %s using GPS_rneu2postseismic.m by Lujia FENG\n',fname);
   if isempty(comps)
      fprintf(fout,'# time(yr) north(m) east(m) down(m) n_err(m) e_err(m) d_err(m)\n');
   else
      fprintf(fout,'# time(yr) %s (m) %s_err (m)\n',comps,comps);
   end
   fprintf(fout,'%10.6f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',out');
   fclose(fout);
end
