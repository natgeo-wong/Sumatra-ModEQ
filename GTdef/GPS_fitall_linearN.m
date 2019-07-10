function [ ] = GPS_fitall_linearN(finName,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_fitall_linearN.m                             % 
% Fit everthing according to the prescribed info                              %
%                                                                             %	
% INPUT:                                                                      %
% finName - *.files                                                           %
% 1     2              3                4                  5                  %
% Site  Site_Loc_File  Data_File        Fit_Param_File     EQ_File            %
% ABGS  SMT_IGS.sites  ABGS_noise.rneu  ABGS_noise.fitsum  mb_ABGS_GPS.eqs    %
% BTET  SMT_IGS.sites  BTET_noise.rneu  BTET_noise.fitsum  mb_BTET_GPS.eqs    %
%                                                                             %
% 6                                                                           %
% Noise_File                                                                  %
% ABGS_res1site.noisum                                                        %
% BTET_res1site.noisum                                                        %
%                                                                             %
% Note: file order can be different, because it uses extension to             %
%       identify file types                                                   %
%                                                                             %
% scaleIn  - scale to meter in *.rneu fileName                                %
%    if scaleIn = [], an optimal unit will be determined                      %
% scaleOut - scale to meter in output rneu, fitsum files                      %
%                                                                             %
% OUTPUT:                                                                     %
% *.vel                                                                       %
% a new *.rneu file that contains common mode noise                           %
%                                                                             %
% first created by Lujia Feng Thu Jun 28 15:45:42 SGT 2012                    %
% added scaleIn & scaleOut lfeng Thu Oct 25 14:57:12 SGT 2012                 %
% added tlim lfeng Mon Jun  1 22:50:41 SGT 2015                               %
% changed tlim to ymdlim lfeng Thu Jul  9 12:42:31 SGT 2015                   %
% changed from 2 to 3 stations lfeng Fri Jul 10 19:25:27 SGT 2015             %
% last modified by Lujia Feng Fri Jul 10 19:25:33 SGT 2015                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... reading %s ...........\n',finName);
[ siteList,locfList,datfList,fitfList,eqsfList,noifList ] = GPS_readfiles(finName);
siteNum = size(siteList,1);

fprintf(1,'\n.......... reading site locations ...........\n');
fprintf(1,'\n.......... reading individual sites ...........\n');
locMat = []; ymd = [];
rneuList0 = {};                          % list of rneu data for all stations [Cell]
eqList    = {};
funcList  = {};
paramList = {};
for ii=1:siteNum
    % read location
    name = locfList{ii};
    [ sites,locs ] = GPS_readsites(name);
    site = siteList{ii};
    ind  = strcmpi(site,sites);
    loc  = locs(ind,1:3);
    locMat = [ locMat; loc ];
    % read data 
    name = datfList{ii};
    [ rneu ] = GPS_readrneu(name,scaleIn,scaleOut);
    % remove data points within tlim
    ftlimName = [ site '_cm.tlim' ];
    if exist(ftlimName,'file')
        fprintf(1,'%s exists\n',ftlimName);
        [ trange ] = GPS_readtlim(ftlimName,site);
        if ~isempty(trange)
            ymdlim = trange(:,[1 3]);
            limNum  = size(ymdlim,1);
            for ii=1:limNum
                ymddate = rneu(:,1);
                indRem  = ymddate>=ymdlim(ii,1) & ymddate<=ymdlim(ii,2);
                indKeep = ~indRem;
                rneu    = rneu(indKeep,:);
            end
        end
    end
    rneuList0 = [ rneuList0; rneu ];     % rneuList (Cell)
    ymd = [ ymd; rneu(:,[1 2]) ];
    %% read initial fit parameters
    %name = inifList{ii};
    %[ ~,~,eqMat,funcMat,paramMat,minmaxMat,fqMat,ampMat ] = GPS_readfitsum(name,site,scaleOut);
    %eqList    = [ eqList; eqMat ];
    %funcList  = [ funcList; funcMat ];
    %paramList = [ paramList; paramMat ];
    % output data info
    dayNum = size(rneu,1);
    fprintf(1,'%s has %d days from %8d to %8d\n',siteList{ii},dayNum,rneu([1 end],1));
end

%%%%%%%%%%%%%%%% prepare %%%%%%%%%%%%%%%%
% only keep days that have at least three stations
fprintf(1,'\n.......... preparing data ...........\n');
ymd    = unique(ymd,'rows');             % Note: assume only one unique decimal year corresponds to yearmonday
dayNum = size(ymd,1);
fprintf(1,'Total: %d days from %8d to %8d\n',dayNum,ymd([1 end],1));
countStack  = zeros(dayNum,1);
for ii=1:siteNum
    rneu = rneuList0{ii};
    [ lia,locb ] = ismember(ymd(:,1),rneu(:,1));
    countStack = countStack + lia;
end
ind = countStack>=3;
countStack = countStack(ind);
ymd = ymd(ind,:);
dayNum = length(ymd);
fprintf(1,'Used:  %d days from %8d to %8d\n',dayNum,ymd([1 end],1));
mat0 = zeros(dayNum,6);     % zeros fill in no data
mat0 = [ ymd mat0 ];
for ii=1:siteNum
    mat  = mat0;
    rneu = rneuList0{ii};
    [ lia,locb ] = ismember(ymd(:,1),rneu(:,1));
    ind = locb(locb>0);
    mat(lia,:)   = rneu(ind,:);
    rneuList{ii} = mat;
end

%%%%%%%%%%%%%%%% fit all %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... fitting data ...........\n');
[ b0,rate,rneuNoise,rchi2,rneuNewList ] = GPS_fitrneu_linearN(rneuList);

%%%%%%%%%%%%%%%% average noise %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... averaging data ...........\n');
rneuStack = zeros(dayNum,3);
for ii=1:siteNum
    rneu = rneuList{ii};
    rneuStack = rneuStack + rneu(:,[3 4 5]);
end
ave = bsxfun(@rdivide,rneuStack,countStack);
rneuAve = rneuNoise;
rneuAve(:,[3 4 5]) = ave;
rneuAve(:,[6 7 8]) = 0;

%%%%%%%%%%%%%%%% save results %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... saving results ...........\n');
% save linear fit results
periodStr = [ '_' num2str(ymd(1,1)) '-' num2str(ymd(end,1)) ];
foutName  = [ 'all' periodStr '.vel' ];
fout = fopen(foutName,'w');
fprintf(fout,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15\n');
fprintf(fout,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D\n');
fprintf(fout,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
fprintf(fout,'# Output from GPS_fitall_linearN.m with common mode noise estimated simultaneously\n');
for ii=1:siteNum
    fprintf(fout,'%s  %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %5.1f %9d %12.6f %9d %12.6f\n',...
            siteList{ii},locMat(ii,:),rate(ii,:),1.0,ymd(1,:),ymd(end,:));
end
fclose(fout);

% save file to test if common mode noise has been extracted correctly
[ ~,basename,~ ] = fileparts(finName);
foutName = [ basename '_NOISE.rneu' ];
GPS_saverneu(foutName,'w',rneuNoise,scaleOut);
foutName = [ basename '_AVE.rneu' ];
GPS_saverneu(foutName,'w',rneuAve,scaleOut);

% save data with common mode removed
for ii=1:siteNum
    foutName = [ siteList{ii} '-NOISE.rneu' ];
    GPS_saverneu(foutName,'w',rneuNewList{ii},scaleOut);
end
