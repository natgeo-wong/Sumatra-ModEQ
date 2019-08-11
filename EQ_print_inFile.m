function [ fID ] = EQ_print_inFile (ii,data,EQin,sites,vel)

%                            EQ_print_inFile.m
%           EQ Function that defines the names of the input files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function defines the names of the various EQ files that are used
% during the earthquake model run.  The function then creates an input file
% based on the imported data for the earthquake event.
%
% INPUT:
% -- ii    : run ID for rake
% -- data  : information on the earthquake event
% -- EQin  : earthquake fault input information
% -- sites : GPS station input information
% -- vel   : GPS displacement information
%
% OUTPUT:
% -- fID   : structure containing information on file names
%
% FORMAT OF CALL: EQ_print_bfitFile (name,data,EQin,sites,vel)
% 
% OVERVIEW:
% 1) This function extracts information on the GTdef-fault and GPS
%    information type
%
% 2) The function then creates the filenames for the respective earthquake
%
% 3) The function then creates an input file based on the information for
%    the earthquake imported from the parent function.
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190811 by Nathanael Wong

EQID = data.EQID;
flt  = data.type(1); pnt = data.type(2);

fID.in  = {}; fID.out = {};
fID.pch = {}; fID.pnt = {}; fID.xsc = {};

fID.in  = [ EQID '_' num2str(ii) '.in' ];
fID.out = [ EQID '_' num2str(ii) '_fwd.out' ];
fID.pch = [ EQID '_' num2str(ii) '_fwd_patches.out' ];
fID.pnt = [ EQID '_' num2str(ii) '_fwd_point.out' ];
fID.xsc = [ EQID '_' num2str(ii) '_fwd_xsection.out' ];

fEQin = fopen (fID.in,'w');

if     flt == 1, EQ_print_flt1 (fEQin,data,EQin);
elseif flt == 2, EQ_print_flt2 (fEQin,data,EQin);
elseif flt == 3, EQ_print_flt3 (fEQin,data,EQin);
elseif flt == 4, EQ_print_flt4 (fEQin,data,EQin);
end

if     pnt == 1, EQ_print_pnt1 (fEQin,sites,vel);
elseif pnt == 2, EQ_print_pnt2 (fEQin,sites,vel);
elseif pnt == 3, EQ_print_pnt3 (fEQin,sites,vel);
end

fclose (fEQin);

end