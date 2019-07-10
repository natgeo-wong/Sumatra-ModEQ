function [ siteList,locfList,datfList,fitfList,eqsfList,noifList ] = GPS_readfiles(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_readfiles.m                                 %
% read *.files                                                                %
% only reads lines started with 4-letter site name                            %
% fields are separated by spaces                                              %
% it recognizes files according to extension                                  %
% so file order can be different, but extension is essential!                 %
% file names can include path                                                 %
%                                                                             %
% INPUT: *.files                                                              %
% 1     2              3                4                  5                  %
% Site  Site_Loc_File  Data_File        Fit_Param_File     EQ_File            %
% ABGS  SMT_IGS.sites  ABGS_clean.rneu  ABGS_clean.fitsum  ABGS.siteqs        %
% BTET  SMT_IGS.sites  BTET_clean.rneu  BTET_clean.fitsum  BTET.siteqs        %
% 6                                                                           %
% Noise_File                                                                  %
% ABGS_res1site.noisum                                                        %
% BTET_res1site.noisum                                                        %
%                                                                             %
% OUTPUT: all CELL, not String Arrays                                         %
% (1) siteList - site names stored as a cell                                  %
% (2) locfList - location file names                                          %
% (3) datfList - data file names                                              %
% (4) fitfList - initial fit parameter file names                             %
% (5) eqsfList - earthquake file names                                        %
% (6) noifList - noise summary file names                                     %
%                                                                             %
% first created by Lujia Feng Thu Jun 28 10:07:20 SGT 2012                    %
% used extension to distinguish files lfeng Sat Aug  4 14:59:23 SGT 2012      %
% added noise summary file noisum lfeng Mon Nov 25 17:33:19 SGT 2013          %
% changed eqs extension to siteqs lfeng Thu Feb 20 16:53:30 SGT 2014          %
% modified stdfst to accept file path lfeng Fri Feb 28 17:48:48 SGT 2014      %
% last modified by Lujia Feng 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readfiles ERROR: %s does not exist!',fileName); end

fin = fopen(fileName,'r');
stdfst = '^[^#]'; % \w = [a-zA-Z_0-9]
siteList = {};
locfList = {};
datfList = {};
fitfList = {};
eqsfList = {};
noifList = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with SITE
    isdata = regexp(tline,stdfst,'match');
    if ~isempty(isdata)
        [ siteName,remain ] = strtok(tline);
        siteList = [ siteList;siteName ];
        locName = 'none'; datName = 'none'; fitName = 'none'; 
	eqsName = 'none'; noiName = 'none';
        while(1)
            [ fname,remain ]  = strtok(remain);
            [ ~,~,ext ] = fileparts(fname);
            if strcmpi(ext,'.sites'),  locName = fname; end
            if strcmpi(ext,'.rneu'),   datName = fname; end
            if strcmpi(ext,'.fitsum'), fitName = fname; end
            if strcmpi(ext,'.siteqs'), eqsName = fname; end
            if strcmpi(ext,'.noisum'), noiName = fname; end
            if isempty(remain), break; end
        end
        locfList = [ locfList;locName ];
        datfList = [ datfList;datName ];
        fitfList = [ fitfList;fitName ];
        eqsfList = [ eqsfList;eqsName ];
        noifList = [ noifList;noiName ];
    end
end

fclose(fin);
