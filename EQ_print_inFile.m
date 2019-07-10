function [ Files ] = EQ_print_inFile (ii,data,EQin,sites,vel)



EQID = data.EQID;
flt  = data.type(1); pnt = data.type(2);

Files.in  = {}; Files.out = {};
Files.pch = {}; Files.pnt = {}; Files.xsc = {};

Files.in  = [ EQID '_' num2str(ii) '.in' ];
Files.out = [ EQID '_' num2str(ii) '_fwd.out' ];
Files.pch = [ EQID '_' num2str(ii) '_fwd_patches.out' ];
Files.pnt = [ EQID '_' num2str(ii) '_fwd_point.out' ];
Files.xsc = [ EQID '_' num2str(ii) '_fwd_xsection.out' ];

fEQin = fopen (Files.in,'w');

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