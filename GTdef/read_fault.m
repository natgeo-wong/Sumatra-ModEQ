function [] = read_fault(h5Name)

% read hdf5 files for faults
% first created by lfeng Sat Feb  2 15:15:56 SGT 2013
% last modified by lfeng Sat Feb  2 17:24:26 SGT 2013

[ vertices,cells ] = PyLith_readhdf5_fault(h5Name);

% convert from local xyz to lonlat
%lon1 = 99.983234; 
%lat1 = -4.156308;
% trench point corresponding to maximum slip
lon0 = 99.460933;
lat0 = -3.56602;
rot  = 322.406483-360;

xx = vertices.loc(:,1);
yy = vertices.loc(:,2);
zz = vertices.loc(:,3);
[ lon,lat ] = ckm2LLd(xx,yy,lon0,lat0,rot);
slip = squeeze(vertices.slip);

% output
[ ~,basename,~ ] = fileparts(h5Name);
foutName = [ basename '.slip' ];
fout     = fopen(foutName,'w');
out      = [ lon lat zz slip ]';
fprintf(fout,'# slip distribution extracted from %s\n',h5Name);
fprintf(fout,'# (1)lon (2)lat (3)zz (4)leftlateral (5)reverse (6)opening [m]\n',h5Name);
fprintf(fout,'%14.9f %14.9f %12.4f   %15.8f %15.8f %15.8f\n',out);
fclose(fout);

% plot
close all;
figure;
plot3(xx,yy,slip(:,1),'or'); title('strike-slip');
figure;
plot3(xx,yy,slip(:,2),'or'); title('dip-slip');
figure;
plot3(xx,yy,slip(:,3),'or'); title('opening');
