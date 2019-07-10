function [ fitsum,stats ] = GPS_readfitsum(fileName,siteName,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 GPS_readfitsum.m                                  %
% read *.fitsum output either from GPSGUI or GPS_savefitsum.m                       %
% only reads lines started with 4-letter site name; fields are separated by spaces  %
% Three components can be different order rather than N E & U                       %
% All functions have different lengths of names                                     %
% Use funcLen [20] as the maximum length                                            %
% Default is samerate and sametau                                                   %
%                                                                                   %
% Examples for function names:                                                      %
% off = off_samerate; off_diffrate                                                  %
% log_samerate, log_diffrate, exp_samerate, exp_diffrate, k05_samerate, k05_diffrate%
% use the same tau for N, E, and U                                                  %
% log_samerate_tau1 = log_tau1_samerate, log_tau2                                   %
% lg2 = lg2_samerate without offset (must be after log)                             %
% ln2 = ln2_samerate without offset (must be after lng)                             %
% ep2 = ep2_samerate without offset (must be after exp)                             %
%                                                                                   %
% INPUT:                                                                            %
% *.fitsum                                                                          %
% ---- site ----------------------------------------------------------------------- %
% 1    2   3        4        5                                                      %
% Site LOC Lon(deg) Lat(deg) Elev(m)                                                %
% ---- scale ---------------------------------------------------------------------- %
% 1    2    3  4    5     6      7           8            9    10                   %
% Site STAT TT Days Comps Params MATLAB_chi2 MATLAB_Rchi2 chi2 Rchi2                %
% ---- scale ---------------------------------------------------------------------- %
% 1    2       3                                                                    %
% Site SCALE2M ScaleToMeter Unit                                                    %
% ---- linear --------------------------------------------------------------------- %
% 1    2     3        4      5      6    7     8    9    10                         %
% Site Comp  Fittype  Dstart Tstart Dend Tend  b    v    FIT                        %
% Site Comp  Fittype  Dstart Tstart Dend Tend  bErr vErr ERR                        %
% ---- seasonal ------------------------------------------------------------------- %
% 1    2     3        4    5    6       7     8     9     10                        %
% Site Comp  Fittype  fSin fCos Tstart  Tend  ASin  ACos  FIT                       %
% Site Comp  Fittype  fSin fCos Tstart  Tend  ASin  ACos  ERR                       %
% ---- function fit --------------------------------------------------------------- %
% 1    2     3        4   5     6      7     8  9  10  11  12  13 14    15          %
% Site Comp  Fittype  Deq Teq   Tstart Tend  b  v1 v2  dV  O   a  tau   FIT         %
% Site Comp  Fittype  Deq Teq   Tstart Tend  b  v1 v2  dV  O   a  tau   ERR         %
% Site Comp  Fittype  Deq Teq   Tstart Tend  b  v1 v2  dV  O   a  tau   MIN         %
% Site Comp  Fittype  Deq Teq   Tstart Tend  b  v1 v2  dV  O   a  tau   MAX         %
% --------------------------------------------------------------------------------- %
%                                                                                   %
% siteName - site name                                                              %
% scaleOut - scale to meter in output                                               %
%          = [] means no change of unit                                             %
%                                                                                   %
% OUTPUT:                                                                           %
% --------------------------------------------------------------------------------- %
% fitsum struct including                                                           %
% fitsum.site      - site name                                                      %
% fitsum.loc       - site location                                                  %
%          = [ lon lat elev ]                                                       %
% fitsum.rateRow   - linear rates                                                   %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate                         %
%              nnbErr nnRateErr eebErr eeRateErr uubErr uuRateErr ] (2+6*2)         %
% fitsum.minmaxRow - lower & upper bounds for linear rates                          %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate   <-min                 %
%                          nnb nnRate eeb eeRate uub uuRate ] <-max (2+6*2)         %
% fitsum.eqMat     - earthquake dates that has been ordered chronologically         %
%          = [ Deq Teq ]                 (eqNum*2)                                  %
%          = [] means no earthquake removed                                         %
% fitsum.funcMat   - a string matrix for function names                             %
%          = [ funcN funcE funcU ]       (eqNum*3*funcLen)                          %
% fitsum.paramMat  - each row for one earthquake (eqNum*3*7*2)                      %
%          = [ nb nv1 nv2 ndV nO na ntau                                            %
%              eb ev1 ev2 edV eO ea etau                                            %
%              ub uv1 uv2 udV uO ua utau                                            %
%              nbErr nv1Err nv2Err ndVErr nOErr naErr ntauErr                       %
%              ebErr ev1Err ev2Err edVErr eOErr eaErr etauErr                       %
%              ubErr uv1Err uv2Err udVErr uOErr uaErr utauErr ]                     %
% fitsum.minmaxMat - lower & upper bounds for paramMat (eqNum*3*7*2)                %
%          = [ nb nv1 nv2 ndV nO na ntau \                                          %
%              eb ev1 ev2 edV eO ea etau  min                                       %
%              ub uv1 uv2 udV uO ua utau /                                          %
%            / nb nv1 nv2 ndV nO na ntau                                            %
%        max   eb ev1 ev2 edV eO ea etau                                            %
%            \ ub uv1 uv2 udV uO ua utau ]                                          %
% fitsum.fqMat     - frequency in 1/year                                            %
%          = [ fqSin fqCos ]             (fqNum*2)                                  %
% fitsum.ampMat    - amplitudes for seasonal signals                                %
%          = [ Tstart Tend nnS nnC eeS eeC uuS uuC                                  %
%              nnSErr nnCErr eeSErr eeCErr uuSErr uuCErr ]  fqNum*(2+6*2)           %
% --------------------------------------------------------------------------------- %
% stats struct including                                                            %
% stats.site          - site name                                                   %
% stats.TT            - number of observation period                                %
% stats.daynum        - number of days used                                         %
% stats.compnum       - number of components                                        %
% stats.xxnum         - number of parameters                                        %
% stats.resnorm       - chi2, MATLAB output weighted by errors                      %
% stats.rchi2         - rchi2, MATLAB output weighted by errors                     %
% stats.realresnorm   - squared 2-norm of the residual                              %
% stats.realrchi2     - stats.realresnorm/dofnum                                    %
% stats.coEQnum       - number of EQs with offsets only                             %
% stats.poEQnum       - number of EQs with offsets & any number of decays           %
% stats.po1EQnum      - number of EQs with offsets & one decay                      %
% stats.po2EQnum      - number of EQs with offsets & two decays                     %
%     -------------------------------------------------------------------------     %
% stats.realrmsN1     - root-mean-square (RMS) misfit for 1st iteration North       %
% stats.realrmsE1     - root-mean-square (RMS) misfit for 1st iteration East        %
% stats.realrmsU1     - root-mean-square (RMS) misfit for 1st iteration Up          %
% stats.realrms1      - root-mean-square (RMS) misfit for 1st iteration             %
% stats.realrmsN      - root-mean-square (RMS) misfit for North                     %
% stats.realrmsE      - root-mean-square (RMS) misfit for East                      %
% stats.realrmsU      - root-mean-square (RMS) misfit for Up                        %
% stats.realrms       - root-mean-square (RMS) misfit                               %
% --------------------------------------------------------------------------------- %
%									            %
% first created by Lujia Feng Wed Jul  4 17:55:50 SGT 2012                          %
% changed funcList to funcMat lfeng Wed Jul 11 07:25:15 SGT 2012                    %
% considered different fittype for NEU comps lfeng Mon Jul 16 16:48:46 SGT 2012     %
% changed fitsum format lfeng Sun Oct 21 16:21:47 SGT 2012                          %
% added scaleIn & scaleOut & rateRow lfeng Thu Oct 25 12:56:27 SGT 2012             %
% added seasonal cycles lfeng Sat Oct 27 02:51:22 SGT 2012                          %
% added reading ERR lfeng Tue Nov 27 16:28:06 SGT 2012                              %
% modified funcMat lfeng Thu Apr  4 09:21:16 SGT 2013                               %
% added minmaxMat Mat lfeng Tue Apr  9 00:02:35 SGT 2013                            %
% added fitsum struct lfeng Thu Nov 21 16:31:32 SGT 2013                            %
% added lg2 & ep2 lfeng Wed Mar  5 17:52:31 SGT 2014                                %
% added minmaxRow lfeng Mon Mar 17 16:11:28 SGT 2014                                %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                      %
% added read STAT & stats lfeng Mon Jul  7 16:30:48 SGT 2014                        %
% added stats.coEQnum & stats.poEQnum lfeng Mon Jul  7 19:16:35 SGT 2014            %
% added rms misfit lfeng Wed Feb  4 11:32:01 SGT 2015                               %
% added po2EQnum lfeng Wed Feb  4 11:42:29 SGT 2015                                 %
% added po1EQnum lfeng Thu Feb  5 15:18:11 SGT 2015                                 %
% last modified by Lujia Feng Thu Feb  5 15:22:26 SGT 2015                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% check if this file exists %%%%%%%%%%%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readfitsum ERROR: %s does not exist!',fileName); end
fin = fopen(fileName,'r');

