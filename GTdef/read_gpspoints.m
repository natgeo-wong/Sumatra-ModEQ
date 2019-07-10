function [] = read_gpspoints(h5Name,xyzName)

% read hdf5 files for specific gps stations
% name files give name information
% functions used: ckm2LLd.m & GPS_readsites.m
% first created by lfeng Tue Jan 29 18:05:35 SGT 2013
% last modified by lfeng Sat Feb  2 15:02:33 SGT 2013

[ gpsites ] = PyLith_readhdf5_pnts(h5Name);
[ sitesName,sitesLoc,~ ] = GPS_readsites(xyzName,4);

% convert from local xyz to lonlat
%lon1 = 99.983234; 
%lat1 = -4.156308;
% trench point corresponding to maximum slip
lon0 = 99.460933;
lat0 = -3.56602;

rot = 322.406483-360;

cos_rot = cosd(rot);        % cos_rot - cos of rotation angle
sin_rot = sind(rot);        % sin_rot - sin of rotation angle

xxin  = sitesLoc(:,1);    yyin  = sitesLoc(:,2);    zzin  = sitesLoc(:,3);     % input into PyLith
xxout = gpsites.loc(:,1); yyout = gpsites.loc(:,2); zzout = gpsites.loc(:,3); % output from PyLith
% reorder gps sites according to PyLith input because PyLith randomizes them 
newInd = zeros(gpsites.num,1);
for ii=1:gpsites.num
    dist = sqrt((xxin(ii)-xxout).^2+(yyin(ii)-yyout).^2);
    [ ~,ind ] = sort(dist);
    newInd(ii) = ind(1);
end
xxout = xxout(newInd);
yyout = yyout(newInd);
zzout = zzout(newInd);
[ lon,lat ] = ckm2LLd(xxout,yyout,lon0,lat0,rot);

% reorder & m -> mm
%scale = 1e2;
scale = 1;
dispxx = scale*gpsites.disp(1,newInd,1)';
dispyy = scale*gpsites.disp(1,newInd,2)';
dispzz = scale*gpsites.disp(1,newInd,3)';
% rotate displacement x y back to east & west
ee =  dispxx*cos_rot + dispyy*sin_rot;
nn = -dispxx*sin_rot + dispyy*cos_rot;
uu =  dispzz;

% output
[~,basename,~] = fileparts(h5Name);
foutName = [ basename '.vel' ];
fout     = fopen(foutName,'w');
out      = [ lon lat zzout ee nn uu ];
for ii=1:gpsites.num
    fprintf(fout,'%4s %14.9f %14.9f %12.4f  %12.5f %12.5f %12.5f\n',sitesName{ii},out(ii,:));
end
fclose(fout);
