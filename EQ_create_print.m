function EQFile = EQ_create_print (type,ID,dim,geom,pos,slip,inv)

%                            EQ_create_print.m
%              EQ Function that creates and prints to .eq files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of printing the initial input
% information into .eq files, to be read and used for GTdef modelling
%
% INPUT: Earthquake event information
%
% OUTPUT:
% -- EQFile : name of .eq file created
%
% FORMAT OF CALL: EQ_create_print (type,ID,dim,geom,pos,slip,inv)
% 
% OVERVIEW:
% 1) This function creates and prints data to a .eq file
%
% 2) The name of the .eq file is exported to the parent script
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREATE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EQFile = EQ_create_printFile(type,ID,pos,slip); fEQ = fopen(EQFile,'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT DETAILS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EQ_create_printHead(fEQ,ID);
EQ_create_printType(fEQ,type);
EQ_create_printXYZ (fEQ,pos);
EQ_create_printDGeo(fEQ,dim,geom);
EQ_create_printSlip(fEQ,slip);
EQ_create_printInv0(fEQ,inv.O);
EQ_create_printInvX(fEQ,inv.X);
EQ_create_printInvN(fEQ,inv.N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CLOSE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose (fEQ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end