function [ ] = GPS_rneu(rneuName1,scaleIn1,oper,var2,scaleIn2,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     GPS_rneu.m				        % 
% manipulate *.rneu files								%
%											%	
% INPUT: 										%
% (1) *.rneu                           							%
% 1        2         3     4    5    6     7     8                              	%
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          	%
%											%
% scaleIn1 & scaleIn2 - scale to meter in input fileName                                %
%    if scaleIn = [], an optimal unit will be determined                                %
% scaleOut - scale to meter in output rneu                                              %
%    if scaleOut = [], units won't be changed                                           %
%											%
% (2) oper - operator									%
%    '-':     1.rneu - 2.rneu; not coded yet						%
%        var2 = frneu2_name								%
%											%
%    '+':     1.rneu + 2.rneu not coded yet						%
%        var2 = frneu2_name								%
%										 	%	
%    'h/v':  horizontal/vertical							%
%        var2 = the date when to start calculating displacements			%
%											%
%    'offset': remove offsets from 1.rneu						%
%        var2 = foffset_name that provides offset information				%
%        temporary format is 								%
%        1			2	3						%
%        Offset Date	File    Scale factor						%
%											%
%    'euler': 1.rneu - euler vector remove an euler vector from 1.rneu			%
%        var2 = *.euler (a file storing euler pole info)				%
%     a. simple angular velocity, ignore the errors					%
%        euler = [ pole_lat pole_lon omega ]						%
%        omega - angular velocity [degree/Myr]						%
%        e.g. CA-IGSb00 [ 37.6 -99.3 0.247 0.008 ] from Lopez_etal_GRL_2006 		%
%											%
%     b. full angular velocity, consider the full cartesian covariance matrix		%
%        euler = [ pole_lat pole_lon omega ]     [deg/Myr]	 Note: Units different	%
%                [   Cxx     Cxy     Cxz   ] 						%
%          Cw  = [   Cyx     Cyy     Cyz   ]     [rad^2/Myr^2]                         	%
%                [   Czx     Czy     Czz   ]                                           	%
%        Trans = [   Tx	     Ty	     Tz    ]     [mm/yr]				%
%    Cw is the covariance matrix for angular velocity in xyz cartesian coordinate  	%
%        x - direction of (0N,0E) Greenwich						%
%        y - direction of (0N,90E)							%
%        z - direction of 90N								%
%        Cxx, Cyy, Czz - varicance  [rad^2/Myr^2]					%
%        Cxy, Cxz, Cyz - covariance [rad^2/Myr^2]					%
%    The ITRF geocentre CM (mass center including atmosphere, oceans, and ice sheets) 	%
%    is translating relative to the solid Earth centre CE                               %
%											%
%    'strike': project 1.rneu to along strike & normal to strike			%
%        var2 = strike									%
%        e.g. GPS_rneu('NIC_ca_1996-2004.vel','strike',135)				%
%											%
%    'mm2m': convert 1.rneu from mm to m; ignore var2 input				%
%        e.g. GPS_rneu('NIC_ca_1996-2011_str135_normal.vel','mm2m',0)			%
%											%
% OUTPUT: a new *.rneu file that contains the results					%
%										        %
% first created by Lujia Feng Wed Jul 13 18:53:39 SGT 2011				%
% coded '-', '+' & 'offset' lfeng Tue Nov 29 14:24:13 SGT 2011				%
% added scaleIn & scaleOut lfeng Sat May 30 13:54:01 SGT 2015                           %
% last modified by Lujia Feng Sat May 30 13:58:36 SGT 2015                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the 1st file
fprintf(1,'\n.......... reading %s  ...........\n',rneuName1);
[ rneu1 ] = GPS_readrneu(rneuName1,scaleIn1,scaleOut);
% format check
fnum = size(rneu1,2);
if fnum~=8, error('GPS_rneu ERROR: %s does not have the right format!',rneuName1); end

switch oper
   case 'h/v'	
      % use one day before EQ as reference
      fprintf(1,'\n calculating N/V E/V H/V\n');
      ind0 = find(rneu1(:,1)==var2);
      north = rneu1(:,3)-rneu1(ind0,3); northErr = rneu1(:,6); 	      
      east  = rneu1(:,4)-rneu1(ind0,4); eastErr  = rneu1(:,7); 	     
      vert  = rneu1(:,5)-rneu1(ind0,5); vertErr  = rneu1(:,8);
      horiz = (north.^2+east.^2).^0.5;
      horizErr = ((north.^2).*(northErr.^2)./(horiz.^2)+(east.^2).*(eastErr.^2)./(horiz.^2)).^0.5;
      % north, east, and horizontal components devided by vertical
      rneu1(:,3) = north; rneu1(:,4) = east; rneu1(:,5) = horiz;
      rneu1(:,3:5) = bsxfun(@rdivide,rneu1(:,3:5),vert);
      % division error calculation
      rneu1(:,6) = abs(rneu1(:,3)).*((northErr./north).^2+(vertErr./vert).^2).^0.5;
      rneu1(:,7) = abs(rneu1(:,4)).*((eastErr./east).^2+(vertErr./vert).^2).^0.5;
      rneu1(:,8) = abs(rneu1(:,5)).*((horizErr./horiz).^2+(vertErr./vert).^2).^0.5;
      % write output
      v1 = strtok(rneu1Name1,'.'); 	% noly works for names without "."
      foutName = [ v1 '_h2v.rneu' ];
      fout = fopen(foutName,'w');
      if ~isempty(scaleOut)
          fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
      end
      fprintf(fout,'# 1        2         3     4    5    6     7     8\n');
      fprintf(fout,'# YEARMODY YEAR.DCML N/V   E/V  H/V  N_err E_err V_err\n');
      fprintf(fout,'%8.0f %14.6f %12.5f %12.5f %12.5f %12.5f %8.5f %8.5f\n',rneu1'); 
      fclose(fout);

   case '-'
      [ ~,v1,~ ] = fileparts(rneuName1); [ ~,v2,~ ] = fileparts(var2);
      % read in the 2nd rneu file
      fprintf(1,'\n.......... reading %s  ...........\n',var2);
      [ rneu2 ] = GPS_readrneu(var2,scaleIn2,scaleOut);
      fnum = size(rneu2,2);
      if fnum~=8, error('GPS_rneu ERROR: %s does not have the right format!',var2); end
      % find dates of the 2nd file in the 1st one
      [ ~,dayInd ] = ismember(rneu2(:,1),rneu1(:,1));
      keepInd = dayInd>0;
      rneu2 = rneu2(keepInd,:);
      [ ~,dayInd ] = ismember(rneu2(:,1),rneu1(:,1));
      % substract
      rneu1(dayInd,3) = rneu1(dayInd,3) - rneu2(:,3);
      rneu1(dayInd,4) = rneu1(dayInd,4) - rneu2(:,4);
      rneu1(dayInd,5) = rneu1(dayInd,5) - rneu2(:,5);
      %% remove mean
      %rneu1(dayInd,3) = rneu1(dayInd,3) - mean(rneu1(dayInd,3));
      %rneu1(dayInd,4) = rneu1(dayInd,4) - mean(rneu1(dayInd,4));
      %rneu1(dayInd,5) = rneu1(dayInd,5) - mean(rneu1(dayInd,5));
      dayInd = sort(dayInd);
      rneu = rneu1(dayInd,:);
      % write output
      foutName = [ v1 oper v2 '.rneu' ];
      fout = fopen(foutName,'w');
      fprintf(fout,'# %s - %s\n',rneuName1,var2);
      if ~isempty(scaleOut)
          fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
      end
      fprintf(fout,'# 1        2         3     4    5    6     7     8\n');
      fprintf(fout,'# YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err\n');
      fprintf(fout,'%8.0f %14.6f %12.5f %12.5f %12.5f %12.5f %8.5f %8.5f\n',rneu');
      fclose(fout);

   case '+'
      [ ~,v1,~ ] = fileparts(rneuName1); [ ~,v2,~ ] = fileparts(var2);
      % read in the 2nd rneu file
      fprintf(1,'\n.......... reading %s  ...........\n',var2);
      [ rneu2 ] = GPS_readrneu(var2,scaleIn2,scaleOut);
      fnum = size(rneu2,2);
      if fnum~=8, error('GPS_rneu ERROR: %s does not have the right format!',var2); end
      % find dates of the 2nd file in the 1st one
      [ ~,dayInd ] = ismember(rneu2(:,1),rneu1(:,1));
      keepInd = dayInd>0;
      rneu2 = rneu2(keepInd,:);
      [ ~,dayInd ] = ismember(rneu2(:,1),rneu1(:,1));
      % add up
      rneu1(dayInd,3) = rneu1(dayInd,3) - rneu2(:,3);
      rneu1(dayInd,4) = rneu1(dayInd,4) - rneu2(:,4);
      rneu1(dayInd,5) = rneu1(dayInd,5) - rneu2(:,5);
      dayInd = sort(dayInd);
      rneu = rneu1(dayInd,:);
      % write output
      foutName = [ v1 oper v2 '.rneu' ];
      fout = fopen(foutName,'w');
      fprintf(fout,'# %s + %s\n',rneuName1,var2);
      if ~isempty(scaleOut)
          fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
      end
      fprintf(fout,'# 1        2         3     4    5    6     7     8\n');
      fprintf(fout,'# YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err\n');
      fprintf(fout,'%8.0f %14.6f %12.5f %12.5f %12.5f %12.5f %8.5f %8.5f\n',rneu');
      fclose(fout);

   case 'offset' % limited to one offset only
         [ ~,v1,~ ] = fileparts(rneuName1); 
	 site = v1(4:7);
         fin = fopen(var2,'r');
         % currently only one line is allowed in the offset file
         offsetCell = textscan(fin,'%f %s %f','CommentStyle','#');
         eqYMD = offsetCell{1}; foffsetName = char(offsetCell{2}); offsetScale = offsetCell{3};
         fclose(fin);
	 fprintf(1,'\n.......... reading %s  ...........\n',var2);
         [ offsetSitelist,vel ] = GPS_readvel(foffsetName);		% E N U
         % remove offset for earthquakes
         siteInd = strcmpi(site,offsetSitelist);
         if any(siteInd > 0.5)
            % cm to m, scale back to 70%
            offsetE = vel(siteInd,4)*1e-2/offsetScale; 
            offsetN = vel(siteInd,5)*1e-2/offsetScale; 
            offsetU = vel(siteInd,6)*1e-2/offsetScale; 
            rneuInd = rneu1(:,1)>eqYMD;
            rneu1(rneuInd,3) = rneu1(rneuInd,3)-offsetN;
            rneu1(rneuInd,4) = rneu1(rneuInd,4)-offsetE;
            rneu1(rneuInd,5) = rneu1(rneuInd,5)-offsetU;
            foutName = [ v1 '_offset.rneu' ];
            GPS_saverneu(foutName,'w',rneu1,scaleOut);
         else   
            fprintf(1,'GPS_rneu WARNING: %s have no offset to remove!\n',rneuName1);
         end

   case 'euler'
      siteName = '~lfeng/SMT/SMT_GPS/sites/SMT_IGS.sites';
      GPS_rneu_euler(rneuName1,siteName,var2);
      
   case 'eulerproj'
      siteName = '~lfeng/SMT/SMT_GPS/sites/SMT_IGS.sites';
      GPS_rneu_eulerproj(rneuName1,siteName,var2,str);
      
   case 'strike'
      GPS_rneu_project(rneuName1,var2);
end
