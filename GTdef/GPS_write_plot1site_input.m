function [] = GPS_write_plot1site_input(frneuName,finName,foutName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       GPS_write_plot1site_input.m                      %    
% write input for GMT script GPS_plot1site.gmt                           %
%                                                                        %	
% INPUT:                                                                 %
% finName   - a base file for GMT input                                  %
% frneuName - *.rneu all in [m]                                          %
% 1        2         3     4    5    6     7     8                       %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                   %
%                                                                        %
% OUTPUT:                                                                %
% foutName  - *.in                                                       %
%                                                                        %
% first created by Lujia Feng Tue Nov 24 11:30:30 SGT 2015               %
% last modified by Lujia Feng Tue Nov 24 22:38:56 SGT 2015               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... reading %s ...........\n',frneuName);
scaleIn  = 1;
scaleOut = 1e-2;
[ rneu ] = GPS_readrneu(frneuName,scaleIn,scaleOut);
startYear = floor(rneu(1,2));
endYear   = ceil(rneu(end,2));

minNN = floor(min(rneu(:,3)*0.1))*10;
maxNN = ceil(max(rneu(:,3)*0.1))*10;
minEE = floor(min(rneu(:,4)*0.1))*10;
maxEE = ceil(max(rneu(:,4)*0.1))*10;
minUU = floor(min(rneu(:,5)*0.1))*10;
maxUU = ceil(max(rneu(:,5)*0.1))*10;

% YWIDTH
totalY  = 17;
ywidth  = totalY*(maxNN-minNN)/(maxUU-minUU+maxEE-minEE+maxNN-minNN);
yorigin = 2+(totalY-ywidth);

% ANNOTATION
absnn = max(abs(minNN),abs(maxNN));
if absnn<=50
   nannot = 10;
elseif absnn>50 && absnn<=140
   nannot = 20;
else
   nannot = 50;
end

absee = max(abs(minEE),abs(maxEE));
if absee<=50
   eannot = 10;
elseif absee>50 && absee<=140
   eannot = 20;
else
   eannot = 50;
end

absuu = max(abs(minUU),abs(maxUU));
if absuu<=50
   uannot = 10;
elseif absuu>50 && absuu<=140
   uannot = 20;
else
   uannot = 50;
end

%%%%%%%%%%%%%%%%% write output %%%%%%%%%%%%%%%%%
if ~exist(finName,'file'), error('GPS_write_plot1site_input ERROR: %s does not exist!',filename); end

fin  = fopen(finName,'r');
fout = fopen(foutName,'w'); 

while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % read the 1st term that is a flag for data type; could be some white-spaces before the 1st term
    [flag,remain] = strtok(tline);		% the default delimiter is white-space
    % omit '#' comment lines
    % if strncmp(flag,'#',1), continue; end

    %%%%% origin %%%%%
    if strcmpi(flag,'YORIGIN')
        fprintf(fout,'YORIGIN         %.1f\n',yorigin);
    elseif strcmpi(flag,'YWIDTH')
        fprintf(fout,'YWIDTH          %.1f\n',ywidth);
    elseif strcmpi(flag,'XMIN')
        fprintf(fout,'XMIN            %.1f\n',startYear);
    elseif strcmpi(flag,'XMAX')
        fprintf(fout,'XMAX            %.1f\n',endYear);
    elseif strcmpi(flag,'NMIN')
        fprintf(fout,'NMIN            %.1f\n',minNN);
    elseif strcmpi(flag,'NMAX')
        fprintf(fout,'NMAX            %.1f\n',maxNN);
    elseif strcmpi(flag,'EMIN')
        fprintf(fout,'EMIN            %.1f\n',minEE);
    elseif strcmpi(flag,'EMAX')
        fprintf(fout,'EMAX            %.1f\n',maxEE);
    elseif strcmpi(flag,'UMIN')
        fprintf(fout,'UMIN            %.1f\n',minUU);
    elseif strcmpi(flag,'UMAX')
        fprintf(fout,'UMAX            %.1f\n',maxUU);
    elseif strcmpi(flag,'NANNOT')
        fprintf(fout,'NANNOT          %.1f\n',nannot);
    elseif strcmpi(flag,'EANNOT')
        fprintf(fout,'EANNOT          %.1f\n',eannot);
    elseif strcmpi(flag,'UANNOT')
        fprintf(fout,'UANNOT          %.1f\n',uannot);
    else
        fprintf(fout,'%s\n',tline);
    end
end
fclose(fin); fclose(fout);
