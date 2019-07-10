function [ ] = GPS_extract_GPSfitsum(fileName,scaleOut,dateList)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        GPS_extract_GPSfitsum.m                            %
% Extract EQ info from *.fitsum & *.eqs                                     %
%                                                                           %
% INPUT:                                                                    %
% fileName - *.files                                                        %
% 1    2             3               4                 5                    %
% Site Site_Loc_File Data_File       Fit_Param_File    EQ_File              %
% ABGS SMT_IGS.sites ABGS_clean.rneu ABGS_clean.fitsum ABGS.siteqs          %
% BTET SMT_IGS.sites BTET_clean.rneu BTET_clean.fitsum BTET.siteeqs         %
% 6                                                                         %
% Noise_File                                                                %
% ABGS_res1site.noisum                                                      %
% BTET_res1site.noisum                                                      %
% file order can be different!                                              %
%                                                                           %
% scaleOut - scale to meter in output rate & dist files                     %
%    scaleOut cannot be []                                                  %
% dateList - a list of dates for outputting postseismic deformation         %
%    e.g. [20131231 20151025]                                               %
%                                                                           %
% OUTPUT:                                                                   %
% (1) one interseismic velocity file for all sites                          %
% (2) one distance and displacement file for all EQ-station pairs           %
% (3) offset files for each recorded EQ                                     %
% (4) postseismic files for each recorded EQ                                %
% (5) fitsum files for each recorded EQ                                     %
%                                                                           %
% first created by Lujia Feng Sat Aug  4 16:02:49 SGT 2012                  %
% changed GPS_readrneu.m lfeng Tue Oct 23 18:36:27 SGT 2012                 %
% changed funcMat lfeng Thu Apr  4 10:56:32 SGT 2013                        %
% added tau to dist file lfeng Wed May 15 06:29:40 SGT 2013                 %
% added fitsum output for each EQ lfeng Mon Jan 27 12:05:29 SGT 2014        %
% modified for lg2 & ep2 lfeng Thu Mar  6 13:09:12 SGT 2014                 %
% added rneuList & postseismic lfeng Mon Mar 17 09:33:27 SGT 2014           %
% saved velocity after each earthquake lfeng Thu Mar 27 10:55:53 SGT 2014   %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                  %
% added fpoDate lfeng Wed Jul  9 17:43:29 SGT 2014                          %
% added fpo2 & changed file output lfeng Sat Jul 12 16:34:53 SGT 2014       %
% changed po2013 to poDend Fri Jun  5 19:49:38 SGT 2015                     %
% added errors to postseismic vel files lfeng Thu Sep  3 10:19:09 SGT 2015  %
% added infoMat check lfeng Fri Mar 18 15:48:43 SGT 2016                    %
% added dateList lfeng Wed Mar 30 11:37:59 SGT 2016                         %
% removed Errbase for errors of postseismic disps lfeng Wed Apr  6 SGT 2016 %
% eqinfoMat isscalar is the sign that no EQs lfeng Apr 7 11:54:03 SGT 2016  %
% added eqMat empty check lfeng Thu Apr  7 11:59:52 SGT 2016                %
% last modified by Lujia Feng Thu Apr  7 12:00:00 SGT 2016                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... reading %s ...........\n',fileName);
[ siteList,locfList,datfList,fitfList,eqsfList,~ ] = GPS_readfiles(fileName);
siteNum = size(siteList,1);

fprintf(1,'\n.......... reading individual sites ...........\n\n');
% matrix
locMat  = [];
infoMat = [];
% cell
eqList     = {}; % Deq Teq
funcList   = {};
paramList  = {};
rateList   = {};
eqinfoList = {};
rneuList   = {};

