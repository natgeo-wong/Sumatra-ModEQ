function [ rneuNew ] = GPS_fir_filter(filterType,filterT,dT,filterOrder,sigma,phaseShift,frneuName,figFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_fir_filter.m                                %
% filter GPS time series using FIR (finite-during impulse response ) filters    %
% Note: IIR (infinite-during impulse response)                                  %
%                                                                               %
% INPUT:                                                                        %
% filterType  - filter type                                                     %
%   average: running an averaging window of length filterT                      %
%   gauss:   Gaussian filter                                                    %
%   high:    highpass filter                                                    %
%   low:     lowpass filter                                                     %
% filterT     - total length of the filter [50]                                 %
%   the length should cover the whole Gaussian distribution                     %
% dT          - sampling rate of the filter                                     %
%   the finer the lowerpass filter is                                           %
% filterOrder - only for lowpass or highpass filters                            %
%             = 6-8 good numbers                                                %
% sigma       - only for Gaussian filter                                        %
%               controls the width of the Gaussian distribution                 %
% phaseShift  - phase shift                                                     %
%   0: zero phase shift                                                         %
%   1: has phase shift                                                          %
%                                                                               %
% frneuName   - input *.rneu file                                               %
% figFlag = 'on' turn on figure visibility                                      %
%         = 'off' turn off figure visibility                                    %
%                                                                               %
% OUTPUT:                                                                       %
% rneuNew     - new filtered rneu data                                          %
%                                                                               %
% first created by Lujia Feng Mon Apr 15 14:28:12 SGT 2013                      %
% changed name from GPS_filter.m to GPS_fir_filter.m lfeng Tue Apr 28 SGT 2015  %
% last modified by Lujia Feng Tue Apr 16 11:21:16 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'-------------------------------------------------------\n');
fprintf(1,'input file is %s\n',frneuName);

[ rneu ] = GPS_readrneu(frneuName,[],[]);
[ ~,basename,~ ] = fileparts(frneuName);
figName  = [ basename '_' filterType '_filter.png' ];
foutName = [ basename '_' filterType '_filter.rneu' ]; 
basename = strrep(basename,'_','\_');

switch filterType
   % running average window
   case 'average'
      windSize = round(filterT);
      bb = ones(1,windSize)./windSize;
      aa = 1;  % all-zero filter (FIR)
   % Gaussian lowpass filter      xx^2
   %           1           - ---------------
   % G = ---------------- e    2*sigma^2
   %     sqrt(2*pi)*sigma
   case 'gauss' % check gausswin()
      xx = [ -0.5*filterT:dT:0.5*filterT ];
      ff = exp(-0.5*xx.^2/(sigma^2));       % coeffs before exp not important after normalization!!!
      bb = ff/sum(ff);                      % normalization is important!!!!
      aa = 1;
   % lowpass filter
   case 'low'
      cutoffFreq = 1./filterT;
      nyqFreq    = 0.5./dT;                 % the Nyquist frequency
      cutoffFreq = cutoffFreq/nyqFreq;      % cutoff frequency must be normalized by the Nyquist frequency
      % butterwoth filter design
      % filterOrder = length(bb)-1
      [ bb,aa ] = butter(filterOrder,cutoffFreq,'low');
   case 'high'
      cutoffFreq = 1./filterT;
      nyqFreq    = 0.5./dT;                 % the Nyquist frequency
      cutoffFreq = cutoffFreq/nyqFreq;      % cutoff frequency must be normalized by the Nyquist frequency
      % butterwoth filter design
      % filterOrder = length(bb)-1
      [ bb,aa ] = butter(filterOrder,cutoffFreq,'high');
end

tt = rneu(:,2);
nn = rneu(:,3);
ee = rneu(:,4);
uu = rneu(:,5);

if phaseShift==0 % zero-phase filtering has no phase shift
   if strcmp(filterType,'gauss')
      %------------------------------------------------------------------------------------------------------------
      % conv(X,ff,'same/full') - convolution
      % conv with 'full' has latency and output length is X+ff-1
      % conv with 'same' has no latency and output length is X
      %------------------------------------------------------------------------------------------------------------
      nnFilter = conv(nn,bb,'same');
      eeFilter = conv(ee,bb,'same');
      uuFilter = conv(uu,bb,'same');
   else
      %------------------------------------------------------------------------------------------------------------
      % filtfilt(b,a,X) - zero-phase filtering
      %------------------------------------------------------------------------------------------------------------
      nnFilter = filtfilt(bb,aa,nn);
      eeFilter = filtfilt(bb,aa,ee);
      uuFilter = filtfilt(bb,aa,uu);
   end
else % conventional filtering has phase shift
   %------------------------------------------------------------------------------------------------------------
   % filter(b,a,X) - polynomial multiplication 
   % y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb) - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
   % filter has latency, so the filtered signal is delayed by 0.5*filterOrder as compared to the input signal
   % filter output has the same length as input
   %------------------------------------------------------------------------------------------------------------
   nnFilter = filter(bb,aa,nn);
   eeFilter = filter(bb,aa,ee);
   uuFilter = filter(bb,aa,uu);
end

rneuNew      = rneu;
rneuNew(:,3) = nnFilter;
rneuNew(:,4) = eeFilter;
rneuNew(:,5) = uuFilter;
GPS_saverneu(foutName,'w',rneuNew,1);

figh = figure('Visible',figFlag);

subplot(3,1,1);
plot(tt,nn,'g'); hold on
plot(tt,nnFilter,'r','LineWidth',2); 
plot(get(gca,'Xlim'),[0 0]);
subplot(3,1,2);
plot(tt,ee,'g'); hold on
plot(tt,eeFilter,'r','LineWidth',2); 
plot(get(gca,'Xlim'),[0 0]);
subplot(3,1,3);
plot(tt,uu,'g'); hold on
plot(tt,uuFilter,'r','LineWidth',2); 
plot(get(gca,'Xlim'),[0 0]);

print(figh,'-dpng',figName);
fprintf(1,'-------------------------------------------------------\n');
