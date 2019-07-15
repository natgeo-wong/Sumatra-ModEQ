function EQID = EQ_create_ID

%                              EQ_create_ID.m
%              EQ Function that defines the event ID and name
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of defining the name of the
% earthquake event based on its moment magnitude and date of occurrence.
%
% INPUT: N/A
%
% OUTPUT:
% -- EQID : ID information for earthquake
%
% FORMAT OF CALL: EQ_create_ID
% 
% OVERVIEW:
% 1) This function asks for user input for the date and the moment
%    magnitude of the event
%
% 2) The function then combines the two to give the earthquake name and
%    saves it as part of a structure
%
% 3) The function also then saves the magnitude and date into a vector for
%    export and ease of reference.
%
% VERSIONS:
% 1) -- Created on 20160615 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

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