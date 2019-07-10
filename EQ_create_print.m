function EQFile = EQ_create_print (EQtype,EQID,EQdim,EQgeom,EQpos,EQslip,EQinv)



EQFile = EQ_create_printFile (EQtype,EQID,EQpos,EQslip);
fEQ = fopen (EQFile,'w');

EQ_create_printHead (fEQ,EQID);
EQ_create_printType (fEQ,EQtype);
EQ_create_printXYZ  (fEQ,EQpos);
EQ_create_printDGeo (fEQ,EQdim,EQgeom);
EQ_create_printSlip (fEQ,EQslip);
EQ_create_printInv0 (fEQ,EQinv.O);
EQ_create_printInvX (fEQ,EQinv.X);
EQ_create_printInvN (fEQ,EQinv.N);

fclose (fEQ);

end