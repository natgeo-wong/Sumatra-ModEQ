function [ ] = GPS_rneu2gmt_segy(frneuName,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_rneu2gmt_segy.m                               %
% convert *.rneu to GMT pstext format                                           %
% in order to plot GPS data like seismic reflection/refraction data             %
%                                                                               %
% INPUT:                                                                        %
% frneuName - *.rneu                                                            %
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
% scaleIn   - scale to meter in input fileName                                  %
%    if scaleIn = [], an optimal unit will be determined                        %
% scaleOut  - scale to meter in output rneu                                     %
%    if scaleOut = [], units won't be changed                                   %
% scaleIn & scaleOut is used in GPS_readrneu.m                                  %
%                                                                               %
% OUTPUT:                                                                       %
% *.sege+, *.sege-  - positive or negative areas of east  component             %
% *.segn+, *.segn-  - positive or negative areas of north component             %
% *.segu+, *.segu-  - positive or negative areas of vertical component          %
% 1    2                                                                        %
% Doy  Position                                                                 %
% use > to separate variable areas                                              %
%                                                                               %
% first created by Lujia Feng Wed May 27 16:45:02 SGT 2015                      %
% considered data gaps lfeng Wed May 27 19:04:24 SGT 2015                       %
% corrected dealing with gaps lfeng Thu Jun 11 17:58:12 SGT 2015                %
% corrected a bug for large gaps lfeng Thu Jul  9 19:03:36 SGT 2015             %
% last modified by Lujia Feng Thu Jul  9 19:03:43 SGT 2015                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gap allowed
ttgap = 2.1/365;

% read in data
fprintf(1,'\n.......... GPS_rneu2gmt_segy ...........\n');
fprintf(1,'\nreading %s\n',frneuName);
scaleOut = 0.001; % gmt_segy6xx takes [mm]
[ rneu ] = GPS_readrneu(frneuName,scaleIn,scaleOut);
yearmmdd = rneu(:,1);
tt       = rneu(:,2);
nn       = rneu(:,3);
ee       = rneu(:,4);
uu       = rneu(:,5);
%nnErr   = rneu(:,6);
%eeErr   = rneu(:,7);
%uuErr   = rneu(:,8);

% output to 6 files
[ ~,basename,~ ] = fileparts(frneuName);
feeName1 = [ basename '.sege+' ];
feeName0 = [ basename '.sege-' ];
fnnName1 = [ basename '.segn+' ];
fnnName0 = [ basename '.segn-' ];
fuuName1 = [ basename '.segu+' ];
fuuName0 = [ basename '.segu-' ];

fnn1 = fopen(fnnName1,'w');
fprintf(fnn1,'# converted from %s using GPS_rneu2gmt_segy.m\n',frneuName);
fprintf(fnn1,'# 1    2\n');
fprintf(fnn1,'# Doy  Position\n');
fnn0 = fopen(fnnName0,'w');
fprintf(fnn0,'# converted from %s using GPS_rneu2gmt_segy.m\n',frneuName);
fprintf(fnn0,'# 1    2\n');
fprintf(fnn0,'# Doy  Position\n');

fee1 = fopen(feeName1,'w');
fprintf(fee1,'# converted from %s using GPS_rneu2gmt_segy.m\n',frneuName);
fprintf(fee1,'# 1    2\n');
fprintf(fee1,'# Doy  Position\n');
fee0 = fopen(feeName0,'w');
fprintf(fee0,'# converted from %s using GPS_rneu2gmt_segy.m\n',frneuName);
fprintf(fee0,'# 1    2\n');
fprintf(fee0,'# Doy  Position\n');

fuu1 = fopen(fuuName1,'w');
fprintf(fuu1,'# converted from %s using GPS_rneu2gmt_segy.m\n',frneuName);
fprintf(fuu1,'# 1    2\n');
fprintf(fuu1,'# Doy  Position\n');
fuu0 = fopen(fuuName0,'w');
fprintf(fuu0,'# converted from %s using GPS_rneu2gmt_segy.m\n',frneuName);
fprintf(fuu0,'# 1    2\n');
fprintf(fuu0,'# Doy  Position\n');

pntNum   = length(tt);
for ii=1:pntNum
   % ---------- north ---------- 
   if nn(ii)>0
      % if 1st point, need to add zero, begin the line
      if ii==1 || nn(ii-1)<=0
         fprintf(fnn1,'%14.5f %12.5f\n',tt(ii),0); 
      end
      % too far from the last positive point, add a break
      if ii>1 && nn(ii-1)>0 && tt(ii)-tt(ii-1)>ttgap
         fprintf(fnn1,'%14.5f %12.5f\n',tt(ii-1),0); 
         fprintf(fnn1,'>\n'); 
         fprintf(fnn1,'%14.5f %12.5f\n',tt(ii),0); 
      end
      % add this point normally
      fprintf(fnn1,'%14.5f %12.5f\n',tt(ii),nn(ii)); 
      % reach the end or next point is negative, close the line
      if ii==pntNum || nn(ii+1)<=0
         fprintf(fnn1,'%14.5f %12.5f\n',tt(ii),0); 
         fprintf(fnn1,'>\n'); 
      end
   elseif nn(ii)<0
      if ii==1 || nn(ii-1)>=0
         fprintf(fnn0,'%14.5f %12.5f\n',tt(ii),0); 
      end
      if ii>1 && nn(ii-1)<0 && tt(ii)-tt(ii-1)>ttgap
         fprintf(fnn0,'%14.5f %12.5f\n',tt(ii-1),0); 
         fprintf(fnn0,'>\n'); 
         fprintf(fnn0,'%14.5f %12.5f\n',tt(ii),0); 
      end
      fprintf(fnn0,'%14.5f %12.5f\n',tt(ii),nn(ii)); 
      if ii==pntNum || nn(ii+1)>=0
         fprintf(fnn0,'%14.5f %12.5f\n',tt(ii),0); 
         fprintf(fnn0,'>\n'); 
      end
   end

   % ---------- east ---------- 
   if ee(ii)>0
      if ii==1 || ee(ii-1)<=0
         fprintf(fee1,'%14.5f %12.5f\n',tt(ii),0); 
      end
      if ii>1 && ee(ii-1)>0 && tt(ii)-tt(ii-1)>ttgap
         fprintf(fee1,'%14.5f %12.5f\n',tt(ii-1),0); 
         fprintf(fee1,'>\n'); 
         fprintf(fee1,'%14.5f %12.5f\n',tt(ii),0); 
      end
      fprintf(fee1,'%14.5f %12.5f\n',tt(ii),ee(ii)); 
      if ii==pntNum || ee(ii+1)<=0
         fprintf(fee1,'%14.5f %12.5f\n',tt(ii),0); 
         fprintf(fee1,'>\n'); 
      end
   elseif ee(ii)<0
      if ii==1 || ee(ii-1)>=0
         fprintf(fee0,'%14.5f %12.5f\n',tt(ii),0); 
      end
      if ii>1 && ee(ii-1)<0 && tt(ii)-tt(ii-1)>ttgap
         fprintf(fee0,'%14.5f %12.5f\n',tt(ii-1),0); 
         fprintf(fee0,'>\n'); 
         fprintf(fee0,'%14.5f %12.5f\n',tt(ii),0); 
      end
      fprintf(fee0,'%14.5f %12.5f\n',tt(ii),ee(ii)); 
      if ii==pntNum || ee(ii+1)>=0
         fprintf(fee0,'%14.5f %12.5f\n',tt(ii),0); 
         fprintf(fee0,'>\n'); 
      end
   end

   % ---------- up ---------- 
   if uu(ii)>0
      if ii==1 || uu(ii-1)<=0
         fprintf(fuu1,'%14.5f %12.5f\n',tt(ii),0); 
      end
      if ii>1 && uu(ii-1)>0 && tt(ii)-tt(ii-1)>ttgap
         fprintf(fuu1,'%14.5f %12.5f\n',tt(ii-1),0); 
         fprintf(fuu1,'>\n'); 
         fprintf(fuu1,'%14.5f %12.5f\n',tt(ii),0); 
      end
      fprintf(fuu1,'%14.5f %12.5f\n',tt(ii),uu(ii)); 
      if ii==pntNum || uu(ii+1)<=0
         fprintf(fuu1,'%14.5f %12.5f\n',tt(ii),0); 
         fprintf(fuu1,'>\n'); 
      end
   elseif uu(ii)<0
      if ii==1 || uu(ii-1)>=0
         fprintf(fuu0,'%14.5f %12.5f\n',tt(ii),0); 
      end
      if ii>1 && uu(ii-1)<0 && tt(ii)-tt(ii-1)>ttgap
         fprintf(fuu0,'%14.5f %12.5f\n',tt(ii-1),0); 
         fprintf(fuu0,'>\n'); 
         fprintf(fuu0,'%14.5f %12.5f\n',tt(ii),0); 
      end
      fprintf(fuu0,'%14.5f %12.5f\n',tt(ii),uu(ii)); 
      if ii==pntNum || uu(ii+1)>=0
         fprintf(fuu0,'%14.5f %12.5f\n',tt(ii),0); 
         fprintf(fuu0,'>\n'); 
      end
   end
end


fclose(fnn1); fclose(fnn0);
fclose(fee1); fclose(fee0);
fclose(fuu1); fclose(fuu0);
