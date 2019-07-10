function [ ff,pp,prob,levels,fc ] = LombScargle_periodogram(tt,yy,ofac,hifac,signif,winflag,ff0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           LombScargle_periodogram.m	                        %
% Compute the normalized Lomb-Scargle periodogram or power spectrum             %
% for unevenly-spaced data                                                      %
%                                                                               %
% INPUT: N data points at times t_i                                             %
% tt - times at which data points are measured                                  %
% yy - corresponding measurements at tt                                         %
% ofac  - oversampling factor for sampling frequencies (>=4)                    %
%   if empty, use default ofac = 4                                              %
%   Frequency resolution: N independent frequencies within [-fc fc]             %
%   for enenly-spaced data (ref4)                                               %
% hifac - higher frequency factor (1-4)                                         %
%   if hifac = 1, the Nyquist frequency is the highest frequency                %
%   if empty, use default hifac = 1                                             %
% signif - significance level vector e.g. [0.9 0.95 0.99]                       %
% Note: signif = 1 - prob                                                       %
%   e.g. signif = 95% prob = 0.05                                               %
% winflag - window names                                                        %
%   'hanning', 'hamming', 'blackman'                                            %
%   if empty, no windowing is applied                                           %
% ff0 - frequency sampling vector is given!!!                                   %
%                                                                               %
% OUTPUT:                                                                       %
% ff   - frequency sampling vector                                              %
%    length(ff) = 0.5*ofac*hifac*N                                              %
% pp   - power vector reflecting statistical significance                       %
% prob - false-alarm probability of the null hypothesis                         %
%        low prob indicates a highly significant peak in the power spectrum     %
%        P(>z) = 1 - (1-e^(-z))^M                                               %
%    M - independent frequencies that are sampled                               %
% levels - power levels corresponding to significance levels                    %
% fc   - the Nyquist frequency                                                  %
%                                                                               %
% Note: significant peaks might be detected above the Nyquist frequency and     %
%       without any significant aliasing! This would be possible because        %
%       randomly spaced data have some points spaced closer than the average    %
%                                                                               %
% References:                                                                   %
% (1) Martin H. Trauth, MATLAB Recipes for Earth Sciences, 2007, P109           %
% (2) Press, Numerical Recipes, 1992, P575 or 2007 P685                         %
% (3) Scargle, J. D. (1982), Studies in astronomical time series analysis.      %
%     II. Statistical aspects of spectral analysis of unevenly spaced data,     %
%     Astrophys. J., 263(2), 835–853, doi:10.1086/160554.                       %
% (4) Horne, J. H., and S. L. Baliunas (1986), A prescription for period        %
%     analysis of unevenly sampled time series,                                 %
%     Astrophys. J., 302(2), 757–763, doi:10.1086/164037.                       %
% (5) Schulz, M., and K. Stattegger (1997), Spectrum:                           %
%     spectral analysis of unevenly spaced paleoclimatic time series,           %        
%     Comput. Geosci., 23(9), 929–945, doi:10.1016/S0098-3004(97)00087-3.       %
% (6) http://www.mathworks.com/help/signal/ug/spectral-analysis.html#brbq68v    %
%                                                                               %
% modified for GPS data based on lomb.m written by Dmitry Savransky 21 May 2008 %
% first created by Lujia Feng Mon Apr  1 16:37:32 SGT 2013                      %
% added more comments lfeng Fri Oct 25 12:52:06 SGT 2013                        %
% added windowing option lfeng Tue Oct 29 13:21:46 SGT 2013                     %
% added ff0 lfeng Tue Nov 12 16:53:50 SGT 2013                                  %
% last modified by Lujia Feng Tue May 26 12:54:05 SGT 2015                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pre-check
if size(tt,2)~=1 || size(yy,2)~=1, error('LombScargle_periodogram ERROR: tt & yy must be column vectors!'); end
if size(tt)~=size(yy), error('LombScargle_periodogram ERROR: tt & yy must have the same size!'); end

% defaults
if isempty(ofac),  ofac  = 4; end
if isempty(hifac), hifac = 1; end

if nargin<=6
    N  = length(tt);            % number of data points
    T  = tt(end)-tt(1);         % data span
    fprintf(1,'%.0f data points spanning %f\n',N,T);
    
    fb = 1/T;                   % lowest base frequency except mean which is zero frequency or infinite period
    df = fb/ofac;               % frequency sampling interval - oversample more finely than at interval 1/T
    
    dT = T/N;                   % average sampling interval in time
    fc = 0.5/dT;                % average Nyquist critial frequency 
                                % the highest frequency the data can produce theoritically
    fh = fc*hifac;              % the highest frequency used
    
    ff = [ df:df:fh ]';        % sampling frequency vector (cannot deal with zero frequency)
else
    ff = ff0;
    fc = ff(end)/hifac;
end
ww  = 2*pi*ff;                  % angular frequency vector
Mf  = length(ff);
fprintf(1,'%.0f frequency samples between %f and %f\n',Mf,ff(1),ff(end));
fprintf(1,'frequency resolution is %f\n',(ff(end)-ff(1))/Mf);

% tau makes the periodogram invariant to a shift of the origin time
% tau are constants so won't change the periodogram either
% the choice of these particular offsets makes 
% the solution is identical to a least-squares fit of sine and cosine functions to 
% time series yy = Acoswt + Bsinwt
tau = atan2(sum(sin(2*ww*tt.'),2),sum(cos(2*ww*tt.'),2))./(2*ww);      

% windowing data
if ~isempty(winflag)
    len = length(yy);
    switch winflag
       case 'hanning'
          wind = hann(len);
       case 'hamming'
          wind = hamming(len);
       case 'blackman'
          wind = blackman(len);
    end
    yy = wind.*yy;
end
ave = mean(yy);             % data mean which is removed, so not interested in zero frequency
% s2 is the correct normalization term, important for calculating false-alarm probability (ref4)
s2  = var(yy);              % data variance
fprintf(1,'data mean and variance are %e and %e\n',ave,s2);

% the normalized Lomb-Scargle Fourier transform (eqs in ref3,4)
% power is squared
cterm = cos(ww*tt.' - repmat(ww.*tau,1,length(tt)));
sterm = sin(ww*tt.' - repmat(ww.*tau,1,length(tt)));
pp    = (sum(cterm*diag(yy-ave),2).^2./sum(cterm.^2,2) + ...
         sum(sterm*diag(yy-ave),2).^2./sum(sterm.^2,2))/(2*s2);

% M = hifac*length(tt) = hifac*N
M     = 2.0*Mf/ofac;  % number of different/indepedent/effective frequencies which affect significant level

% statistical significane of power
prob  = M*exp(-pp);           % needed for possible round-off errors
ind = prob > 0.01;
prob(ind) = 1-(1-exp(-pp(ind))).^M;

% calculate corresponding power of significance level
levels = -log(1-signif.^(1/M));
