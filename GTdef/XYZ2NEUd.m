function [ NN,EE,UU,NNErr,EEErr,UUErr ] = XYZ2NEUd(lat0,lon0,XX,YY,ZZ,XXErr,YYErr,ZZErr,corXY,corXZ,corYZ)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert from changes in Earth Center Earth Fixed (ECEF) XYZ cartesian coordinate
% to changes in local tangent plane of NEU system
% The World Geodetic System 1984 (WGS84) ellipsoid (updated on GRS80) 
% The Geodetic Reference System 1980 (GRS80)
% Very small difference between WGS84 and GRS80
%
% INPUT:
% lon0, lat0 - starting point in geodetic coordinate 
%              from which the changes are calculated
% XX,YY,ZZ [m] in WGS84 or GRS80 ellipsoid system 
% XXErr,YYErr,ZZErr [m] - standard deviation                                         
% corXY,corXZ,corYZ     - correlation                                                
%              covXY                                                             
% corXY = ----------------                                                       
%            XXErr*YYErr                                                         
% They can be scalar, vector or matrix
%
% OUTPUT:
% NN,EE,UU [m] in local geodetic tangent plane
% NN - pointing north
% EE - pointing east
% UU - pointing up, normal to the ellipsoid
% NNErr,EEErr,UUErr [m]
%
% first created by Lujia Feng Thu Mar  3 13:25:35 EST 2011
% corrected miscalculation for east component lfeng Sat Jul 16 14:35:48 SGT 2011
% included error propagation lfeng Thu Mar 14 02:19:01 SGT 2013
% modified isequal lfeng Wed Jul  9 10:43:01 SGT 2014
% last modified by Lujia Feng Wed Jul  9 10:43:07 SGT 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sizexx = size(XX); sizeyy = size(YY); sizezz = size(ZZ);
if ~isequal(sizexx,sizeyy,sizezz)
    error('XX, YY, and ZZ are not consistent!'); 
end

TT = [ -sind(lat0)*cosd(lon0) -sind(lat0)*sind(lon0)  cosd(lat0);
            -sind(lon0)		    cosd(lon0)		0;
	cosd(lat0)*cosd(lon0)   cosd(lat0)*sind(lon0)  sind(lat0) ];

NEU = TT*[ XX YY ZZ ]';
NN = NEU(1,:); EE = NEU(2,:); UU = NEU(3,:);

% if errors considered
NNErr = zeros(size(NN)); 
EEErr = zeros(size(EE)); 
UUErr = zeros(size(UU));
if ~isempty(XXErr) && ~isempty(YYErr) && ~isempty(ZZErr) && ~isempty(corXY) && ~isempty(corXZ) && ~isempty(corYZ)
    for ii=1:length(XXErr)
        % clumsy way
        %covXX = XXErr(ii)^2;
        %covYY = YYErr(ii)^2;
        %covZZ = ZZErr(ii)^2;
        %covXY = corXY(ii)*XXErr(ii)*YYErr(ii); 
        %covXZ = corXZ(ii)*XXErr(ii)*ZZErr(ii);
        %covYZ = corYZ(ii)*YYErr(ii)*ZZErr(ii);
        %covmat = [ covXX covXY covXZ;
        %           covXY covYY covYZ;
        %           covXZ covYZ covZZ ];
        % smart way
        corMat = [ 1 corXY(ii) corXZ(ii); corXY(ii) 1 corYZ(ii); corXZ(ii) corYZ(ii) 1 ];
	errMat = diag([ XXErr(ii) YYErr(ii) ZZErr(ii) ]);
	covmat = errMat*corMat*errMat;
        NEUErr = TT*covmat*TT';
        NNErr(ii) = sqrt(NEUErr(1,1));
        EEErr(ii) = sqrt(NEUErr(2,2));
        UUErr(ii) = sqrt(NEUErr(3,3));
    end
end
