function [ xx,rneuNoise,chi2 ] = GPS_fitrneu_1comp(rneuList,eqList,funcList,paramList)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_fitrneu_1comp.m				   %
% Fit everthing according to the prescribed info                                   %
% lsqnonlin - non-linear least squares                                             %
% resnorm  - the squared 2-norm of the residual = chi2                             %
% residual - the value of the residual fun(x) at the solution x rr = abs(residual) %
%										   %
% INPUT:									   % 
% rneuList  - each cell has a rneu dayNum*8 matrix to store data                   %
%             1        2         3     4    5    6     7     8                     %
%             YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                 %
% eqList    - each cell has an eqNum*2 matrix                                      %
%             1    2                                                               %
%             Deq  Teq                                                             %
% funcList  - each cell has a eqNum*15 string matrix for function names            %
%             'offset_samerate' 'offset_diffrate'                                  %
%             'loglog_samerate' 'loglog_diffrate'                                  %
%             'expexp_samerate' 'expexp_diffrate'                                  %
% paramList - each cell has an eqNum*18 (6 parameters*3 comps) matrix              %
%             filled with zeros if parameter number < 6                            %
% comp      - 'N' 'E' or 'U'                                                       %
% xx        - unknown parameters that need to be estimated 		           %
%   The 1st dayNum variables are common mode noise                                 %
%										   %
% OUTPUT:                   							   %
%										   %
% first created by lfeng Tue Jul 10 15:03:27 SGT 2012                              %
% changed funcList lfeng Wed Jul 11 07:29:24 SGT 2012                              %
% last modified by lfeng Wed Jul 11 07:29:34 SGT 2012                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

chi2  = zeros(1,3);
rneuNoise = rneuList{1};
rneuNoise(:,6:8) = 0;
dayNum = size(rneuNoise,1);
parNum = dayNum+1000;

% loop through 3 components
for ii=1:3
   % set options
   options = optimset('MaxFunEvals',250*parNum,'MaxIter',2000,'TolFun',1e-8,'TolX',1e-8);

   % initial values & bounds
   [ x0,lb,ub ] = GPS_lsqnonlin_1comp_prep(rneuList,funcList,paramList,ii);

   % non-linear inversion
   [ xx,resnorm,residual,exitflag ] = ...
   lsqnonlin(@(xx) GPS_lsqnonlin_1comp(rneuList,eqList,funcList,ii,xx),x0,lb,ub,options);	
   % check if successful
   if exitflag~=1, error('GPS_fitrneu_1comp ERROR: do not converge!'); end

   % output info
   rneuNoise(:,2+ii) = xx(1:dayNum)';
   chi2(ii) = resnorm;					% residual is weighted
end