stdfst    = '^\w{4}\s+[NEU]\s+'; 	% \w = [a-zA-Z_0-9]
fitend    = 'FIT$';
errend    = 'ERR$';
minend    = 'MIN$';
maxend    = 'MAX$';
stdloc    = 'LOC';
stdstat   = 'STAT';
stdrms    = 'RMS_MISFIT';
stdscale  = 'SCALE2M';
eqMat     = [];
funcMat   = '';                    
paramMat  = [];
minmaxMat = [];
fqMat     = [];
ampMat    = [];
rateRow   = [];   
minmaxRow = [];
scaleIn   = [];
loc       = [];
% for function manipulation
wSpace    = ' '; % one white space
funcLen   = 20;  % length for each function name

%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Reading %%%%%%%%%%%%%%%%%%%%%%%%
while(1)
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % read location line
    isloc   = regexpi(tline,stdloc,'match');
    if ~isempty(isloc)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ flag,remain ] = strtok(remain);
            if strcmpi(flag,'LOC')
                [ lon,remain ] = GTdef_read1double(remain);
                [ lat,remain ] = GTdef_read1double(remain);
                [ elev,~ ] = GTdef_read1double(remain);
                loc = [ lon lat elev ];
            end
        end
    end
    % read statistic line
    isstat   = regexpi(tline,stdstat,'match');
    if ~isempty(isstat)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ flag,remain ] = strtok(remain);
            if strcmpi(flag,'STAT')
                [ stats.TT,remain ] = GTdef_read1double(remain);
                [ stats.daynum,remain ] = GTdef_read1double(remain);
                [ stats.compnum,remain ] = GTdef_read1double(remain);
                [ stats.xxnum,remain ] = GTdef_read1double(remain);
                [ stats.resnorm,remain ] = GTdef_read1double(remain);       
                [ stats.rchi2,remain ] = GTdef_read1double(remain);         
                [ stats.realresnorm,remain ] = GTdef_read1double(remain);   
                [ stats.realrchi2,~ ] = GTdef_read1double(remain);     
            end
        end
    end
    % read rms mistif line
    isstat   = regexpi(tline,stdrms,'match');
    if ~isempty(isstat)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ flag,remain ] = strtok(remain);
            if strcmpi(flag,'RMS_MISFIT')
                [ stats.realrmsN1,remain ] = GTdef_read1double(remain);
                [ stats.realrmsE1,remain ] = GTdef_read1double(remain);
                [ stats.realrmsU1,remain ] = GTdef_read1double(remain);     
                [ stats.realrms1 ,remain ] = GTdef_read1double(remain);
                [ stats.realrmsN ,remain ] = GTdef_read1double(remain);
                [ stats.realrmsE ,remain ] = GTdef_read1double(remain);
                [ stats.realrmsU ,remain ] = GTdef_read1double(remain);
                [ stats.realrms  ,~ ] = GTdef_read1double(remain);
            end
        end
    end
    % read scale line
    isscale = regexpi(tline,stdscale,'match');
    if ~isempty(isscale)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ ~,remain ] = strtok(remain);
            [ scaleIn,~ ] = GTdef_read1double(remain);
        end
    end

