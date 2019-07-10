function [ b0,rate,rneuNoise,rchi2,rneuNewList ] = GPS_fitrneu_linearN(rneuList)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          GPS_fitrneu_linearN.m			%
% calculate long-term/interseismic rates and common mode noises		%
% Two common mode constraints:                                          %
% (1) Sum of common mode  ~ 0                                           %
% (2) Rate of common mode ~ 0                                           %
%									%
% INPUT:                                                                %
% rneuList lists rneu data from all stations                            %
% each cell = [ day time north east vert northErr eastErr vertErr ] 	%
%									%
% OUTPUT:                   						%
% b0   - intercept                                                      %
%      = [ b0_E b0_N b0_U b0E_E b0E_N b0E_U ]                           %
% rate - linear velocity                                                %
%      = [ rate_E rate_N rate_U rateE_E rateE_N rateE_U ]               %
% rneuNoise - common mode noise                                         %
%           = [ day time north east vert northErr eastErr vertErr ]     %
% rchi2 - reduced chi2                                                  %
% rneuNewList similar to rneuList but with common mode removed          %
%									%
% References:                                                           %
% Davis, J. L., J. X. Mitrovica, H.-G. Scherneck, and H. Fan (1999),    %
% Investigations of Fennoscandian glacial isostatic adjustment using    %
% modern sea level records, J. Geophys. Res., 104(B2), 2733–2747,       %
% doi:10.1029/1998JB900057.                                             %
%									%
% first created by lfeng Thu Jun 28 16:34:19 SGT 2012                   %
% modified output lfeng Tue Jul 24 13:59:30 SGT 2012                    %
% last modified by lfeng Wed Jul 25 13:42:45 SGT 2012                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iteration to fit a line
% y = b + vt; 			y - model prediction; b - intercept; v - rate
% d = Ax 			d - observation corresponding to y
%          Site 1   |   Site 2   |   Site 3
% d = [ y0 y1 ... yn x0 x1 ... xn z0 z1 ... zn ...... ]'
% A = [ 1 t1 0 0  ] 
%     [ .... .... ] 
%     [ 1 tn 0 0  ]
%     [ 0 0  1 t1 ]
%     [ .... .... ] 
%     [ 0 0  1 tn ]
% x = [ b1 ] \ site 1
%     [ v1 ] /
%     [ b2 ] \ site 2
%     [ v2 ] /
%      ....
%     [ n1 ]  --
%     [ n2 ]    \ common mode noise
%      ....     /
%     [ nn ]  --

%%%%%%%%%%%%%%%% least square linear fit %%%%%%%%%%%%%%%%
siteNum = length(rneuList);
% b v
ymd     = rneuList{1}(:,1);
tt0     = rneuList{1}(:,2);             % all sites should have the same time period
dayNum  = length(tt0);
unitCol = ones(dayNum,1);               % unit column vector
A0      = [ unitCol tt0 ];
Ad      = A0;
% common mode noise
ident   = eye(dayNum);                  % identity matrix
An      = ident;
for ii=1:siteNum-1
    Ad = blkdiag(Ad,A0);                % rate intercept
    An = vertcat(An,ident);             % noise
end
zeroRow = zeros(1,2*siteNum);
AA0    = [ Ad An ];
AAsum  = [ zeroRow ones(1,dayNum) ];
AArate = [ zeroRow tt0' ];
    
% loop through 3 component
b0     = [];     % intercept
b0E    = [];
rate   = [];
rateE  = [];
rneuNoise = [ ymd tt0 zeros(dayNum,6) ];
for ii=1:3
    % loop through all sites
    dat = []; err = [];
    for jj=1:siteNum
        rneu = rneuList{jj};
        dat0 = rneu(:,ii+2);
	dat  = [ dat; dat0 ];
	err0 = rneu(:,ii+5); 
	err  = [ err; err0 ];
    end
    % find zero errors
    ind = err~=0;
    AA = AA0(ind,:); dat = dat(ind); err = err(ind);
    datNum = length(dat);
    % add last constrain that make sum of noise = 0
    AA = [ AA; AAsum; AArate ];
    % rank(AA)
    dat = [ dat; 0; 0 ];
    err = [ err; 1; 1 ];
    wgt  = 1./err.^2;                       % weight is the inverse of squared formal error
    %-------------------------------------------------
    % xx   - estimated results;  
    % stdx - standard errors of xx stdx = sqrt(diag(S))
    % mse  - mean squared error     mse = rchi2; 
    % S    - estimated covariance matrix of xx
    %-------------------------------------------------
    [ xx,stdx,mse,S ] = lscov(AA,dat,wgt);	% xx - estimated results; stdx - standard errors of xx; mse - mean squared error
    % calculate rchi2
    %rr = abs(AA*xx-dat);                   % residuals of model prediction
    %rr2 = rr.^2;
    %chi2 = sum(rr2.*wgt);
    %rchi2(ii,1) = chi2/(datNum-2*siteNum-dayNum);
    rchi2(ii,1) = mse;
    % extract common mode noise
    param  = reshape(xx(1:2*siteNum,1),2,[])';
    b0     = [ b0    param(:,1) ];
    rate   = [ rate  param(:,2) ];
    paramE = reshape(stdx(1:2*siteNum,1),2,[])'; 
    b0E    = [ b0E   paramE(:,1)   ];
    rateE  = [ rateE paramE(:,2)   ];
    noise  =   xx(2*siteNum+1:end,1);
    noiseE = stdx(2*siteNum+1:end,1);
    rneuNoise(:,ii+2) = noise;
    rneuNoise(:,ii+5) = noiseE;
end

% form vel output format switch N & E
b0   = [ b0(:,[2 1 3])   b0E(:,[2 1 3])   ];
rate = [ rate(:,[2 1 3]) rateE(:,[2 1 3]) ];

% remove common mode noise
rneuNewList = {};
for ii=1:siteNum
    rneu = rneuList{ii};
    datInd = rneu(:,3)~=0 & rneu(:,4)~=0 & rneu(:,5)~=0;
    rneu(datInd,[3 4 5]) = rneu(datInd,[3 4 5])-rneuNoise(datInd,[3 4 5]);
    rneu = rneu(datInd,:);
    rneuNewList = [ rneuNewList; rneu ];
end
