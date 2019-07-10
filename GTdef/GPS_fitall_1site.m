function GPS_fitall_1site(fileName,scaleIn,scaleOut,...
         ymdRangeIn,ymdRangeOut,decyrRangeIn,decyrRangeOut,boundsFlag,figFlag,cases)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_fitall_1site.m                           %
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
% cases   - number of Monte Carlo cases to simulate errors               %
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
% first created by Lujia Feng Wed Jul 11 18:23:04 SGT 2012               %
% added removing offsets lfeng Fri Jul 27 10:31:33 SGT 2012              %
% added detrend lfeng Mon Oct 22 19:21:30 SGT 2012                       %
% added scaleIn & scaleOut lfeng Thu Oct 25 14:58:46 SGT 2012            %
% added ranges lfeng Thu Oct 25 15:35:48 SGT 2012                        %
% excluded data points on EQ days lfeng Wed Apr  3 20:37:08 SGT 2013     %
% added lower & upper bounds lfeng Tue Apr  9 00:51:55 SGT 2013          %
% added boundsFlag lfeng Mon May 13 10:32:57 SGT 2013                    %
% added seasonal output lfeng Mon May 13 17:40:00 SGT 2013               %
% output all EQs that have posseismic lfeng Thu May 16 16:09:47 SGT 2013 %
% added rneuAfterCell lfeng Mon Nov 18 03:07:52 SGT 2013                 %
% added fillrneu lfeng Tue Dec 10 02:11:35 SGT 2013                      %
% added MCerrors lfeng Tue Jan  7 12:36:36 SGT 2014                      %
% added RangeIn & RangeOut lfeng Wed Jan  8 12:18:17 SGT 2014            %
% added modsumModel lfeng Fri Jan 10 09:04:34 SGT 2014                   %
% added lg2, ep2, modsum.uqMat lfeng Thu Mar  6 10:23:08 SGT 2014        %
% do not exclude EQ days lfeng Thu Mar  6 13:00:45 SGT 2014              %
% added rneuOoff & rneuSoff lfeng Thu Mar  6 17:20:10 SGT 2014           %
% added rneuPostNdiffcell lfeng Wed Mar 26 13:30:10 SGT 2014             %
% added properrors lfeng Sun Apr 13 12:25:02 SGT 2014                    %
% added rneuCopoCell lfeng Sun Jun  1 19:51:54 SGT 2014                  %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014               %
% added rneuMegaPost for postseismic only on megathrust lfeng Apr 9 2015 %
% last modified by Lujia Feng Wed Apr  6 18:03:13 SGT 2016               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ siteList,locfList,datfList,fitfList,~,noifList ] = GPS_readfiles(fileName);
siteNum = size(siteList,1);