%--------------------------------------------------------------------------------------------------
    % only read lines started with 'SITE N' or 'SITE E' or 'SITE U' ended with 'FIT'
    isfst = regexpi(tline,stdfst,'match');
    isend = regexpi(tline,fitend,'match');
    if ~isempty(isfst) && ~isempty(isend)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ comp,remain ]    = strtok(remain);
            [ fittype,remain ] = strtok(remain);
            if strcmpi(fittype,'linear')
                [ ~,remain ] = strtok(remain); [ Tstart,remain ] = GTdef_read1double(remain);
                [ ~,remain ] = strtok(remain); [ Tend,remain ]   = GTdef_read1double(remain);
                [ b,remain ]      = GTdef_read1double(remain);
                [ v,remain ]      = GTdef_read1double(remain);
                if isempty(rateRow)  % new rate
                    rateRow = zeros(1,2+6*2);
                    rateRow(1,1) = Tstart; rateRow(1,2) = Tend;
                end
                fstind = 2;
                if strcmpi(comp,'N')
                    rateRow(1,fstind+1) = b; rateRow(1,fstind+2) = v;
                end
                if strcmpi(comp,'E')
                    rateRow(1,fstind+3) = b; rateRow(1,fstind+4) = v;
                end
                if strcmpi(comp,'U')
                    rateRow(1,fstind+5) = b; rateRow(1,fstind+6) = v;
                end
            elseif strcmpi(fittype,'seasonal')
                [ fqSin,remain ]  = GTdef_read1double(remain); 
                [ fqCos,remain ]  = GTdef_read1double(remain);
                if fqSin ~= fqCos
                    fprintf(1,'GPS_readfitsum WARNING: Sin frequency %f is not equal to Cos frequency %f!\n',fqSin,fqCos);
                end
                [ Tstart,remain ] = GTdef_read1double(remain);
                [ Tend,remain ]   = GTdef_read1double(remain);
                [ ampSin,remain ] = GTdef_read1double(remain);
                [ ampCos,remain ] = GTdef_read1double(remain);
                if isempty(fqMat) || ~any(fqMat(:,1)==fqSin)  % new frequency
                    fqMat  = [ fqMat;  fqSin fqCos ];
                    ampMat = [ ampMat; Tstart Tend zeros(1,6*2) ];
                end
                ind = fqMat(:,1)==fqSin;
                fstind = 2;
                if strcmpi(comp,'N')
                    ampMat(ind,fstind+1) = ampSin; ampMat(ind,fstind+2) = ampCos;
                end
                if strcmpi(comp,'E')
                    ampMat(ind,fstind+3) = ampSin; ampMat(ind,fstind+4) = ampCos;
                end
                if strcmpi(comp,'U')
                    ampMat(ind,fstind+5) = ampSin; ampMat(ind,fstind+6) = ampCos;
                end
            else
                [ Deq,remain ] = GTdef_read1double(remain);
                [ Teq,remain ] = GTdef_read1double(remain);
                [ ~,remain ]   = GTdef_read1double(remain);
                [ ~,remain ]   = GTdef_read1double(remain);
                [ b,remain ]   = GTdef_read1double(remain);
                [ v1,remain ]  = GTdef_read1double(remain);
                [ v2,remain ]  = GTdef_read1double(remain);
                [ dv,remain ]  = GTdef_read1double(remain);
                [ O,remain ]   = GTdef_read1double(remain);
                [ a,remain ]   = GTdef_read1double(remain);
                [ tau,remain ] = GTdef_read1double(remain);
                if ~isempty(regexpi(fittype,'(lg2|ln2|ep2)'))
                    % lg2, ln2 or ep2 must follow log, lng or exp of the same Deq & Teq
                    if isempty(eqMat)  
                        error('GPS_readfitsum ERROR: %8.0f lg2, ln2 or ep2 must follow %8.0f log, lng or exp!',Deq,Deq); 
                    end
                    recnum = sum(eqMat(:,1)==Deq);
                    if recnum == 0
                        error('GPS_readfitsum ERROR: %8.0f lg2, ln2 or ep2 must follow %8.0f log, lng or exp!',Deq,Deq); 
                    end
		    % add the second record for 1 EQ
                    if recnum == 1
                        eqMat      = [ eqMat; Deq Teq ];
                        paramMat   = [ paramMat; zeros(1,7*3*2) ];
                        minmaxMat  = [ minmaxMat; -Inf*ones(1,7*3) Inf*ones(1,7*3) ];
                        funcMat    = [ funcMat; 'nan' wSpace(ones(1,17)) 'nan' wSpace(ones(1,17)) 'nan' wSpace(ones(1,17)) ];
                        ind = false(size(eqMat,1),1);
                        ind(end) = true;
                    end
                    if recnum == 2
                        ind  = eqMat(:,1)==Deq;
			ind1 = find(eqMat(:,1)==Deq);
                        ind(ind1(1)) = false;
                    end
                elseif isempty(eqMat) || ~any(eqMat(:,1)==Deq)  % add new EQ to list
                    eqMat      = [ eqMat; Deq Teq ];
                    paramMat   = [ paramMat; zeros(1,7*3*2) ];
                    minmaxMat  = [ minmaxMat; -Inf*ones(1,7*3) Inf*ones(1,7*3) ];
                    funcMat    = [ funcMat; 'nan' wSpace(ones(1,17)) 'nan' wSpace(ones(1,17)) 'nan' wSpace(ones(1,17)) ];
                    ind = eqMat(:,1)==Deq;
                end
                % for each earthquake N E & U is ordered accordingly
                fstind  = 0;
                len = length(fittype);
                if strcmpi(comp,'N') 
                    paramMat(ind,fstind+1:fstind+7)    = [ b v1 v2 dv O a tau ];
                    funcMat(ind,1:len)                 = fittype;
                end
                if strcmpi(comp,'E')
                    paramMat(ind,fstind+8:fstind+14)   = [ b v1 v2 dv O a tau ]; 
                    funcMat(ind,funcLen+1:funcLen+len) = fittype;
                end
                if strcmpi(comp,'U')
                    paramMat(ind,fstind+15:fstind+21)  = [ b v1 v2 dv O a tau ]; 
                    funcMat(ind,funcLen*2+1:funcLen*2+len) = fittype;
                end
            end
        end
    end

