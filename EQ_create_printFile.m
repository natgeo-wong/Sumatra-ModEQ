function EQFile = EQ_create_printFile (type,ID,pos,slip)

%                           EQ_create_printFile.m
%                EQ Function that creates the .eq file name
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of determining the file name
% based on event inputs
%
% INPUT:
% -- type : model input type information
% -- ID   : earthquake ID information
% -- pos  : event location/depth information
% -- slip : event displacement information
%
% OUTPUT:
% -- EQFile : .eq file name
%
% FORMAT OF CALL: EQ_create_printFile (type,ID,pos,slip)
% 
% OVERVIEW:
% 1) This function determines the filename of the .eq file and exports it
%    to the parent function
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

slab = type(3);  reg = type(5);
date = ID.ID(1); Mw  = ID.ID(2); depth = floor(pos.z(1)/1000);
name = EQ_create_printregname (reg); mu = slip.MME(2);

if any(slab == [1 1.1])
    EQFile = [ 'EQ' num2str(date) '_' ...
               'Mw' num2str(Mw,'%04.2f') '_' ...
               name '_' ...
               'Rig' num2str(mu) '_co.eq' ];
else
    EQFile = [ 'EQ' num2str(date) '_' ...
               'Mw' num2str(Mw,'%04.2f') '_' ...
               num2str(depth,'%02d') 'km' '_' ...
               name '_' ...
               'Rig' num2str(mu) '_co.eq' ];
end