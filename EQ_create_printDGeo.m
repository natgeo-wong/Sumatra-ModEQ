function EQ_create_printDGeo (fEQ,EQdim,EQgeom)



fprintf (fEQ, '# DGeo   Len      Wid      Area');
fprintf (fEQ, '           ');
fprintf (fEQ, 'Str     Dip\n');

fprintf (fEQ, '#        (m)      (m)      (m^2)');
fprintf (fEQ, '          ');
fprintf (fEQ, '(d)     (d)\n');

fprintf (fEQ, '  DGeo   %-6.0f   %-6.0f   %-e', EQdim);
fprintf (fEQ, '   ');
fprintf (fEQ, '%-5.1f   %-4.1f\n\n', EQgeom);

end