%--------------------------------------------------------------------------------------------------
% Note: ERR must follow FIT!!!! ERR can not be before FIT!!!!
    % only read lines started with 'SITE N' or 'SITE E' or 'SITE U' ended with 'ERR'
    isfst = regexpi(tline,stdfst,'match');
    isend = regexpi(tline,errend,'match');
    if ~isempty(isfst) && ~isempty(isend)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ comp,remain ]    = strtok(remain);
            [ fittype,remain ] = strtok(remain);
            if strcmpi(fittype,'linear')
                [ ~,remain ] = strtok(remain); [ Tstart,remain ] = GTdef_read1double(remain);
		[ ~,remain ] = strtok(remain); [ Tend,remain ]   = GTdef_read1double(remain);
                [ bErr,remain ]   = GTdef_read1double(remain);
                [ vErr,remain ]   = GTdef_read1double(remain);
                if isempty(rateRow)  % new rate
                    rateRow = zeros(1,2+6*2);
                    rateRow(1,1) = Tstart; rateRow(1,2) = Tend;
                end
                fstind = 8;
                if strcmpi(comp,'N')
                    rateRow(1,fstind+1) = bErr; rateRow(1,fstind+2) = vErr;
                end
                if strcmpi(comp,'E')
                    rateRow(1,fstind+3) = bErr; rateRow(1,fstind+4) = vErr;
                end
                if strcmpi(comp,'U')
                    rateRow(1,fstind+5) = bErr; rateRow(1,fstind+6) = vErr;
                end
            elseif strcmpi(fittype,'seasonal')
                [ fqSin,remain ]  = GTdef_read1double(remain); 
                [ fqCos,remain ]  = GTdef_read1double(remain);
                if fqSin ~= fqCos
                    fprintf(1,'GPS_readfitsum WARNING: Sin frequency %f is not equal to Cos frequency %f!\n',fqSin,fqCos);
                end
                [ Tstart,remain ] = GTdef_read1double(remain);
                [ Tend,remain ]   = GTdef_read1double(remain);
                [ ampSinErr,remain ] = GTdef_read1double(remain);
                [ ampCosErr,remain ] = GTdef_read1double(remain);
                if isempty(fqMat) || ~any(fqMat(:,1)==fqSin)  % new frequency
                    fqMat  = [ fqMat;  fqSin fqCos ];
                    ampMat = [ ampMat; Tstart Tend zeros(1,6*2) ];
                end
                ind = fqMat(:,1)==fqSin;
                fstind = 8;
                if strcmpi(comp,'N')
                    ampMat(ind,fstind+1) = ampSinErr; ampMat(ind,fstind+2) = ampCosErr;
                end
                if strcmpi(comp,'E')
                    ampMat(ind,fstind+3) = ampSinErr; ampMat(ind,fstind+4) = ampCosErr;
                end
                if strcmpi(comp,'U')
                    ampMat(ind,fstind+5) = ampSinErr; ampMat(ind,fstind+6) = ampCosErr;
                end
            else
                [ Deq,remain ]    = GTdef_read1double(remain);
                [ Teq,remain ]    = GTdef_read1double(remain);
                [ ~,remain ]      = GTdef_read1double(remain);
                [ ~,remain ]      = GTdef_read1double(remain);
                [ bErr,remain ]   = GTdef_read1double(remain);
                [ v1Err,remain ]  = GTdef_read1double(remain);
                [ v2Err,remain ]  = GTdef_read1double(remain);
                [ dvErr,remain ]  = GTdef_read1double(remain);
                [ OErr,remain ]   = GTdef_read1double(remain);
                [ aErr,remain ]   = GTdef_read1double(remain);
                [ tauErr,remain ] = GTdef_read1double(remain);
                if isempty(eqMat) || ~any(eqMat(:,1)==Deq)
                    error('GPS_readfitsum ERROR: EQ %8.0f ERR must be after FIT!',Deq);
                end
		ind    = eqMat(:,1)==Deq;
                recnum = sum(ind);
                if recnum == 2
                    ind2 = find(eqMat(:,1)==Deq);
                    if ~isempty(regexpi(fittype,'(lg2|ln2|ep2)'))
                       ind(ind2(1)) = false;
                    else
                       ind(ind2(2)) = false;
                    end
                end
                % for each earthquake N E & U is ordered accordingly
                fstind = 21;
                %len = length(fittype);
                if strcmpi(comp,'N') 
                    paramMat(ind,fstind+1:fstind+7)   = [ bErr v1Err v2Err dvErr OErr aErr tauErr ];
		    % ignore error functions
                    %funcMat(ind,1:len)               = fittype;
                end
                if strcmpi(comp,'E')
                    paramMat(ind,fstind+8:fstind+14)  = [ bErr v1Err v2Err dvErr OErr aErr tauErr ]; 
                    %funcMat(ind,funcLen+1:funcLen+len) = fittype;
                end
                if strcmpi(comp,'U')
                    paramMat(ind,fstind+15:fstind+21) = [ bErr v1Err v2Err dvErr OErr aErr tauErr ]; 
                    %funcMat(ind,funcLen*2+1:funcLen*2+len) = fittype;
                end
            end
        end
    end

