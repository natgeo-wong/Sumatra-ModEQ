function [ inmat,outmat,mfitmat ] = EQ_run (ii,rakeii,data,pos,size,GPS)

%                                EQ_run.m
%                          Run Earthquake Model
%                    Nathanael Zhixin Wong, Lujia Feng
%
% This function hosts the GTdef (Georgia Tech Deformation) model and runs
% all the iterations of the model within the appointed grid.
%
% INPUT:
% -- ii     : run ID
% -- rakeii : rake direction for run
% -- data   : earthquake data loaded from file
% -- pos    : meshgrid information
% -- size   : size of the meshgrid
% -- GPS    : GPS information
%
% OUTPUT:
% -- inmat   : GTdef input for run
% -- outmat  : GTdef output for run
% -- mfitmat : misfit between modelled and observed displacements
%
% FORMAT OF CALL: EQ_run (runID,rake,EQdata,gridpos,size,GPS)
%
% VERSIONS:
% 1) -- Final version validated on 20190419 by Nathanael Wong

sites = GPS.sites; vel = GPS.vel;

count   = (1:size)';
rakevec = ones(size,1)*rakeii;
poszsd  = EQ_pos_zsd  (pos,data,size);
possurf = EQ_pos_surf (pos,poszsd,data);
slipvec = EQ_load_slipvec (rakeii,data,size);

% inmat = [ (1)count (2)lon1  (3)lat1  (4)lon2  (5)lat2 
%           (6)slon1 (7)slat1 (8)slon2 (9)slat2
%           (10)z1   (11)z2   (12)str  (13)dip  (14)rake ]
%           (15)rs   (16)ss   (17)ds   (18)ts ]
inmat = [ count pos possurf poszsd rakevec slipvec ];

mfitmat = zeros (size,10);
[ r,d_act,d_err ] = EQ_GPSread (vel,data); outmat = zeros (size,r);

for jj = 1 : size
    
    EQin = inmat (jj,:);
    [ Files ] = EQ_print_inFile (ii,data,EQin,sites,vel);
    
    z1 = EQin(10); dip = EQin(13);
    
    if z1 > 0 && round(dip,1) > 0
          GTdef(Files.in,0); GTdef_project(Files.out);
        [ d_out ] = EQ_out  (Files.out);
        [ cpos ]  = EQ_cpos (Files.pch);
    else
        [ d_out ] =   ones(1,r) * NaN;
        [ cpos ]  = [ NaN NaN ];
    end
    
    mfitmat(jj,1:3) = EQin(1:3); mfitmat(jj,4:5) = cpos;
    mfitmat(jj,6)   = EQin(14);
    
    d_out = reshape (d_out',1,r); outmat(jj,:) = d_out;
    
end

mfit    = EQ_mfit (outmat,r,d_act,d_err); mfitmat(:,7:10) = mfit;

iivec   = ones(size,1)*ii;
inmat   = [ iivec inmat ];
mfitmat = [ iivec mfitmat ];
outmat  = [ iivec count outmat ];

delete(Files.in);
if exist(Files.out,'file') == 2; delete(Files.out); end
if exist(Files.pch,'file') == 2; delete(Files.pch); end
if exist(Files.pnt,'file') == 2; delete(Files.pnt); end
if exist(Files.xsc,'file') == 2; delete(Files.xsc); end

end
