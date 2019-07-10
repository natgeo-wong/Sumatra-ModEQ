function [ meshXX,meshYY,meshZZ ] = xyz2meshgrd(xx,yy,zz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      	     CUBIT_xyz2meshgrd.m                                %
% create mesh grid as output from Matlab meshgrid function using xyz data	%
%                                                                               %
% INPUT:                                                                        %
% xx,yy,zz - read xx,yy,zz data from xyz files [column vectors]			% 
%                                                                               %
% OUTPUT:                                                                       % 
% meshXX,meshYY,meshZZ  [matrix]						%
%                                                                               %
% related function: readxyz.m							%
% first created by lfeng Wed Sep 28 21:19:35 SGT 2011				%
% last modified by lfeng Thu Sep 29 11:32:55 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if xx,yy,zz have the same length
xxNum = length(xx); yyNum = length(yy); zzNum = length(zz);
if xxNum~=yyNum || xxNum~=zzNum || zzNum~=yyNum
   error('xyz2meshgrd ERROR: xx,yy,zz do not have the same length!');
end
num = xxNum;

% sort according to xx/lon first, next according to yy/lat 
meshXYZ = [ xx yy zz ];
meshXYZ = sortrows(meshXYZ,[1 2]);	
xx = meshXYZ(:,1); yy = meshXYZ(:,2); zz = meshXYZ(:,3);

% find out how many yys/lats
xxDiff = xx-xx(1,1);
ind = xxDiff==0;
yyNum = sum(ind);
if mod(num,yyNum)~=0
   error('xyz2meshgrd ERROR: yy cannot be converted to mesh format!');
end
xxNum = int32(num/yyNum);
meshXX = reshape(xx,yyNum,[]);
meshYY = reshape(yy,yyNum,[]);
meshZZ = reshape(zz,yyNum,[]);
meshZero = zeros(yyNum,xxNum);

% check if it's a qualified mesh
meshXXDiff = bsxfun(@minus,meshXX,meshXX(1,:));		% all rows - 1st row
if ~isequal(meshZero,meshXXDiff)
   error('xyz2meshgrd ERROR: xx cannot be converted to mesh format!');
end
meshYYDiff = bsxfun(@minus,meshYY,meshYY(:,1));		% all columns - 1st column
if ~isequal(meshZero,meshYYDiff)
   error('xyz2meshgrd ERROR: yy cannot be converted to mesh format!');
end