%--------------------------------------------------------------------------------------------------
% Note: MIN must follow FIT!!!! MIN can not be before FIT!!!!
    % only read lines started with 'SITE N' or 'SITE E' or 'SITE U' ended with 'MIN'
    isfst = regexpi(tline,stdfst,'match');
    isend = regexpi(tline,minend,'match');
    if ~isempty(isfst) && ~isempty(isend)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ comp,remain ]    = strtok(remain);
            [ fittype,remain ] = strtok(remain);
            if strcmpi(fittype,'linear')
                [ ~,remain ] = strtok(remain); [ Tstart,remain ] = GTdef_read1double(remain);
		[ ~,remain ] = strtok(remain); [ Tend,remain ]   = GTdef_read1double(remain);
                [ bMin,remain ]   = GTdef_read1double(remain);
                [ vMin,remain ]   = GTdef_read1double(remain);
                if isempty(minmaxRow)  % new min max
                    minmaxRow = [ 0  0  -Inf*ones(1,2*3) Inf*ones(1,2*3) ];
                    minmaxRow(1,1) = Tstart; minmaxRow(1,2) = Tend;
                end
                fstind = 2;
                if strcmpi(comp,'N')
                    minmaxRow(1,fstind+1) = bMin; minmaxRow(1,fstind+2) = vMin;
                end
                if strcmpi(comp,'E')
                    minmaxRow(1,fstind+3) = bMin; minmaxRow(1,fstind+4) = vMin;
                end
                if strcmpi(comp,'U')
                    minmaxRow(1,fstind+5) = bMin; minmaxRow(1,fstind+6) = vMin;
                end
            elseif ~strcmpi(fittype,'seasonal')
                [ Deq,remain ] = GTdef_read1double(remain);
                [ Teq,remain ] = GTdef_read1double(remain);
                [ ~,remain ]   = GTdef_read1double(remain);
                [ ~,remain ]   = GTdef_read1double(remain);
                [ b,remain ]   = GTdef_read1double(remain);
                [ v1,remain ]  = GTdef_read1double(remain);
                [ v2,remain ]  = GTdef_read1double(remain);
                [ dv,remain ]  = GTdef_read1double(remain);
                [ O,remain ]   = GTdef_read1double(remain);
                [ a,remain ]   = GTdef_read1double(remain);
                [ tau,remain ] = GTdef_read1double(remain);
                if isempty(eqMat) || ~any(eqMat(:,1)==Deq)
                    error('GPS_readfitsum ERROR: EQ %8.0f MIN must be after FIT!',Deq);
                end
		ind    = eqMat(:,1)==Deq;
                recnum = sum(ind);
                if recnum == 2
                    ind2 = find(eqMat(:,1)==Deq);
                    if ~isempty(regexpi(fittype,'(lg2|ln2|ep2)'))
                       ind(ind2(1)) = false;
                    else
                       ind(ind2(2)) = false;
                    end
                end
                % for each earthquake N E & U is ordered accordingly
                fstind  = 0;
		len = length(fittype);
                if strcmpi(comp,'N') 
                    minmaxMat(ind,fstind+1:fstind+7)    = [ b v1 v2 dv O a tau ];
                end
                if strcmpi(comp,'E')
                    minmaxMat(ind,fstind+8:fstind+14)   = [ b v1 v2 dv O a tau ]; 
                end
                if strcmpi(comp,'U')
                    minmaxMat(ind,fstind+15:fstind+21)  = [ b v1 v2 dv O a tau ]; 
                end
            end
        end
    end