for ii=1:siteNum
    % site name
    siteName = siteList{ii};  
    fprintf(1,'\n.................................................................\n');
    fprintf(1,'\n%s\n',siteName);

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
    %----dmy = rneu(:,1);
    %----if ~isempty(fitsum.eqMat)
    %----    DeqMat    = fitsum.eqMat(:,1);
    %----    [ ~,ind ] = setdiff(dmy,DeqMat);
    %----else
    %----    ind = true(size(dmy));
    %----end
    %----rneu = rneu(ind,:);
    fprintf(1,'\nrneu data from %8d to %8d\n\n',rneu([1 end],1));

    %--------------------- fit one station ---------------------%
    [ fitsum,lsqsum,modsum ] = GPS_fitrneu_1site(rneu,fitsum,noisum,boundsFlag,cases);

    %--------------------- fill rneu ---------------------%
    [ modsumFill,modsumModel ]  = GPS_fillrneu_1site(rneu,ymdRangeOut,decyrRangeOut,fitsum,lsqsum.xx,lsqsum.xxStd);
    %[ modsumFill,~ ]  = GPS_fillrneu_1site(rneu,ymdRangeOut,decyrRangeOut,fitsum,lsqsum.xx,lsqsum.xxStd);
    %[ ~,modsumModel ] = GPS_fillrneu_1site(rneu,[],[],fitsum,lsqsum.xx,lsqsum.xxStd);

    %--------------------- save fitsum ---------------------%
    foutName  = [ basename '.fitsum' ];
    GPS_savefitsum(foutName,fitsum,lsqsum,scaleOut);

    %--------------------- plot data ---------------------%
    eqCell    = { fitsum.eqMat };
    eqlinCell = { 'k' };
    % plot data & model
    figName   = [ basename '_datamodel.ps' ];
    rneuCell  = { modsum.rneuUsed; modsum.rneuOut; modsum.rneuModel };
    lineCell  = {};
    markCell  = {'errorbar'; 'o'; 'o'};
    sizeCell  = { 2; 5; 2 };
    colorCell = { [0.5 0.5 0.5; 0 1 0]; 'b'; 'r' };
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot model & errors
    figName   = [ basename '_modeldata.ps' ];
    rneuCell  = { modsumModel.rneuModel; modsum.rneuRaw };
    lineCell  = {};
    markCell  = {'errorbar'; 'o'};
    sizeCell  = { 2; 2 };
    colorCell = { [0.5 0.5 0.5; 0 1 0]; 'r' };
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot filled data
    figName   = [ basename '_fill.ps' ];
    rneuCell  = {  modsumFill.rneuFill; modsum.rneuRaw };
    lineCell  = {};
    markCell  = {'errorbar'; 'o'};
    sizeCell  = { 2; 2 };
    colorCell = { [0.5 0.5 0.5; 0 1 0]; 'r' };
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot noise
    figName   = [ basename '_residual.ps' ];
    rneuCell  = { modsum.rneuRes };
    lineCell  = {};
    markCell  = {'o'};
    sizeCell  = { 5 };
    colorCell = {'g'};
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot seasonal signals
    if ~isempty(modsum.rneuSeason)
        figName   = [ basename '_season.ps' ];
        rneuCell  = { modsum.rneuSeason };
        lineCell  = {};
        markCell  = {'o'};
        sizeCell  = { 5 };
        colorCell = {'g'};
        GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    end
    % plot no offsets
    figName   = [ basename '_Noffset.ps' ];
    rneuCell  = { modsum.rneuNoff };
    lineCell  = {};
    markCell  = {'errorbar'; };
    sizeCell  = { 2 };
    colorCell = { [0.5 0.5 0.5; 0 1 0] };
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot with offsets
    figName   = [ basename '_Ooffset.ps' ];
    rneuCell  = { modsum.rneuOoff };
    lineCell  = {};
    markCell  = {'errorbar'; };
    sizeCell  = { 2 };
    colorCell = { [0.5 0.5 0.5; 0 1 0] };
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot small offsets
    figName   = [ basename '_Soffset.ps' ];
    rneuCell  = { modsum.rneuSoff };
    lineCell  = {};
    markCell  = {'errorbar'; };
    sizeCell  = { 2 };
    colorCell = { [0.5 0.5 0.5; 0 1 0] };
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot no rates
    figName   = [ basename '_Nrate.ps' ];
    rneuCell  = { modsum.rneuNrate };
    lineCell  = {};
    markCell  = {'errorbar'; };
    sizeCell  = { 2 };
    colorCell = { [0.5 0.5 0.5; 0 1 0] };
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);
    % plot postseismic of all EQs
    figName   = [ basename '_postEQ.ps' ];
    rneuCell  = {  modsumFill.rneuPostEQs; modsum.rneuPostEQs };
    lineCell  = {};
    markCell  = {};
    sizeCell  = { 5; 5 };
    colorCell = {'g'; 'r'};
    GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut);

    %--------------------- output results ---------------------%
    foutName = [ basename '_used1site.rneu' ];          % data used
    GPS_saverneu(foutName,'w',modsum.rneuUsed,scaleOut);
    foutName = [ basename '_outlier1site.rneu' ];       % data not used
    GPS_saverneu(foutName,'w',modsum.rneuOut,scaleOut);
    foutName = [ basename '_season1site.rneu' ];        % seasonal signals
    GPS_saverneu(foutName,'w',modsum.rneuSeason,scaleOut);
    foutName = [ basename '_res1site.rneu' ];           % residuals
    GPS_saverneu(foutName,'w',modsum.rneuRes,scaleOut);
    foutName = [ basename '_mod1site.rneu' ];           % model prediction
    GPS_saverneu(foutName,'w',modsum.rneuModel,scaleOut);
    foutName = [ basename '_Noff1site.rneu' ];          % data with all offsets removed
    GPS_saverneu(foutName,'w',modsum.rneuNoff,scaleOut);
    foutName = [ basename '_Ooff1site.rneu' ];          % data with only offsets kept
    GPS_saverneu(foutName,'w',modsum.rneuOoff,scaleOut);
    foutName = [ basename '_Soff1site.rneu' ];          % data with only small offsets kept
    GPS_saverneu(foutName,'w',modsum.rneuSoff,scaleOut);
    foutName = [ basename '_Nrate1site.rneu' ];         % data with background rates removed
    GPS_saverneu(foutName,'w',modsum.rneuNrate,scaleOut);
    foutName = [ basename '_postSC1site.rneu' ];        % all postseismic deformation & seasonal signals
    GPS_saverneu(foutName,'w',modsum.rneuPostSC,scaleOut);
    foutName = [ basename '_postEQs1site.rneu' ];       % postseismic deformation only
    GPS_saverneu(foutName,'w',modsum.rneuPostEQs,scaleOut);
    if ~isempty(modsum.rneuMegaPostEQs)                 % postseismic deformation for megathrust EQs only
        foutName = [ basename '_postMegaEQs1site.rneu' ];
        GPS_saverneu(foutName,'w',modsum.rneuMegaPostEQs,scaleOut);
    end
    % data with only postseismic deformation
    eqNum = size(modsum.uqMat,1);
    for jj=1:eqNum
        rneuCopo = modsum.rneuCopoCell{jj};
        if ~isempty(rneuCopo)
            eqName = num2str(modsum.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'copo.rneu' ];       
            GPS_saverneu(foutName,'w',rneuCopo,scaleOut);
        end
        rneuPost = modsum.rneuPostCell{jj};
        if ~isempty(rneuPost)
            eqName = num2str(modsum.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'po.rneu' ];       
            GPS_saverneu(foutName,'w',rneuPost,scaleOut);
        end
        rneuPostNdiff = modsum.rneuPostNdiffCell{jj};
        if ~isempty(rneuPostNdiff)
            eqName = num2str(modsum.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'poNdiff.rneu' ];       
            GPS_saverneu(foutName,'w',rneuPostNdiff,scaleOut);
        end
        rneuAfter = modsum.rneuAfterCell{jj};
        if ~isempty(rneuAfter)
            eqName = num2str(modsum.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_postEQ' eqName '.rneu' ];       
            GPS_saverneu(foutName,'w',rneuAfter,scaleOut);
        end
    end
    %--------------------- output modeled results ---------------------%
    foutName = [ basename '_mod2model.rneu' ];           % model prediction
    GPS_saverneu(foutName,'w',modsumModel.rneuModel,scaleOut);
    foutName = [ basename '_Noff2model.rneu' ];          % model with all offsets removed
    GPS_saverneu(foutName,'w',modsumModel.rneuNoff,scaleOut);
    foutName = [ basename '_Ooff2model.rneu' ];          % model with only offsets kept
    GPS_saverneu(foutName,'w',modsumModel.rneuOoff,scaleOut);
    foutName = [ basename '_Nrate2model.rneu' ];         % model with background rates removed
    GPS_saverneu(foutName,'w',modsumModel.rneuNrate,scaleOut);
    foutName = [ basename '_postSC2model.rneu' ];        % all postseismic deformation & seasonal signals
    GPS_saverneu(foutName,'w',modsumModel.rneuPostSC,scaleOut);
    foutName = [ basename '_postEQs2model.rneu' ];       % postseismic deformation only
    GPS_saverneu(foutName,'w',modsumModel.rneuPostEQs,scaleOut);
    if ~isempty(modsumModel.rneuMegaPostEQs)             % postseismic deformation for megathrust EQs only
        foutName = [ basename '_postMegaEQs2model.rneu' ];
        GPS_saverneu(foutName,'w',modsumModel.rneuMegaPostEQs,scaleOut);
    end
    % data with only postseismic deformation
    eqNum = size(modsumModel.uqMat,1);
    for jj=1:eqNum
        rneuCopo = modsumModel.rneuCopoCell{jj};
        if ~isempty(rneuCopo)
            eqName = num2str(modsumModel.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'copo_2model.rneu' ];       
            GPS_saverneu(foutName,'w',rneuCopo,scaleOut);
        end
        rneuPost = modsumModel.rneuPostCell{jj};
        if ~isempty(rneuPost)
            eqName = num2str(modsumModel.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'po_2model.rneu' ];       
            GPS_saverneu(foutName,'w',rneuPost,scaleOut);
        end
        rneuPostNdiff = modsumModel.rneuPostNdiffCell{jj};
        if ~isempty(rneuPostNdiff)
            eqName = num2str(modsumModel.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'poNdiff_2model.rneu' ];       
            GPS_saverneu(foutName,'w',rneuPostNdiff,scaleOut);
        end
        rneuAfter = modsumModel.rneuAfterCell{jj};
        if ~isempty(rneuAfter)
            eqName = num2str(modsumModel.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_postEQ' eqName '_2model.rneu' ];       
            GPS_saverneu(foutName,'w',rneuAfter,scaleOut);
        end
    end
    %--------------------- output filled results ---------------------%
    foutName = [ basename '_mod4fill.rneu' ];           % filled data
    GPS_saverneu(foutName,'w',modsumFill.rneuFill,scaleOut);
    foutName = [ basename '_Noff4fill.rneu' ];          % filled data with all offsets removed
    GPS_saverneu(foutName,'w',modsumFill.rneuNoff,scaleOut);
    foutName = [ basename '_Ooff4fill.rneu' ];          % filled data with only offsets kept
    GPS_saverneu(foutName,'w',modsumFill.rneuOoff,scaleOut);
    foutName = [ basename '_Nrate4fill.rneu' ];         % filled data with background rates removed
    GPS_saverneu(foutName,'w',modsumFill.rneuNrate,scaleOut);
    foutName = [ basename '_postSC4fill.rneu' ];        % all postseismic deformation & seasonal signals
    GPS_saverneu(foutName,'w',modsumFill.rneuPostSC,scaleOut);
    foutName = [ basename '_postEQs4fill.rneu' ];       % postseismic deformation only
    GPS_saverneu(foutName,'w',modsumFill.rneuPostEQs,scaleOut);
    if ~isempty(modsumFill.rneuMegaPostEQs)             % postseismic deformation for megathrust EQs only
        foutName = [ basename '_postMegaEQs4fill.rneu' ];
        GPS_saverneu(foutName,'w',modsumFill.rneuMegaPostEQs,scaleOut);
    end
    % data with only postseismic deformation
    eqNum = size(modsumFill.uqMat,1);
    for jj=1:eqNum
        rneuCopo = modsumFill.rneuCopoCell{jj};
        if ~isempty(rneuCopo)
            eqName = num2str(modsumFill.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'copo_4fill.rneu' ];       
            GPS_saverneu(foutName,'w',rneuCopo,scaleOut);
        end
        rneuPost = modsumFill.rneuPostCell{jj};
        if ~isempty(rneuPost)
            eqName = num2str(modsumFill.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'po_4fill.rneu' ];       
            GPS_saverneu(foutName,'w',rneuPost,scaleOut);
        end
        rneuPostNdiff = modsumFill.rneuPostNdiffCell{jj};
        if ~isempty(rneuPostNdiff)
            eqName = num2str(modsumFill.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_EQ' eqName 'poNdiff_4fill.rneu' ];       
            GPS_saverneu(foutName,'w',rneuPostNdiff,scaleOut);
        end
        rneuAfter = modsumFill.rneuAfterCell{jj};
        if ~isempty(rneuAfter)
            eqName = num2str(modsumFill.uqMat(jj,1),'%8.0f');
            foutName = [ basename '_postEQ' eqName '_4fill.rneu' ];       
            GPS_saverneu(foutName,'w',rneuAfter,scaleOut);
        end
    end

    % clear current site
    clearvars fitsum noisum lsqsum modsum modsumFill modsumModel rneu
    fprintf(1,'\nfinished %s \n',siteName);
    fprintf(1,'\n.................................................................\n');
end
