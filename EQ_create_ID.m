function EQID = EQ_create_ID

%                              EQ_input_name.m
%             EQ Function that defines input for fault strike
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of defining the name of the
% earthquake event based on its moment magnitude and date of occurrence.
%
% INPUT:
% --
%
% OUTPUT:
% -- EQID : Name of the Earthquake
%
% FORMAT OF CALL: EQ_input_name (date, Mw)
% 
% OVERVIEW:
% 1) This function takes in the variables "date" and "Mw" before converting
%    them to strings.
%
% 2) The function will then string them together to form the earthquake
%    name.
%
% VERSIONS:
% 1) -- Created on 20160615 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% INITIALIZING "TYPE" STRUCTURE %%%%%%%%%%%%%%%%%%%%%%

EQID.ID = []; EQID.name = {};

%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE THE FAULT NAME %%%%%%%%%%%%%%%%%%%%%%%%%%

date = input ('Date of Earthquake (YYYYMMDD): ');
Mw   = input ('Moment Magnitude of Earthquake: ');
disp (' ');

EQID.name  = [ 'EQ' num2str(date) '_' ...
               'Mw' num2str(Mw,'%04.2f') 'co' ];
EQID.ID = [ date Mw ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end