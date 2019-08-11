function EQ_print_flt3 (finput,data,EQin)

%                              EQ_print_flt3.m
%      EQ Function that Format Prints the Input for Fault Model Type 3
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function format prints the input for the fault variables according
% to the fault model of format type 3.
%
% Format type 3 requires the longitude and latitude coordinates of only the
% top-left corner of the fault-rupture, but requires the length and strike
% of the fault.  It requires only the rake of the slip and the total slip
% in the direction of the rake, and not the components of the total slip.
%
% INPUT:
% -- finput  : used to open the input file that was created by the function
%              EQ_open_inputpara1/2
% -- all fault variables
%
% OUTPUT:
% -- formatted print of the fault variables into the input file
%
% FORMAT OF CALL: EQ_print_flt3 (finput, ...
%                     flttype, fltName, ...
%                     lon, lat, z1, z2, len, str, dip, ...
%                     rake, rs, ts, rake0, rakeX, rs0, rsX, ts0, tsX, ...
%                     Nd, Ns)
%
% OVERVIEW:
% 1) This function will call the fault variables, and using finput which
%    opens the input file, the fault variables will be printed into the
%    input file.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
% 2) -- Final version validated and commented on 20190811 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf (finput,'# fault type  name');
fprintf (finput,'                  ');
fprintf (finput,'lon1 (d)    lat1 (d)');
fprintf (finput,'   ');
fprintf (finput,'z1 (m)    z2 (m)');
fprintf (finput,'    ');
fprintf (finput,'len (m)   str (d)   dip (d)');
fprintf (finput,'   ');
fprintf (finput,'rake (d)   rs (m)   ts (m)');
fprintf (finput,'   ');
fprintf (finput,'rake0 (m)   rakeX (m)   rs0 (m)');
fprintf (finput,'   ');
fprintf (finput,'rsX (m)   ts0 (m)   tsX (m)');
fprintf (finput,'   ');
fprintf (finput,'Nd   Ns\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fltName = data.EQID;
slon1 = EQin (6); slat1 = EQin(7);
z1 = EQin(10); z2 = EQin(11);
len = data.dgeo(1); str = EQin(12); dip = EQin(13);
rake = EQin(14); rs = EQin(15); ts = EQin(18);
rake0 = data.inv0(1); rakeX = data.invX(1);
rs0 = data.inv0(2); rsX = data.invX(2);
ts0 = data.inv0(5); tsX = data.invX(5);
invN = data.invN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf (finput,'  fault  3    %s',fltName);
fprintf (finput,'   ');
fprintf (finput,'%-9.4f   %-8.4f',slon1,slat1);
fprintf (finput,'   ');
fprintf (finput,'%-6.0f   %-6.0f',z1,z2);
fprintf (finput,'   ');
fprintf (finput,'%-5.0f   %-5.1f   %-5.1f',len,str,dip);
fprintf (finput,'   ');
fprintf (finput,'%-5.1f    %-7.4f   %-7.4f',rake,rs,ts);
fprintf (finput,'   ');
fprintf (finput,'%-4.1f      %-4.1f      %-4.1f',rake0,rakeX,rs0);
fprintf (finput,'      ');
fprintf (finput,'%-4.1f      %-4.1f      %-4.1f',rsX,ts0,tsX);
fprintf (finput,'      ');
fprintf (finput,'%-2d   %-2d\n\n',invN);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end