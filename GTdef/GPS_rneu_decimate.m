function [ rneu ] = GPS_rneu_decimate(frneuName,deciFactor)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_rneu_decimate.m				        % 
% decimate rneu data                                                                    %
%											%	
% INPUT: 										%
% frneuName  - *.rneu                           					%
%     1        2         3     4    5    6    7    8                              	%
%     YEARMODY YEAR.DCML NORTH EAST VERT Nerr Eerr Verr                          	%
% deciFactor - keep 1 point every deciFactor points                                     %
%											%
% OUTPUT: a new decimated rneu file                                                     %
%										        %
% first created by Lujia Feng Wed Dec  4 10:51:42 SGT 2013                              %
% output rneu lfeng Fri Feb 20 21:26:10 SGT 2015                                        %
% last modified by Lujia Feng Fri Feb 20 21:26:20 SGT 2015                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in *.rneu file
fprintf(1,'\n.......... reading %s  ...........\n',frneuName);
[ rneu ] = GPS_readrneu(frneuName,1,1);

indList = 1:size(rneu,1);
modList = mod(indList,deciFactor);
ind     = modList==0;
rneu    = rneu(ind,:);

% save new rneu file
[ ~,basename,~ ] = fileparts(frneuName);
foutName = [ basename '_deci' num2str(deciFactor,'%.0f') '.rneu' ];
fout     = fopen(foutName,'w');
% write out the header
fprintf(fout,'# decimated %s by %f using GPS_rneu_decimate.m\n',frneuName,deciFactor);
fclose(fout);

GPS_saverneu(foutName,'a',rneu,1);