for ii=1:siteNum
    site = siteList{ii};
    fprintf(1,'reading %s\n',site);
    %------------ read location ------------
    name = locfList{ii};
    if strcmpi(name,'none')  % 'none' - no files attached
        error('GPS_extract_GPSfitsum ERROR: %s''s location file must exist!',site);
    else
        [ sites,locs ] = GPS_readsites(name);        
        ind = strcmpi(site,sites);
        loc = locs(ind,1:3);
        locMat = [ locMat; loc ];
    end
    %--------------------- read rneu ---------------------%
    fname = datfList{ii};
    if strcmpi(name,'none')  % 'none' - no files attached
        error('GPS_extract_GPSfitsum ERROR: %s''s rneu file must exist!',site);
    else
        [ rneu ] = GPS_readrneu(fname,1,1);
        rneuList = [ rneuList; rneu ];
    end
    %------------ read fit parameters ------------
    name = fitfList{ii};
    if strcmpi(name,'none')
        error('GPS_extract_GPSfitsum ERROR: %s''s fitsum file must exist!',site);
    else
        [ fitsum ] = GPS_readfitsum(name,site,scaleOut);
        % assign 0 to be used as a placeholder for cell list
	if isempty(fitsum.eqMat)
           eqMat = 0;
	else
	   eqMat = fitsum.eqMat;
	end
	if isempty(fitsum.funcMat)
           funcMat = 0;
	else
	   funcMat = fitsum.funcMat;
	end
	if isempty(fitsum.paramMat)
           paramMat = 0;
	else
	   paramMat = fitsum.paramMat;
	end
        % all parameters
        rateList   = [ rateList;  fitsum.rateRow ];
        eqList     = [ eqList;    eqMat ];
        funcList   = [ funcList;  funcMat ];
        paramList  = [ paramList; paramMat ];
    end
    %------------ read eqs ------------
    name = eqsfList{ii};
    if strcmpi(name,'none')
        error('GPS_extract_GPSfitsum ERROR: %s''s eqs file must exist!',site);
    else
	[ ~,eqinfoMat,~ ] = EQS_readsiteqs(name);
        if isempty(eqinfoMat)
            eqinfoMat = 0; % assign 0 to be used as a placeholder for cell list
        else
            infoMat = [ infoMat; eqinfoMat(:,1:12) ];
            %------------ campare eqinfo & fit parameters ------------
            ymd   = eqinfoMat(:,1)*1e4+eqinfoMat(:,2)*1e2+eqinfoMat(:,3);
	    uqMat = unique(eqMat,'rows','stable');
	    num1  = size(uqMat,1); 
	    num2  = size(eqinfoMat,1);
            if num1 ~= num2
	        diff = num1 - num2;
                fprintf(1,'GPS_extract_GPSfitsum WARNING: %s fitsum - eqs = %.0f - %.0f = %.0f!\n',site,num1,num2,diff);
            elseif uqMat(:,1)~=ymd
                error('GPS_extract_GPSfitsum ERROR: %s''s fitsum & eqs files have different EQs!',site);
            end
            ind = uqMat(:,2)<rneu(1,2) | uqMat(:,2)>rneu(end,2);
	    if any(ind)
                fprintf(1,'%s indirectly recorded %d EQ(s): ',site,sum(ind));
                fprintf(1,'%-12.0f',uqMat(ind,1));
                fprintf(1,'\n');
	    end
        end        
        eqinfoList = [ eqinfoList; eqinfoMat ];
    end
end

