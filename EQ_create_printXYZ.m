function EQ_create_printXYZ (fEQ,EQpos)



fprintf (fEQ, '# XYZ    lon1       lat1');
fprintf (fEQ, '      ');
fprintf (fEQ, 'lon2       lat2');
fprintf (fEQ, '      ');
fprintf (fEQ, 'z1       z2\n');

fprintf (fEQ, '#        (d)        (d)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(d)        (d)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(m)      (m)\n');

fprintf (fEQ, '  XYZ    %-08.3f   %-07.3f   %-08.3f   %-07.3f', EQpos.xy);
fprintf (fEQ, '   ');
fprintf (fEQ, '%-06d   %-06d\n\n', EQpos.z);

end