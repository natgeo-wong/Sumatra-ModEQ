function GPS_fitall_1site_bootstrap(fileName,scaleIn,scaleOut,...
         ymdRangeIn,ymdRangeOut,decyrRangeIn,decyrRangeOut,boundsFlag,figFlag,btnum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      GPS_fitall_1site_bootstrap.m                      %
% Fit one station data according to the prescribed earthquakes           %
%                                                                        %
% INPUT:                                                                 %
% fileName - *.files                                                     %
% 1    2             3               4              5                    %
% Site Site_Loc_File Data_File       Fit_Param_File EQ_File              %
% ABGS SMT_IGS.sites ABGS_clean.rneu ABGS.fitsum    ABGS.siteqs          %
% BTET SMT_IGS.sites BTET_clean.rneu BTET.fitsum    BTET.siteqs          %
% 6                                                                      %
% Noise_File                                                             %
% ABGS_res1site.noisum                                                   %
% BTET_res1site.noisum                                                   %
%                                                                        %
% Note: file order can be different, because it uses extension to        %
%       identify file types                                              %
%                                                                        %
% scaleIn  - scale to meter in *.rneu fileName                           %
%    if scaleIn = [], an optimal unit will be determined                 %
% scaleOut - scale to meter in output rneu, fitsum files                 %
%    scaleOut cannot be []                                               %
%                                                                        %
% ymdRangeIn   = [ min max ] {1x2 row vector}                            %
% decyrRangeIn = [ min max ] {1x2 row vector}                            %
% Note: if ymdRangeIn & decyrRangeIn both provided,                      %
%       rneu is trimmed according to the narrrowest range                %
%       NaN is used if no constraint                                     %
%                                                                        %
% ymdRangeOut   = [ min max ] {1x2 row vector}                           %
% decyrRangeOut = [ min max ] {1x2 row vector}                           %
% Note: if ymdRangeOut & decyrRangeOut both provided,                    %
%       rneu is filled according to the widest range                     %
%       NaN indicates no filling & using data length                     %
%                                                                        %
% boundsFlag = 'yes' using bounds                                        %
%            = 'no' not using bounds even if specified in fitsum files   %
%                                                                        %
% figFlag - figure visibility                                            %
% btnum   - number of bootstrap sampling                                 %
%                                                                        %
% OUTPUT:                                                                %
% '_used1site.rneu'    - data used                                       %
% '_outlier1site.rneu' - data not used                                   %
% '_season1site.rneu'  - seasonal signals                                %
% '_mod1site.rneu'     - model prediction from fitting 1 site            %
% '_res1site.rneu'     - residuals from fitting 1 site                   %
% '_Noff1site.rneu'    - data with all offsets removed                   %
% '_Ooff1site.rneu'    - data with only offsets kept                     %
% '_Soff1site.rneu'    - data with only small offsets kept               %
% '_Nrate1site.rneu'   - data with background rates removed              %
% '_postSC1site.rneu'  - all postseismic deformation & seasonal signals  %
% '_postEQs1site.rneu' - postseismic deformation only                    %
% '_Noff2model.rneu'   - model with all offsets removed                  %
% '_Ooff2model.rneu'   - model with only offsets kept                    %
% '_Nrate2model.rneu'  - model with background rates removed             %
% '_postSC2model.rneu' - all postseismic deformation & seasonal signals  %
% '_postEQs2model.rneu'- postseismic deformation only                    %
% '_mod4fill.rneu'     - filled data                                     %
% '_Noff4fill.rneu'    - filled data with all offsets removed            %
% '_Ooff4fill.rneu'    - filled data with only offsets kept              %
% '_Nrate4fill.rneu'   - filled data with background rates removed       %
% '_postSC4fill.rneu'  - all postseismic deformation & seasonal signals  %
% '_postEQs4fill.rneu' - filled postseismic deformation only             %
%                                                                        %
% modified based on GPS_fitall_1site.m lfeng Thu Feb 19 15:36:04 SGT 2015%
% last modified by Lujia Feng Thu Feb 19 22:59:21 SGT 2015               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ siteList,locfList,datfList,fitfList,~,noifList ] = GPS_readfiles(fileName);
siteNum = size(siteList,1);

for ii=1:siteNum
    % site name
    siteName = siteList{ii};  
    fprintf(1,'\n.................................................................\n');
    fprintf(1,'\n%s\n',siteName);

    %--------------------- check if folder exists ---------------------%
    if ~exist(siteName,'dir')
       mkdir(siteName);
    end

    %--------------------- read location ---------------------%
    fname = locfList{ii};
    [ sites,locs ] = GPS_readsites(fname);
    ind  = strcmpi(siteName,sites);
    loc = locs(ind,1:3); % site location

    %--------------------- read & trim rneu ---------------------%
    fname = datfList{ii};
    [ rneu ]   = GPS_readrneu(fname,scaleIn,scaleOut);
    [ rneu,~ ] = GPS_trimrneu(rneu,[],ymdRangeIn,decyrRangeIn);
    [ ~,basename,~ ] = fileparts(fname);
 
    %--------------------- read & trim fitsum ---------------------%
    fname = fitfList{ii};
    [ fitsum ] = GPS_readfitsum(fname,siteName,scaleOut);
    % trim fitsum according to user-provided ymdRangeIn & decyrRangeIn & rneu data range
    [ fitsum ] = GPS_trimfitsum(fitsum,ymdRangeIn,decyrRangeIn);
    %% trim according to rneu data
    %rneuRangeIn = rneu([1 end],2);
    %[ fitsum ] = GPS_trimfitsum(fitsum,[],rneuRangeIn);

    %--------------------- read noisum ---------------------%
    fname = noifList{ii};
    noisum = [];
    if ~strcmp(fname,'none');
        [ noisum ] = GPS_readnoisum(fname,siteName,scaleOut);
    end

    %---------- exclude data points on earthquake days ----------%
    dmy = rneu(:,1);
    if ~isempty(fitsum.eqMat)
        DeqMat    = fitsum.eqMat(:,1);
        [ ~,ind ] = setdiff(dmy,DeqMat);
    else
        ind = true(size(dmy));
    end
    rneu = rneu(ind,:);
    fprintf(1,'\nrneu data from %8d to %8d\n\n',rneu([1 end],1));

    if isempty(btnum)
       %btnum = 40*size(rneu,1); % if btnum is not specified
       btnum = 10000; % if btnum is not specified
    end

    %--------------------- fit one station ---------------------%
    GPS_fitrneu_1site_bootstrap(rneu,fitsum,noisum,boundsFlag,btnum,basename,scaleOut);

    fprintf(1,'\nfinished %s \n',siteName);
    fprintf(1,'\n.................................................................\n');
end
