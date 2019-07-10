function EQ_create_printHead (fEQ,EQID)



fprintf (fEQ, '# Earthquake DataFile for EQID: %s\n', EQID.name);
fprintf (fEQ, '  EQID   %s\n\n', EQID.name);
fprintf (fEQ, '# This DataFile compiles all data for the EQ event, to be extracted\n');
fprintf (fEQ, '# by EQ_ series functions.  NaN is indicative that there is no need\n');
fprintf (fEQ, '# to extract these particular datapoints because they will be replaced\n');
fprintf (fEQ, '# or because they are not applicable to this particular flt type.\n\n');

end