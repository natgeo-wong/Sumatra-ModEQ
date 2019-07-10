function [ rneu,dflag ] = GPS_trimrneu(rneu,dflag,ymdRange,decyrRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_trimrneu.m			        %
% window rneu & dlag according to given time period			%
%									%
% INPUT:								% 
% (1) *.rneu                           					%
%     1        2         3     4    5    6     7     8                 	%
%     YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err             	%
% (2) dflag for *.rneu                                                  %
%     dflag can be []                                                   %
% (3) ymdRange = [ min max ] {1x2 row vector}			        %
% (4) decyrRange    = [ min max ] {1x2 row vector}			%
%									%
% Note: if ymdRange & decyrRange both provided,			        %
% rneu is trimmed according to the narrrowest range			%
%									%
% first created by lfeng Fri Dec  2 18:05:42 SGT 2011			%
% added dflag lfeng Mon Mar  5 18:19:20 SGT 2012			%
% last modified by lfeng Mon Mar  5 18:31:30 SGT 2012			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(ymdRange)
   ind = rneu(:,1)>= ymdRange(1) & rneu(:,1)<=ymdRange(2);
   rneu = rneu(ind,:);
   if ~isempty(dflag) 
       dflag = dflag(ind); 
   end
end

if ~isempty(decyrRange)
   ind = rneu(:,2)>= decyrRange(1) & rneu(:,2)<=decyrRange(2);
   rneu = rneu(ind,:);
   if ~isempty(dflag)  
       dflag = dflag(ind); 
   end
end