%--------------------------------------------------------------------------------------------------
% Note: MAX must follow FIT!!!! MAX can not be before FIT!!!!
    % only read lines started with 'SITE N' or 'SITE E' or 'SITE U' ended with 'MAX'
    isfst = regexpi(tline,stdfst,'match');
    isend = regexpi(tline,maxend,'match');
    if ~isempty(isfst) && ~isempty(isend)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ comp,remain ]    = strtok(remain);
            [ fittype,remain ] = strtok(remain);
            if strcmpi(fittype,'linear')
                [ ~,remain ] = strtok(remain); [ Tstart,remain ] = GTdef_read1double(remain);
		[ ~,remain ] = strtok(remain); [ Tend,remain ]   = GTdef_read1double(remain);
                [ bMax,remain ]   = GTdef_read1double(remain);
                [ vMax,remain ]   = GTdef_read1double(remain);
                if isempty(minmaxRow)  % new min max
                    minmaxRow = [ 0  0  -Inf*ones(1,2*3) Inf*ones(1,2*3) ];
                    minmaxRow(1,1) = Tstart; minmaxRow(1,2) = Tend;
                end
                fstind = 8;
                if strcmpi(comp,'N')
                    minmaxRow(1,fstind+1) = bMax; minmaxRow(1,fstind+2) = vMax;
                end
                if strcmpi(comp,'E')
                    minmaxRow(1,fstind+3) = bMax; minmaxRow(1,fstind+4) = vMax;
                end
                if strcmpi(comp,'U')
                    minmaxRow(1,fstind+5) = bMax; minmaxRow(1,fstind+6) = vMax;
                end
            elseif ~strcmpi(fittype,'seasonal')
                [ Deq,remain ] = GTdef_read1double(remain);
                [ Teq,remain ] = GTdef_read1double(remain);
                [ ~,remain ]   = GTdef_read1double(remain);
                [ ~,remain ]   = GTdef_read1double(remain);
                [ b,remain ]   = GTdef_read1double(remain);
                [ v1,remain ]  = GTdef_read1double(remain);
                [ v2,remain ]  = GTdef_read1double(remain);
                [ dv,remain ]  = GTdef_read1double(remain);
                [ O,remain ]   = GTdef_read1double(remain);
                [ a,remain ]   = GTdef_read1double(remain);
                [ tau,remain ] = GTdef_read1double(remain);
                if isempty(eqMat) || ~any(eqMat(:,1)==Deq)
                    error('GPS_readfitsum ERROR: EQ %8.0f MIN must be after FIT!',Deq);
                end
		ind    = eqMat(:,1)==Deq;
                recnum = sum(ind);
                if recnum == 2
                    ind2 = find(eqMat(:,1)==Deq);
                    if ~isempty(regexpi(fittype,'(lg2|ln2|ep2)'))
                       ind(ind2(1)) = false;
                    else
                       ind(ind2(2)) = false;
                    end
                end
                % for each earthquake N E & U is ordered accordingly
                fstind  = 21;
                len = length(fittype);
                if strcmpi(comp,'N') 
                    minmaxMat(ind,fstind+1:fstind+7)   = [ b v1 v2 dv O a tau ];
                end
                if strcmpi(comp,'E')
                    minmaxMat(ind,fstind+8:fstind+14)  = [ b v1 v2 dv O a tau ]; 
                end
                if strcmpi(comp,'U')
                    minmaxMat(ind,fstind+15:fstind+21) = [ b v1 v2 dv O a tau ]; 
                end
            end
        end
    end
