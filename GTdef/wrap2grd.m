function [ ] = wrap2grd(AP,datafile,grdfile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% AP is 0=Amp or 1=Phase 
%%% datafile is input datafile in hgt format (must have an associated .rsc file
%%% grdfile is the output gmt grdfile
%%%%% AVN and JJ
%%% Last modified: Tue Nov 14 23:39:03 EST 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% addpath '/home/anewman/InSAR/matlab_common'
%%  datafile='geo_990915-991020-sim_ODR_4rlks.int';
%%  grdfile='geo_990915-991020-sim_ODR_4rlks.wrap.grd';
%%  datafile='test3.int';
%%  grdfile='test3.int.grd';
  str=pwd;
  inpath=str;

  rscfile=sprintf('%s%s',datafile,'.rsc');
  readforwrapped;
  [Amp,Phase]=readhgt(datafile,RSC_WIDTH);

  lon_max=[RSC_X_FIRST+RSC_XMAX*RSC_X_STEP];
  lon_min=[RSC_X_FIRST];
  lat_max=[RSC_Y_FIRST+RSC_YMAX*RSC_Y_STEP];
  lat_min=[RSC_Y_FIRST];
 
if AP == 1 
       Z_MAX=[max((max(Phase))')];
       Z_MIN=[min((min(Phase))')];
       % 1  could be a zero   (1 - pixel registration, 0 - grd node registration)
       D=[lon_min lon_max lat_min lat_max Z_MIN Z_MAX 0];
       grdwrite(Phase,D,grdfile);
  else
       Z_MAX=[max((max(Amp))')];
       Z_MIN=[min((min(Amp))')];
       % 1  could be a zero   (1 - pixel registration, 0 - grd node registration)
       D=[lon_min lon_max lat_min lat_max Z_MIN Z_MAX 0];
       grdwrite(Amp,D,grdfile);
 end 
