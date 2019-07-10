function [amp,phase] = readhgt(infile,linelength,subset,flipflag,unit);
%   readhgt        - reads a hgt-amp file
% usage:  [a,p] = readhgt('infile',linelength);
%    or:  [a,p] = readhgt('infile',linelength,subset);
%    or:  [a,p] = readhgt('infile',linelength,subset,'flipud');
%    or:  [a,p] = readhgt('infile',linelength,[],'flipud');
% 
% reads a general hgt file for matlab,
%
%         extracts subset if given: 
%                  subset=[xmin ymin xpix ypix]
%         for subset=[100 100 200 300]  data(100:300,100:400) are extracted
%
% FA, last modified 3 Mar 99 
% FA, last modified 15 Mar 04  adding subset feature

str=pwd;
inpath=str;
% if left blank, will prompt user
if nargin == 0,
[infile, inpath] = uigetfile('',...
    'Select Data File', 0,0);
linelength = input('Give the linelength : ');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open binary file for reading
fid=fopen(infile,'r');

% read binary data as 32-bit float data
[F,count]=fread(fid,'float32');

nlines   = length(F)/(2*linelength);
recl     = 8 * linelength;

phase = zeros(nlines,linelength);
amp = zeros(nlines,linelength);

for line = 1:nlines,
   amp(line,:)  = F((line-1)*(2*linelength)+1:(line-1)*(2*linelength)+linelength)';
   phase(line,:)= F((line-1)*(2*linelength)+linelength+1 : line*(linelength*2))';
end

phase(find(amp==0))=nan;        % NaNs for non-unwrapped pixels

if exist('subset','var') && ~isempty(subset)
   xrange=[subset(1):subset(1)+subset(3)-1];
   yrange=[subset(2):subset(2)+subset(4)-1];
   phase=phase(yrange,xrange);
   amp=amp(yrange,xrange);
end
if exist('flipflag','var') && strmatch(flipflag,'flipud')
   phase=flipud(phase);
   amp=flipud(amp);
end
if exist('unit','var') && strmatch(unit,'meter')
  phase=phase./2/pi*0.02828;    % Range displacement in m
end