end
fclose(fin);

% order earthquakes
if ~isempty(eqMat)
    [ eqMat,ind ] = sortrows(eqMat);
    funcMat   = funcMat(ind,:);
    paramMat  = paramMat(ind,:);
    minmaxMat = minmaxMat(ind,:);
end

% scale if needed
if ~isempty(scaleOut)
    if isempty(scaleIn)
        fprintf(1,'GPS_readfitsum WARNING: %s needs to specify SCALE2M!\n',fileName);
    else
        if ~isempty(rateRow)
            rateRow(:,3:end)  = rateRow(:,3:end)*scaleIn/scaleOut;
        end
        if ~isempty(minmaxRow)
            minmaxRow(:,3:end)= minmaxRow(:,3:end)*scaleIn/scaleOut;
        end
        if ~isempty(ampMat)
            ampMat(:,3:end)   = ampMat(:,3:end)*scaleIn/scaleOut;
        end
        if ~isempty(paramMat)
            % paramMat
            paramMat(:,1:6)   = paramMat(:,1:6)*scaleIn/scaleOut;
            paramMat(:,8:13)  = paramMat(:,8:13)*scaleIn/scaleOut;
            paramMat(:,15:20) = paramMat(:,15:20)*scaleIn/scaleOut;
            paramMat(:,22:27) = paramMat(:,22:27)*scaleIn/scaleOut;
            paramMat(:,29:34) = paramMat(:,29:34)*scaleIn/scaleOut;
            paramMat(:,36:41) = paramMat(:,36:41)*scaleIn/scaleOut;
	    % minmaxMat
            minmaxMat(:,1:6)   = minmaxMat(:,1:6)*scaleIn/scaleOut;
            minmaxMat(:,8:13)  = minmaxMat(:,8:13)*scaleIn/scaleOut;
            minmaxMat(:,15:20) = minmaxMat(:,15:20)*scaleIn/scaleOut;
            minmaxMat(:,22:27) = minmaxMat(:,22:27)*scaleIn/scaleOut;
            minmaxMat(:,29:34) = minmaxMat(:,29:34)*scaleIn/scaleOut;
            minmaxMat(:,36:41) = minmaxMat(:,36:41)*scaleIn/scaleOut;
        end
    end
