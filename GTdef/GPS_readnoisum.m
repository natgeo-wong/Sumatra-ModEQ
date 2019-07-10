function [ noisum ] = GPS_readnoisum(fileName,siteName,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_readnoisum.m                                   %
% read *.noisum from GPS_est_noise_sum.m which combines MLE results from            %
% Langbein's est_noise code                                                         %
% only reads lines started with 4-letter site name; fields are separated by spaces  %
% Three components can be different order rather than N E & U                       %
% Note: haven't debugged for seasonal signals yet!!!!                               %
%                                                                                   %
% INPUT:                                                                            %
% *.noisum                                                                          %
% ---- site ----------------------------------------------------------------------- %
% 1    2    3   4   5                                                               %
% Site LOC  Lon Lat Height(m)                                                       %
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
% 1    2     3      4      5      6    7     8     9     10                         %
% Site Comp  noise  Dstart Tstart Dend Tend  Index Power FIT                        %
% Site Comp  noise  Dstart Tstart Dend Tend  Index Power ERR                        %
% --------------------------------------------------------------------------------- %
% siteName - site name                                                              %
% scaleOut - scale to meter in output                                               %
%          = [] means no change of unit                                             %
%                                                                                   %
% OUTPUT:                                                                           %
% --------------------------------------------------------------------------------- %
% noisum struct including                                                           %
% noisum.site     - site name                                                       %
% noisum.loc      - site location                                                   %
%          = [ lon lat elev ]                                                       %
% noisum.rateRow  - linear rate                                                     %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate                         %
%              nnbErr nnRateErr eebErr eeRateErr uubErr uuRateErr ] (2+6*2)         %
% noisum.fqMat    - frequency in 1/year                                             %
%          = [ fqSin fqCos ]             (fqNum*2)                                  %
% noisum.ampMat   - amplitudes for seasonal signals                                 %
%          = [ Tstart Tend nnS nnC eeS eeC uuS uuC                                  %
%              nnSErr nnCErr eeSErr eeCErr uuSErr uuCErr ]  fqNum*(2+6*2)           %
% noisum.noiMat   - indecies and amplitudes for noise components                    %
%          = [ nnInd nnAmp eeInd eeAmp uuInd uuAmp                                  %
%              nnIndErr nnAmpErr eeIndErr eeAmpErr uuIndErr uuAmpErr ] (noiNum*12)  %
%   white noise (index=0), power1 noise, power2 noise                               %
%   one row represents one index                                                    %
% --------------------------------------------------------------------------------- %
%                                                                                   %
% first created by Lujia Feng Tue Nov 26 10:04:18 SGT 2013                          %
% modified noisum format lfeng Mon Jan  6 18:18:32 SGT 2014                         %
% last modified by Lujia Feng Mon Jan  6 18:18:42 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% check if this file exists %%%%%%%%%%%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readnoisum ERROR: %s does not exist!',fileName); end
fin = fopen(fileName,'r');

stdfst    = '^\w{4}\s+[NEU]\s+'; 	% \w = [a-zA-Z_0-9]
fitend    = 'FIT$';
errend    = 'ERR$';
stdloc    = 'LOC';
stdscale  = 'SCALE2M';
rateRow   = [];   
fqMat     = [];
ampMat    = [];
noiMat    = [];
scaleIn   = [];
loc       = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Reading %%%%%%%%%%%%%%%%%%%%%%%%
while(1)
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % read location line (can be missing)
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
                    fprintf(1,'GPS_readnoisum WARNING: Sin frequency %f is not equal to Cos frequency %f!\n',fqSin,fqCos);
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
            elseif strcmpi(fittype,'noise')
                [ ~,remain ] = strtok(remain); [ Tstart,remain ] = GTdef_read1double(remain);
                [ ~,remain ] = strtok(remain); [ Tend,remain ]   = GTdef_read1double(remain);
                [ index,remain ]    = GTdef_read1double(remain);
                [ powerAmp,remain ] = GTdef_read1double(remain);
                fstind = 0;
                if index==0, rowind = 1; else rowind = 2; end
                if strcmpi(comp,'N') 
                    noiMat(rowind,fstind+1:fstind+2) = [ index powerAmp ];
                end
                if strcmpi(comp,'E')
                    noiMat(rowind,fstind+3:fstind+4) = [ index powerAmp ];
                end
                if strcmpi(comp,'U')
                    noiMat(rowind,fstind+5:fstind+6) = [ index powerAmp ];
                end
            end
        end
    end

%--------------------------------------------------------------------------------------------------
    % only read lines started with 'SITE N' or 'SITE E' or 'SITE U' ended with 'ERR'
    isfst = regexpi(tline,stdfst,'match');
    isend = regexpi(tline,errend,'match');
    if ~isempty(isfst) && ~isempty(isend)
        [ name,remain ] = strtok(tline);
        if isempty(siteName) || strcmpi(name,siteName)
            [ comp,remain ]    = strtok(remain);
            [ fittype,remain ] = strtok(remain);
            if strcmpi(fittype,'linear')
                [ ~,remain ] = strtok(remain); [ ~,remain ] = strtok(remain);
                [ Tstart,remain ] = GTdef_read1double(remain);
                [ Tend,remain ]   = GTdef_read1double(remain);
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
                    fprintf(1,'GPS_readnoisum WARNING: Sin frequency %f is not equal to Cos frequency %f!\n',fqSin,fqCos);
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
            elseif strcmpi(fittype,'noise')
                [ ~,remain ] = strtok(remain); [ Tstart,remain ] = GTdef_read1double(remain);
                [ ~,remain ] = strtok(remain); [ Tend,remain ]   = GTdef_read1double(remain);
                [ indexErr,remain ]    = GTdef_read1double(remain);
                [ powerAmpErr,remain ] = GTdef_read1double(remain);
                fstind = 6;
		if index==0, rowind = 1; else rowind = 2; end
                if strcmpi(comp,'N') 
                    noiMat(rowind,fstind+1:fstind+2) = [ indexErr powerAmpErr ];
                end
                if strcmpi(comp,'E')
                    noiMat(rowind,fstind+3:fstind+4) = [ indexErr powerAmpErr ];
                end
                if strcmpi(comp,'U')
                    noiMat(rowind,fstind+5:fstind+6) = [ indexErr powerAmpErr ];
                end
            end
        end
    end
end
fclose(fin);

% scale if needed
if ~isempty(scaleOut)
    if isempty(scaleIn)
        fprintf(1,'GPS_readnoisum WARNING: %s needs to specify SCALE2M!\n',fileName);
    else
        if ~isempty(rateRow)
            rateRow(:,3:end) = rateRow(:,3:end)*scaleIn/scaleOut;
        end
        if ~isempty(ampMat)
            ampMat(:,3:end)  = ampMat(:,3:end)*scaleIn/scaleOut;
        end
        if ~isempty(noiMat)
            noiMat(:,[2 4 6 8 10 12]) = noiMat(:,[2 4 6 8 10 12])*scaleIn/scaleOut;
        end
    end
end

% assign to noisum struct
noisum.site    = siteName;
noisum.loc     = loc;
noisum.rateRow = rateRow;
noisum.noiMat  = noiMat;
noisum.fqMat   = fqMat;
noisum.ampMat  = ampMat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GTdef_read1double.m                               %
% 	      function to read in one double number from a string                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ value,remain ] = GTdef_read1double(str)

[str1,remain] = strtok(str);
if isempty(str1)||strncmp(str1,'#',1)
    error('GPS_readnoisum ERROR: The input file is wrong!');
end
value = str2double(str1);