%%%%%%%%%%%%%%%% save velocities %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... saving velocities ...........\n');
[ ~,basename,~ ] = fileparts(fileName);
fvelName = [ basename '.vel' ];
fout = fopen(fvelName,'w');
fprintf(fout,'# Rates extracted from fitsum files by GPS_extract_GPSfitsum.m\n');
fprintf(fout,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
fprintf(fout,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
fprintf(fout,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
for ii=1:siteNum
    site    = siteList{ii};
    loc     = locMat(ii,:);
    rateRow = rateList{ii}; 
    enu     = rateRow([6 4 8]); 
    err     = rateRow([12 10 14]) ; 
    wgt     = 1.0;
    T1      = rateRow(1,1); 
    T2      = rateRow(1,2);
    [ D1,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(T1);
    [ D2,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(T2);
    fprintf(fout,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
            site,loc,enu,err,wgt,D1,T1,D2,T2,0.0);
end
fclose(fout);

%%%%%%%%%%%%%%%% save earthquakes %%%%%%%%%%%%%%%%
if isempty(infoMat)
   fprintf(1,'\n.......... no earthquakes ...........\n\n');
   return
else
   fprintf(1,'\n.......... saving earthquakes ...........\n\n');
end
eqidMat = infoMat(:,11);
[ eqidMat,ind,~ ] = unique(eqidMat);   % sorted
infoMat = infoMat(ind,:);
uqNum   = size(eqidMat,1);
fdisName = [ basename '.dist' ];
fdis = fopen(fdisName,'w');
fprintf(fdis,'# EQ info extracted from GPS_extract_GPSfitsum.m\n');
fprintf(fdis,'# 1  2     3   4   5     6   7    8   9   10   11    12    13   14    15   16    17   18    19\n');
fprintf(fdis,'# ID Decyr Lon Lat Depth Mag Site Lon Lat Elev Hdisp Vdisp Dist Ntype Ntau Etype Etau Utype Utau\n');
fprintf(fdis,'# Depth [km] Elev [m] Disp [mm] error [mm] Dist [km]\n');
fprintf(1,'The total number of EQs is %.0f\n\n',uqNum);
for ii=1:uqNum
    % file flag
    fpoFlag     = false;
    fpo2Flag    = false;
    % EQ info
    id   = eqidMat(ii);    % only EQ id
    fprintf(1,'processing EQ %.0f\n',id);
    eqs  = infoMat(ii,:);  % normal info for EQs
    Deq  = eqs(1,1)*1e4+eqs(1,2)*1e2+eqs(1,3);
    Teq  = eqs(1,12);
    mag  = eqs(1,10);
    eqloc  = eqs(1,7:9);
    eqtime = [ Deq Teq ];
    idStr  = num2str(id,'%12.0d');
    magStr = num2str(mag,'%04.2f');
    %------------------------------- velocity change -----------------------------------
    fdfName  = [ 'EQ' idStr '_Mw' magStr 'df.vel' ];
    fdf = fopen(fdfName,'w');
    % output EQ info
    fprintf(fdf,'# velocities after EQ extracted from GPS_extract_GPSfitsum.m\n');
    fprintf(fdf,'# 1    2   3   4    5   6    7    8    9          10    11  12\n');
    fprintf(fdf,'# Year Mon Day Hour Min Sec  Lon  Lat  Depth[km]  Mag   ID  Decyr\n');
    fprintf(fdf,'# %4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f\n',eqs);
    % output site info for this EQ
    fprintf(fdf,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
    fprintf(fdf,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
    fprintf(fdf,'# Height [m] Disp [mm] error [mm]\n');
    %------------------------------- coseismic deformation -----------------------------------
    fcoName  = [ 'EQ' idStr '_Mw' magStr 'co.vel' ];
    fco = fopen(fcoName,'w');
    % output EQ info
    fprintf(fco,'# EQ coseismic deformation extracted from GPS_extract_GPSfitsum.m\n');
    fprintf(fco,'# 1    2   3   4    5   6    7    8    9          10    11  12\n');
    fprintf(fco,'# Year Mon Day Hour Min Sec  Lon  Lat  Depth[km]  Mag   ID  Decyr\n');
    fprintf(fco,'# %4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f\n',eqs);
    % output site info for this EQ
    fprintf(fco,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
    fprintf(fco,'# Sta Lon Lat Height OE ON OU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
    fprintf(fco,'# Height [m] Disp [mm] error [mm]\n');
    %-------------------------------- fit summary ---------------------------------------
    ffitName = [ 'EQ' idStr '_Mw' magStr '.fitsum' ];
    ffit = fopen(ffitName,'w');
    % output EQ info
    fprintf(ffit,'# EQ fit summary extracted from GPS_extract_GPSfitsum.m\n');
    fprintf(ffit,'# 1    2   3   4    5   6    7    8    9          10    11  12\n');
    fprintf(ffit,'# Year Mon Day Hour Min Sec  Lon  Lat  Depth(km)  Mag   ID  Decyr\n');
    fprintf(ffit,'%4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f\n',eqs);
    % unit
    fprintf(ffit,'# SCALE2M ScaleToMeter Unit\n');
    fprintf(ffit,'SCALE2M %8.3e\n',scaleOut);
    % output fitsum info for this EQ
    fprintf(ffit,'# 1    2     3        4    5    6      7     8  9   10  11  12  13  14\n');
    fprintf(ffit,'# Site Comp  Fittype  Deq  Teq  Tstart Tend  b  v1  v2  dv  O   a   tau\n');
    %------------------------------------------------------------------------------------------
    distMat = []; siteMat = ''; 
    NMat = ''; EMat = ''; UMat = '';
    for jj=1:siteNum
        site      = siteList{jj};
        loc       = locMat(jj,:);
        rneu      = rneuList{jj};
        eqMat     = eqList{jj};
        funcMat   = funcList{jj};
        paramMat  = paramList{jj};
        eqinfoMat = eqinfoList{jj};
        rateRow   = rateList{jj}; 
        T1        = rateRow(1,1); 
	T2        = rateRow(1,2);
        [ D2,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(T2);
        if ~isscalar(eqinfoMat)   % if EQ removed
            ind1    = eqinfoMat(:,11)==id;
            ind2    = find(eqMat(:,1)==Deq);
	    ind2len = length(ind2);
            if any(ind1) && any(ind2) % if this EQ removed
                wgt     = 1.0;
                % distance from site to EQ
                dist    = eqinfoMat(ind1,13);
                % velocity after this EQ
                v2ee    = paramMat(ind2(1),10);
                v2nn    = paramMat(ind2(1),3);
                v2uu    = paramMat(ind2(1),17);
                v2err   = paramMat(ind2(1),[ 31 24 38 ]);
                % coseismic deformation
                coee    = paramMat(ind2(1),12);
                conn    = paramMat(ind2(1),5); 
                couu    = paramMat(ind2(1),19); 
                coerr   = paramMat(ind2(1),[ 33 26 40 ]); 
                % postseismic deformation
                poee    = paramMat(ind2(1),13);
                ponn    = paramMat(ind2(1),6);
                pouu    = paramMat(ind2(1),20); 
                poerr   = paramMat(ind2(1),[ 34 27 41 ]);
                taus    = paramMat(ind2(1),[ 14  7 21 ]);
                tauserr = paramMat(ind2(1),[ 35 28 42 ]);
		% function name
                func    = funcMat(ind2(1),:);
                % after-EQ velocity vel file
                fprintf(fdf,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
                            site,loc,v2ee,v2nn,v2uu,v2err,wgt,eqtime,D2,T2,0.0);
                % coseismic deformation vel file
                if Teq<rneu(1,2) || Teq>rneu(end,2) % not directly recorded
                   fprintf(fco,'#%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
                           site,loc,coee,conn,couu,coerr,wgt,eqtime,eqtime,0.0);
                else % directly recorded
                   fprintf(fco,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
                           site,loc,coee,conn,couu,coerr,wgt,eqtime,eqtime,0.0);
                end
                if ~isempty(regexpi(func,'(log|lng|exp)')) || ~isempty(regexpi(func,'k[0-9]{2}'))
                   if ~fpoFlag
                       %------------------------------- posteismic deformation -----------------------------------
                       fpoName  = [ 'EQ' idStr '_Mw' magStr 'po.vel' ];
                       fpo = fopen(fpoName,'w');
                       % output EQ info
                       fprintf(fpo,'# EQ postseismic deformation extracted from GPS_extract_GPSfitsum.m\n');
                       fprintf(fpo,'# 1    2   3   4    5   6    7    8    9          10    11  12\n');
                       fprintf(fpo,'# Year Mon Day Hour Min Sec  Lon  Lat  Depth[km]  Mag   ID  Decyr\n');
                       fprintf(fpo,'# %4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f\n',eqs);
                       % output site info for this EQ
                       fprintf(fpo,'# 1   2   3   4      5  6  7  8   9   10  11   12   13   14     15     16\n');
                       fprintf(fpo,'# Sta Lon Lat Height AE AN AU ErE ErN ErU tauE tauN tauU tauErE tauErN tauErU\n');
                       fprintf(fpo,'# Height [m] Disp [mm] error [mm]\n');
                       %------------------------------- posteismic deformation for dateList -----------------------------------
                       %fpoDateName = [ 'EQ' idStr '_Mw' magStr 'poDend.vel' ];
		       if ~isempty(dateList)
		          for ll=1:length(dateList)
			     dd = dateList(ll);
			     if dd<Deq, continue; end
                             fpoDateName = [ 'EQ' idStr '_Mw' magStr 'po' num2str(dd) '.vel' ];
                             fpoDate = fopen(fpoDateName,'w');
                             % output EQ info
                             fprintf(fpoDate,'# EQ postseismic deformation extracted from GPS_extract_GPSfitsum.m\n');
                             fprintf(fpoDate,'# 1    2   3   4    5   6    7    8    9          10    11  12\n');
                             fprintf(fpoDate,'# Year Mon Day Hour Min Sec  Lon  Lat  Depth[km]  Mag   ID  Decyr\n');
                             fprintf(fpoDate,'# %4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f\n',eqs);
                             % output site info for this EQ
                             fprintf(fpoDate,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
                             fprintf(fpoDate,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
                             fprintf(fpoDate,'# Height [m] Disp [mm] error [mm]\n');
                             fclose(fpoDate); 
			  end
		       end
                       fpoFlag = true;
                   end
                   % postseismic deformation parameter file
                   fprintf(fpo,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e\n',...
                           site,loc,poee,ponn,pouu,poerr,taus,tauserr);
                   % postseismic deformation vel files for dateList
                   fname = fitfList{jj};
                   [ pathstr,bname,~ ] = fileparts(fname);
                   p2modname = [ pathstr '/' bname '_EQ' num2str(Deq,'%8.0f') 'po_2model.rneu' ];       
                   [ p2modrneu ] = GPS_readrneu(p2modname,1,scaleOut);
                   p4filname = [ pathstr '/' bname '_EQ' num2str(Deq,'%8.0f') 'po_4fill.rneu' ];       
                   [ p4filrneu ] = GPS_readrneu(p4filname,1,scaleOut);
                   if ~isempty(dateList)
                       for ll=1:length(dateList)
                           dd = dateList(ll);
                           if dd<Deq, continue; end
                           fpoDateName = [ 'EQ' idStr '_Mw' magStr 'po' num2str(dd) '.vel' ];
                           fpoDate = fopen(fpoDateName,'a');
                           % errors
                           ind2mod = p2modrneu(:,1)==dd;
                           ind4fil = p4filrneu(:,1)==dd;
                           if sum(ind2mod)==1
                               poee    = p2modrneu(ind2mod,4);
                               ponn    = p2modrneu(ind2mod,3); 
                               pouu    = p2modrneu(ind2mod,5); 
                               poeeErr = p2modrneu(ind2mod,7); 
                               ponnErr = p2modrneu(ind2mod,6); 
                               pouuErr = p2modrneu(ind2mod,8); 
                               potime  = p2modrneu(ind2mod,1:2);
                           elseif sum(ind4fil)==1 % 4fill file is not usually used
                               poee    = p4filrneu(ind4fil,4);
                               ponn    = p4filrneu(ind4fil,3); 
                               pouu    = p4filrneu(ind4fil,5); 
                               poeeErr = p4filrneu(ind4fil,7); 
                               ponnErr = p4filrneu(ind4fil,6); 
                               pouuErr = p4filrneu(ind4fil,8); 
                               potime  = p4filrneu(ind4fil,1:2);
                           else
                               error('GPS_extract_GPSfitsum ERROR: %8.0f not found in %s or %s!',dd,p2modname,p2filname);
                           end
                           fprintf(fpoDate,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
                           site,loc,poee,ponn,pouu,poeeErr,ponnErr,pouuErr,wgt,eqtime,potime,0.0);
                           fclose(fpoDate); 
                       end
                   end
                end
                % postseismic deformation 2nd parameter file
                if ind2len==2
                    poee2    = paramMat(ind2(2),13);
                    ponn2    = paramMat(ind2(2),6);
                    pouu2    = paramMat(ind2(2),20); 
                    poerr2   = paramMat(ind2(2),[ 34 27 41 ]);
                    taus2    = paramMat(ind2(2),[ 14  7 21 ]);
                    tauserr2 = paramMat(ind2(2),[ 35 28 42 ]);
		    % function name
                    func2    = funcMat(ind2(2),:);
                    if ~isempty(regexpi(func2,'(lg2|ln2|ep2)'))
                       if ~fpo2Flag
                          %------------------------------- posteismic deformation 2nd log -----------------------------------
                          fpo2Name  = [ 'EQ' idStr '_Mw' magStr 'po2.vel' ];
                          fpo2 = fopen(fpo2Name,'w');
                          % output EQ info
                          fprintf(fpo2,'# EQ secondary postseismic deformation extracted from GPS_extract_GPSfitsum.m\n');
                          fprintf(fpo2,'# 1    2   3   4    5   6    7    8    9          10    11  12\n');
                          fprintf(fpo2,'# Year Mon Day Hour Min Sec  Lon  Lat  Depth[km]  Mag   ID  Decyr\n');
                          fprintf(fpo2,'# %4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f\n',eqs);
                          % output site info for this EQ
                          fprintf(fpo2,'# 1   2   3   4      5  6  7  8   9   10  11   12   13   14     15     16\n');
                          fprintf(fpo2,'# Sta Lon Lat Height AE AN AU ErE ErN ErU tauE tauN tauU tauErE tauErN tauErU\n');
                          fprintf(fpo2,'# Height [m] Disp [mm] error [mm]\n');
                          fpo2Flag = true;
                       end
                       fprintf(fpo2,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e\n',...
                               site,loc,poee2,ponn2,pouu2,poerr2,taus2,tauserr2);
                    end
                elseif ind2len>2
                    error('GPS_extract_GPSfitsum ERROR: %s has %d records for %.0f!',site,ind2len,id);
                end
                % fit summary file
                for kk=1:length(ind2)
		    func = funcMat(ind2(kk),:);
		    ff   = reshape(func,[],3)';
                    funcN = ff(1,:);    funcE = ff(2,:);    funcU = ff(3,:);
                    % fitsum file
                    fstind = 0;
                    fprintf(ffit,'%4s N %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',...
                            site,funcN,eqMat(ind2(kk),:),T1,T2,paramMat(ind2(kk),fstind+1:fstind+7));
                    fprintf(ffit,'%4s E %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',...
       	                    site,funcE,eqMat(ind2(kk),:),T1,T2,paramMat(ind2(kk),fstind+8:fstind+14));
                    fprintf(ffit,'%4s U %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',...
                            site,funcU,eqMat(ind2(kk),:),T1,T2,paramMat(ind2(kk),fstind+15:fstind+21));
                    fstind = 21;
                    fprintf(ffit,'%4s N %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e ERR\n',...
                            site,funcN,eqMat(ind2(kk),:),T1,T2,paramMat(ind2(kk),fstind+1:fstind+7));
                    fprintf(ffit,'%4s E %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e ERR\n',...
       	                    site,funcE,eqMat(ind2(kk),:),T1,T2,paramMat(ind2(kk),fstind+8:fstind+14));
                    fprintf(ffit,'%4s U %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e ERR\n',...
                            site,funcU,eqMat(ind2(kk),:),T1,T2,paramMat(ind2(kk),fstind+15:fstind+21));

                    ee    = paramMat(ind2(kk),12);
                    nn    = paramMat(ind2(kk),5); 
                    hdisp = sqrt(ee^2+nn^2);
                    uu    = paramMat(ind2(kk),19); 
                    taus  = paramMat(ind2(kk),[7 14 21]); % N E U
                    distMat = [ distMat; id Teq eqloc mag loc hdisp uu dist taus ];
                    siteMat = [ siteMat; site ];
                    NMat    = [ NMat; funcN ]; 
                    EMat    = [ EMat; funcE ]; 
                    UMat    = [ UMat; funcU ];
                end
            end
        end
    end
    fclose(fco); fclose(ffit); fclose(fdf);
    if fpoFlag  
       fclose(fpo);
    end
    if fpo2Flag, fclose(fpo2); end
    % dist file
    if isempty(distMat)
        fprintf(1,'GPS_extract_GPSfitsum WARNING: %12.0f has no records!\n',id);
    else
        [ distMat,ind ] = sortrows(distMat,12);
        siteMat = siteMat(ind,:);
        NMat = NMat(ind,:); EMat = EMat(ind,:); UMat = UMat(ind,:);
        num = size(distMat,1);
        for jj=1:num
            fprintf(fdis,'%12.0f %12.6f %10.5f %10.5f %9.4f %5.2f %6s %14.9f %14.9f %10.4f %8.1f %8.1f %8.2f %s %10.4e %s %10.4e %s %10.4e\n',...
            distMat(jj,1:6),siteMat(jj,:),distMat(jj,7:end-3),NMat(jj,:),distMat(jj,end-2),EMat(jj,:),distMat(jj,end-1),UMat(jj,:),distMat(jj,end));
        end
    end
end
fclose(fdis);
