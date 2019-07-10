%                                EQ_create.m
%         Creates a general input file for any particular earthquake
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This script creates a EQ_datafile containing the details of an earthquake
% to be run through the EQ_ series of functions and scripts.  It calls as
% input the GTdef flttype and pnttype before adjusting the following calls
% for inputs accordingly.
%
% INPUT:
% -- 
%
% OUTPUT:
% -- General input (.eq) file that contains initial EQ parameters.
% -- Name of general input file "fEQfile" that can be called again and used
%    used to provide the input data if need be so there is no need to
%    manually input all the data again.
%
% FORMAT OF CALL: EQ_create
% 
% OVERVIEW:
% 1) This function will first ask for the format of the Fault Model and of
%    GPS Data that will be run through the entire equation.
%
% 2) This function will then call several functions for an input of the
%    fault parameters as required for the GTdef function. Estimates of some
%    of these parameters stored in the GCMT website, and others will be
%    calculated using regression models or through the interpolation of
%    Slab 1.0 data points.
%
%    -- type            : type of model the data will be run through
%    -- name            : name of fault / model in form "EQYYYYMMDD_MwX.XX"
%                       saved as the variable "fltName"
%
%    (for faults 1 and 3 only)
%    -- EQlon1          : longitude of epicenter (?)
%    -- EQlat1          : latitude of epicenter (?)
%
%    (for faults 2 and 4 only)
%    -- EQlon1          : longitude of fault endpoint 1 (?)
%    -- EQlat1          : latitude of fault endpoint 1 (?)
%    -- EQlon2          : longitude of fault endpoint 2 (?)
%    -- EQlat2          : latitude of fault endpoint 2 (?)
%
%    -- EQdepth         : vertical burial depth from surface (m)
%    -- z2              : vertical locking depth from the surface (m)
%
%    -- len             : subsurface rupture length (m)
%    -- width           : downslip rupture width (m)
%    -- str             : strike-angle of fault-rupture patch wrt north (?)
%    -- dip             : dip-angle of fault-rupture patch wrt surface (?)
%    -- rake            : rake of fault-rupture (?)
%    -- rake0           : minimum value of rake (?)
%    -- rakeX           : maximum value of rake (?)
%
%    -- rs              : rake-slip displacement
%    -- ss              : strike-slip displacement (m)
%    -- ds              : dip-slip displacement (m)
%    -- ts              : tensile-slip displacement (m)
%    -- rs0/ss0/ds0/ts0 : minimum value of respective displacements (m)
%    -- rsX/ssX/dsX/tsX : maximum value of respective displacements (m)
%
%    -- Nd              : number of patches along dip
%    -- Ns              : number of patches along slip
%
% 3) It will then save all these input parameters into an input file that
%    will be named with the appendix "_input.in" so as to indicate that it
%    is a raw input file that can be called for future use instead of
%    having to call the input parameters again multiple times.
%
%    The name of the general input file will also contain the following:
%    a) (RM) Regression model (WC, BKOS, SAB)
%    b) (RigYY) Magnitude of Rigidity (YY * 10^9 Pascals)
%
%    As such, the file name will have the following format:
%       "EQYYYYMMDD_MwX.XX_RM_RigYY_input.in"
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
%    -- Modified on 20160614
%    -- Added options for fault types 1 to 4 and point types 1 to 3 
%    -- Allows for the creation of different types of input files depending
%       on the data provided
%    -- Removed the unnecessary input of pnt and gps data.  This function
%       now creates a general input file of solely fault parameters
%
% 2) -- Final version validated on 20190419 by Nathanael Wong

%%%%%%%%%%%%%%%%% CHOOSING FAULT TYPE AND GPS DATA FORMAT %%%%%%%%%%%%%%%%%

EQtype = EQ_create_type; EQID = EQ_create_ID;

%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE FAULT GEOMETRY %%%%%%%%%%%%%%%%%%%%%%%%%%

EQdim  = EQ_create_dim  (EQID,EQtype);
EQgeom = EQ_create_geom (EQtype);
EQpos  = EQ_create_pos  (EQtype,EQdim,EQgeom);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE FAULT SLIP %%%%%%%%%%%%%%%%%%%%%%%%%%%%

EQslip = EQ_create_slip (EQID,EQdim);
EQinv  = EQ_create_inv  (EQtype);

%%%%%%%%%%% CREATION OF INPUT FILE CONTAINING FAULT PARAMETERS %%%%%%%%%%%%

EQFile = EQ_create_print (EQtype,EQID,EQdim,EQgeom,EQpos,EQslip,EQinv);
[ ~,EQname,~ ] = fileparts(EQFile);
if exist(EQname,'dir') ~= 7, mkdir(EQname); end
movefile (EQFile,EQname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%