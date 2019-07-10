function [ euler ] = GPS_readeuler(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 GPS_readeuler.m                                       %
% read euler pole info                                                                  %
% Note: the number of lines is the first key to identifying different formats!!!        %
% if the values for some parameters are not given, use 0 instead.                       %
% pay particular attention to units!!!                                                  %
%                                                                                       %
% INPUT:                                                                                %
% Three formats are supported:	                                                        %
% (1) euler pole + translation (2x3 matrix)                                             %
%     poleLat,poleLon - location of rotation pole [deg]                                 %
%     omega  - angular velocity [deg/Myr]                                               %
%                                                                                       %
%     euler  = [ poleLat poleLon omega    ]     [deg,deg,deg/Myr]                       %
%     Trans  = [ Tx      Ty      Tz       ]     [mm/yr]	                                %
%                                                                                       %
% (2) rotation vector + errors + translation (4x3 matrix)                               %
%     omega  = sqrt(wx^2+wy^2+wz^2)                                                     %
%                                                                                       %
%     vector = [ wx    wy    wz    ]            [mas/a]	                            	%
%     errors = [ errwx errwy errwz ]            [mas/a]                                 %
%     Trans  = [ Tx    Ty    Tz    ]            [mm/yr]	                                %
%     errors = [ errTx errTy errTz ]            [mm/yr]                                 %
%                                                                                       %
% (3) euler pole + covariance matrix + translation (6x3 matrix)	                        %
%     euler  = [ poleLat poleLon omega  ]        [deg/Myr]                              %
%              [  Cxx     Cxy     Cxz   ]                                               %
%       Cw   = [  Cyx     Cyy     Cyz   ]        [rad^2/Myr^2]                          %
%              [  Czx     Czy     Czz   ]                                              	%
%     Trans  = [  Tx	  Ty	  Tz    ]        [mm/yr]                                %
%     errors = [  errTx	  errTy	  errTz ]        [mm/yr]                                %
%     Cw is the covariance matrix for angular velocity in xyz cartesian coordinate  	%
%        x - direction of (0N,0E) Greenwich                                             %
%        y - direction of (0N,90E)                                                      %
%        z - direction of 90N                                                           %
%        Cxx, Cyy, Czz - varicance  [rad^2/Myr^2]                                       %
%        Cxy, Cxz, Cyz - covariance [rad^2/Myr^2]                                       %
%     The ITRF geocentre CM (mass center including atmosphere, oceans, and ice sheets) 	%
%     is translating relative to the solid Earth centre CE                              %
%                                                                                       %
% OUTPUT: euler structure                                                               %
%     euler.lat     scale        [deg]                                                  %
%     euler.lon     scale        [deg]                                                  %
%     euler.omega   scale        [deg/Myr]                                              %
%     euler.wx  \                                                                       % 
%     euler.wy      vector       [rad/Myr]                                              %
%     euler.wz  /                                                                       %
%     euler.cw      3x3 matrix   [rad^2/Myr^2]                                          %
%     euler.Tx  \                                                                       %
%     euler.Ty      vector       [mm/yr]                                                %
%     euler.Tz  /                                                                       %
%     euler.errTx \                                                                     %
%     euler.errTy   vector       [mm/yr]                                                %
%     euler.errTz /                                                                     %
%                                                                                       %
% The reason of using rad/Myr is                                                        %
% v = w x r = w r sin(a) - [rad/Myr]*[km] = [km/Myr] = [mm/yr]                          %
%                                                                                       %
% first created by Lujia Feng Tue Mar  1 12:53:52 EST 2011                              %
% added translation lfeng Thu Mar  3 21:25:12 EST 2011                                  %
% added a new format lfeng Sat May 14 02:15:54 EDT 2011	                                %
% reorganized formats lfeng Tue Jun 18 11:08:55 SGT 2013                                %
% added translation errors lfeng Wed Jun 19 02:22:09 SGT 2013                           %
% last modified by Lujia Feng Wed Jun 19 03:45:48 SGT 2013                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readeuler ERROR: %s does not exist!',fileName); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fileName,'r');

%%%%%%%%%% read in %%%%%%%%%%%
eulerCell = textscan(fin,'%f %f %f','CommentStyle','#');	 % Delimiter default White Space
eulerMat  = cell2mat(eulerCell);
fclose(fin);

%%%%%%%%%% check if the format is right %%%%%%%%%%
if ~isequal(size(eulerMat),[2 3]) && ~isequal(size(eulerMat),[4 3]) && ~isequal(size(eulerMat),[6 3]), error('GPS_readeuler ERROR: The format of the euler file is wrong!'); end

% initialize euler structure
euler.lat = nan; euler.lon = nan; euler.omega = nan; 
euler.wx  = nan; euler.wy  = nan; euler.wz    = nan;
euler.Tx    = 0; euler.Ty    = 0; euler.Tz    = 0;
euler.errTx = 0; euler.errTy = 0; euler.errTz = 0;
euler.cw  = zeros(3,3);

% format (1)
if isequal(size(eulerMat),[2 3])
   euler.lat   = eulerMat(1,1);
   euler.lon   = eulerMat(1,2);
   euler.omega = eulerMat(1,3);
   euler.Tx    = eulerMat(2,1);  
   euler.Ty    = eulerMat(2,2);  
   euler.Tz    = eulerMat(2,3);  
   [wx,wy,wz]  = Euler2wxyzd(euler.lat,euler.lon,euler.omega);
   euler.wx    = wx;
   euler.wy    = wy;  
   euler.wz    = wz;  
end

% format (2)
if isequal(size(eulerMat),[4 3])
   wx = eulerMat(1,1); errwx = eulerMat(2,1);   
   wy = eulerMat(1,2); errwy = eulerMat(2,2);     
   wz = eulerMat(1,3); errwz = eulerMat(2,3);     
   [ euler.lat,euler.lon,euler.omega ] = wxyz2Eulerd(wx,wy,wz);
   % convert from [mas/a] to [rad/Myr]
   scale = 1e6/3600/1000*pi/180;
   wx = wx*scale;      errwx = errwx*scale;
   wy = wy*scale;      errwy = errwy*scale;
   wz = wz*scale;      errwz = errwz*scale;
   euler.wx = wx;
   euler.wy = wy;  
   euler.wz = wz;  
   euler.cw = [ errwx^2 0 0; 0 errwy^2 0; 0 0 errwz^2 ]; 
   euler.Tx    = eulerMat(3,1);  
   euler.Ty    = eulerMat(3,2);  
   euler.Tz    = eulerMat(3,3);  
   euler.errTx = eulerMat(4,1);  
   euler.errTy = eulerMat(4,2);  
   euler.errTz = eulerMat(4,3);  
end

% format (3)
if isequal(size(eulerMat),[6 3])
   euler.lat   = eulerMat(1,1);
   euler.lon   = eulerMat(1,2);
   euler.omega = eulerMat(1,3);
   [wx,wy,wz]  = Euler2wxyzd(euler.lat,euler.lon,euler.omega);
   euler.wx    = wx;
   euler.wy    = wy;  
   euler.wz    = wz;  
   euler.cw    = eulerMat(2:4,1:3);  
   euler.Tx    = eulerMat(5,1);  
   euler.Ty    = eulerMat(5,2);  
   euler.Tz    = eulerMat(5,3);  
   euler.errTx = eulerMat(6,1);  
   euler.errTy = eulerMat(6,2);  
   euler.errTz = eulerMat(6,3);  
end
