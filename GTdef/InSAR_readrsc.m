function [ rsc ] = InSAR_readrsc(frscName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              InSAR_readrsc.m				        %
% matlab program to read ROI_PAC resource file					%
% INPUT:									%
% frscName - resource file name							%
% example of *.unw.rsc file							%
%     WIDTH                                    888                           	%
%     FILE_LENGTH                              721                          	% 
%     XMIN                                     0                                %
%     XMAX                                     887                              %
%     YMIN                                     0                                %
%     YMAX                                     720                              %
%     X_FIRST                                  115.011666662                    %
%     X_STEP                                   0.000833333                  	% 
%     X_UNIT                                   degrees                          %
%     Y_FIRST                                  -8.050833333                     %
%     Y_STEP                                   -0.000833333                     %
%     Y_UNIT                                   degrees                          %
% NOTE:										%
% WIDTH - longitude; FILE_LENGTH - latitude					%
% first pixel convention: top left for *.unw; bottom left for GMT grid		%
% gridline registration for *.unw and GMT default				%
% nx = (xmax-xmin)/xinc+1; ny = (ymax-ymin)/yinc+1				%
%										%
% OUTPUT:									%
% rsc stucture includes fields							%
% width length xfirst yfirst xstep ystep xlast ylast zoffset zscale    		% 
%										%
% first created based on readrsc.m by Lujia Feng Wed Jun  9 18:52:33 EDT 2010	%
% last modified by lfeng Thu Oct 13 16:55:44 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(frscName,'file')  
    error('InSAR_readrsc ERROR: %s does not exist!',frscName); 
end

%%%%%%%%%% open the file %%%%%%%%%%
fprintf(1,'\n.......... InSAR_readrsc: reading %s ...........\n',frscName);
frsc = fopen(frscName,'r');

%%%%%%%%%% initialization %%%%%%%%%%
rsc.width   = nan; 
rsc.length  = nan; 
xmax        = nan;
ymax        = nan;
rsc.xfirst  = nan; 
rsc.yfirst  = nan; 
rsc.xstep   = nan; 
rsc.ystep   = nan; 
rsc.zoffset = nan; 
rsc.zscale  = nan;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    tline = fgetl(frsc);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % read the 1st term that is a flag for data type; could be some white-spaces before the 1st term
    [flag,remain] = strtok(tline);		% the default delimiter is white-space
    % omit '#' comment lines
    if strncmp(flag,'#',1), continue; end
    % read flags
    if strcmp(flag,'WIDTH')
	[rsc.width,remain] = GTdef_read1double(remain);
	continue
    end
    if strcmp(flag,'FILE_LENGTH')
	[rsc.length,remain] = GTdef_read1double(remain);
	continue
    end
    if strcmp(flag,'X_FIRST')
	[rsc.xfirst,remain] = GTdef_read1double(remain);
	continue
    end
    if strcmp(flag,'Y_FIRST')
	[rsc.yfirst,remain] = GTdef_read1double(remain);
	continue
    end
    if strcmp(flag,'X_STEP')
	[rsc.xstep,remain] = GTdef_read1double(remain);
	continue
    end
    if strcmp(flag,'Y_STEP')
	[rsc.ystep,remain] = GTdef_read1double(remain);
	continue
    end
    if strcmp(flag,'Z_OFFSET')
	[rsc.zoffset,remain] = GTdef_read1double(remain);
	continue
    end
    if strcmp(flag,'Z_SCALE')
	[rsc.zscale,remain] = GTdef_read1double(remain);
	continue
    end
end
% pixel registration
rsc.xlast = rsc.xfirst + (rsc.width-1)*rsc.xstep;
rsc.ylast = rsc.yfirst + (rsc.length-1)*rsc.ystep;
fclose(frsc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GTdef_read1double.m				%
% 	      function to read in one double number from a string		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ value,remain ] = GTdef_read1double(str)

[str1,remain] = strtok(str);
if isempty(str1)||strncmp(str1,'#',1)  
    error('The input file is wrong!');
end
value = str2double(str1);
