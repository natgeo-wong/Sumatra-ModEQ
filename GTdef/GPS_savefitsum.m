function [ ] = GPS_savefitsum(foutName,fitsum,lsqsum,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 GPS_savefitsum                                    %
% write parameters that are read from *.fitsum                                      %
%                                                                                   %
% INPUT:                                                                            %
% foutName - output file name                                                       %
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
% Optional: lsqsum struct including                                                 %
% lsqsum.site          - site name                                                  %
% lsqsum.daynum        - number of days used                                        %
% lsqsum.xx            - solutions  (1*xxNum)                                       %
% lsqsum.xxStd         - standard deviation of solutions                            %
% lsqsum.xxCor         - correlation matrix for model parameters                    %
% lsqsum.resnorm       - chi2, MATLAB output weighted by errors                     %
% lsqsum.realresnorm   - squared 2-norm of the residual                             %
% lsqsum.realrms       - root-mean-square (RMS) misfit                              %
% lsqsum.realrmsN      - root-mean-square (RMS) misfit for North                    %
% lsqsum.realrmsE      - root-mean-square (RMS) misfit for East                     %
% lsqsum.realrmsU      - root-mean-square (RMS) misfit for Up                       %
% lsqsum.realrms1      - root-mean-square (RMS) misfit for 1st iteration            %
% lsqsum.realrmsN1     - root-mean-square (RMS) misfit for 1st iteration North      %
% lsqsum.realrmsE1     - root-mean-square (RMS) misfit for 1st iteration East       %
% lsqsum.realrmsU1     - root-mean-square (RMS) misfit for 1st iteration Up         %
% lsqsum.residual      - value of the residual fun(x) at the solution xx (pntNum*1) %
% lsqsum.exitflag      - exit condition                                             %
% lsqsum.output        - a structure that contains optimization information         %
% lsqsum.lambda        - Lagrange multipliers at the solution xx                    %
% lsqsum.jacob         - Jacobian of fun(x) at the solution xx (pntNum*xxNum)       %
% lsqsum.realjacob     - real Jacobian after reversing back weights                 %
% --------------------------------------------------------------------------------- %
% scaleOut - scale to meter in the output                                           %
%                                                                                   %
% OUTPUT:                                                                           %
% a *fitsum parameter file containing paramters                                     %
%                                                                                   %
% first created by Lujia Feng Thu Oct 25 17:34:35 SGT 2012                          %
% added ERR lfeng Tue Nov 27 21:30:17 SGT 2012                                      %
% modified funcMat lfeng Thu Apr  4 10:29:17 SGT 2013                               %
% corrected fstind error for fqMat & ampMat lfeng Mon Nov 18 01:14:25 SGT 2013      %
% changed to fitsum struct lfeng Wed Nov 27 10:24:11 SGT 2013                       %
% added lsqsum lfeng Mon Dec  2 13:54:19 SGT 2013                                   %
% modified STAT output line lfeng Mon Jul  7 16:21:00 SGT 2014                      %
% added realresnorm for 1st iteration lfeng Wed Jan 21 10:46:40 SGT 2015            %
% added rms misfit lfeng Wed Jan 21 10:47:24 SGT 2015                               %
% last modified by Lujia Feng Wed Jan 21 12:06:14 SGT 2015                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

siteName  = fitsum.site; 
loc       = fitsum.loc;
rateRow   = fitsum.rateRow;
eqMat     = fitsum.eqMat;
funcMat   = fitsum.funcMat;
paramMat  = fitsum.paramMat;
%minmaxMat = fitsum.minmaxMat; % not output
fqMat     = fitsum.fqMat;
ampMat    = fitsum.ampMat;

fout = fopen(foutName,'w');
%----------------------- site info -----------------------
if ~isempty(loc)
    fprintf(fout,'# Output from GPS_savefitsum.m\n');
    fprintf(fout,'# 1    2   3        4        5\n');
    fprintf(fout,'# Site LOC Lon(deg) Lat(deg) Elev(m)\n');
    fprintf(fout,'%4s LOC %14.9f %14.9f %10.4f\n',siteName,loc);
end

%----------------------- fit info -----------------------
if ~isempty(lsqsum)
    TT = fitsum.rateRow(2)-fitsum.rateRow(1);
    daynum    = lsqsum.daynum;
    xxnum     = length(lsqsum.xx);
    dofnum    = daynum*3-xxnum;
    resnorm   = lsqsum.resnorm;
    rchi2     = resnorm/dofnum;
    realres   = lsqsum.realresnorm;
    realrchi2 = realres/dofnum;
    fprintf(fout,'# 1    2    3  4    5      6      7           8            9    10\n');
    fprintf(fout,'# Site STAT TT Days Comps  Params MATLAB_chi2 MATLAB_Rchi2 chi2 Rchi2\n');
    fprintf(fout,'%4s STAT %12.4f %8d 3 %6d %12.4e %8.4e %12.4e %8.4e\n',...
            siteName,TT,daynum,xxnum,resnorm,rchi2,realres,realrchi2);
    fprintf(fout,'# 1    2           3      4     5   6        7     8    9  10\n');
    fprintf(fout,'# Site RMS_MISFIT  North1 East1 Up1 all1     North East Up all\n');
    fprintf(fout,'%4s RMS_MISFIT %12.4e %8.4e %8.4e %8.4e  %12.4e %8.4e %8.4e %8.4e\n',...
            siteName,lsqsum.realrmsN1,lsqsum.realrmsE1,lsqsum.realrmsU1,lsqsum.realrms1,...
	             lsqsum.realrmsN, lsqsum.realrmsE, lsqsum.realrmsU, lsqsum.realrms);
end

%----------------------- unit info -----------------------
if ~isempty(scaleOut)
    fprintf(fout,'# 1    2       3\n');
    fprintf(fout,'# Site SCALE2M ScaleToMeter Unit\n');
    fprintf(fout,'%4s SCALE2M %8.3e\n',siteName,scaleOut);
end

%----------------------- basic linear info -----------------------
if ~isempty(rateRow)
    fprintf(fout,'# 1   2     3        4      5      6    7     8          9\n');
    fprintf(fout,'# Sta Comp  Fittype  Dstart Tstart Dend Tend  Intercept  Rate\n');
    % base model = intercept + rate*t
    T1 = rateRow(1); [ D1,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(T1);
    T2 = rateRow(2); [ D2,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(T2);
    fstind = 2;
    nnb = rateRow(fstind+1); nnRate = rateRow(fstind+2);
    eeb = rateRow(fstind+3); eeRate = rateRow(fstind+4);
    uub = rateRow(fstind+5); uuRate = rateRow(fstind+6);
    fprintf(fout,'%4s N linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,D1,T1,D2,T2,nnb,nnRate);
    fprintf(fout,'%4s E linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,D1,T1,D2,T2,eeb,eeRate);
    fprintf(fout,'%4s U linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,D1,T1,D2,T2,uub,uuRate);
    fstind = 8;
    nnb = rateRow(fstind+1); nnRate = rateRow(fstind+2);
    eeb = rateRow(fstind+3); eeRate = rateRow(fstind+4);
    uub = rateRow(fstind+5); uuRate = rateRow(fstind+6);
    fprintf(fout,'%4s N linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e ERR\n',siteName,D1,T1,D2,T2,nnb,nnRate);
    fprintf(fout,'%4s E linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e ERR\n',siteName,D1,T1,D2,T2,eeb,eeRate);
    fprintf(fout,'%4s U linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e ERR\n',siteName,D1,T1,D2,T2,uub,uuRate);
end

%----------------------- seasonal info -----------------------
if ~isempty(fqMat)
    fprintf(fout,'# 1    2     3        4     5      6      7     8     9\n');
    fprintf(fout,'# Site Comp  Fittype  fqSin fqCos  Tstart Tend  ASin  ACos\n');
    % seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
    fqNum = size(fqMat,1);
    for ii=1:fqNum
        fstind = 0;
        fqS = fqMat(ii,1);         fqC = fqMat(ii,2);
        T1  = ampMat(ii,fstind+1); T2  = ampMat(ii,fstind+2);
        fstind = 2;
        nnS = ampMat(ii,fstind+1); nnC = ampMat(ii,fstind+2);
        eeS = ampMat(ii,fstind+3); eeC = ampMat(ii,fstind+4);
        uuS = ampMat(ii,fstind+5); uuC = ampMat(ii,fstind+6);
        fprintf(fout,'%4s N seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,fqS,fqC,T1,T2,nnS,nnC);
        fprintf(fout,'%4s E seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,fqS,fqC,T1,T2,eeS,eeC);
        fprintf(fout,'%4s U seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,fqS,fqC,T1,T2,uuS,uuC);
        fstind = 8;
        nnS = ampMat(ii,fstind+1); nnC = ampMat(ii,fstind+2);
        eeS = ampMat(ii,fstind+3); eeC = ampMat(ii,fstind+4);
        uuS = ampMat(ii,fstind+5); uuC = ampMat(ii,fstind+6);
        fprintf(fout,'%4s N seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e ERR\n',siteName,fqS,fqC,T1,T2,nnS,nnC);
        fprintf(fout,'%4s E seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e ERR\n',siteName,fqS,fqC,T1,T2,eeS,eeC);
        fprintf(fout,'%4s U seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e ERR\n',siteName,fqS,fqC,T1,T2,uuS,uuC);
    end
end

%----------------------- each earthquake -----------------------
if ~isempty(eqMat)
    fprintf(fout,'# 1    2     3        4    5    6      7     8  9   10  11  12  13  14\n');
    fprintf(fout,'# Site Comp  Fittype  Deq  Teq  Tstart Tend  b  v1  v2  dv  O   a   tau\n');
    
    eqNum = size(eqMat,1);
    for jj=1:eqNum
        func = funcMat(jj,:);
        ff   = reshape(func,[],3)';
        funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
        fstind = 0;
        fprintf(fout,'%4s N %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',...
                siteName,funcN,eqMat(jj,:),T1,T2,paramMat(jj,fstind+1:fstind+7));
        fprintf(fout,'%4s E %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',...
       	    siteName,funcE,eqMat(jj,:),T1,T2,paramMat(jj,fstind+8:fstind+14));
        fprintf(fout,'%4s U %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',...
                siteName,funcU,eqMat(jj,:),T1,T2,paramMat(jj,fstind+15:fstind+21));
        fstind = 21;
        fprintf(fout,'%4s N %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e ERR\n',...
                siteName,funcN,eqMat(jj,:),T1,T2,paramMat(jj,fstind+1:fstind+7));
        fprintf(fout,'%4s E %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e ERR\n',...
       	    siteName,funcE,eqMat(jj,:),T1,T2,paramMat(jj,fstind+8:fstind+14));
        fprintf(fout,'%4s U %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e ERR\n',...
                siteName,funcU,eqMat(jj,:),T1,T2,paramMat(jj,fstind+15:fstind+21));
    end
end

fclose(fout);