end

% assign to fitsum struct
fitsum.site      = siteName;
fitsum.loc       = loc;
fitsum.rateRow   = rateRow;
fitsum.minmaxRow = minmaxRow;
fitsum.eqMat     = eqMat;
fitsum.funcMat   = funcMat;
fitsum.paramMat  = paramMat;
fitsum.minmaxMat = minmaxMat;
fitsum.fqMat     = fqMat;
fitsum.ampMat    = ampMat;

% summarize functions
funcNum = size(funcMat,1);
stats.coEQnum  = 0;
stats.poEQnum  = 0;
stats.po1EQnum = 0;
stats.po2EQnum = 0;
for ii=1:funcNum
   func = funcMat(ii,:);
   % number of EQs with offsets & logarithmic or exponential decays
   if ~isempty(regexpi(func,'(log|lng|exp)_\w+')) || ~isempty(regexpi(func,'k[0-9]{2}_\w+'))
      stats.poEQnum = stats.poEQnum + 1;
   % number of EQs with offsets only
   elseif ~isempty(regexpi(func,'off_\w+'))
      stats.coEQnum = stats.coEQnum + 1;
   end
   % number of EQs with secondary logarithmic or exponential decays
   if ~isempty(regexpi(func,'(lg2|ep2)'))
      stats.po2EQnum = stats.po2EQnum + 1;
   end
   stats.po1EQnum = stats.poEQnum - stats.po2EQnum;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GTdef_read1double.m				%
% 	      function to read in one double number from a string		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ value,remain ] = GTdef_read1double(str)

[str1,remain] = strtok(str);
if isempty(str1)||strncmp(str1,'#',1)
    error('GPS_readfitsum ERROR: The input file is wrong!');
end
value = str2double(str1);
