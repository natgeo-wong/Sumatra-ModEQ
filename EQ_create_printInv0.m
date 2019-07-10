function EQ_create_printInv0 (fEQ,O)



fprintf (fEQ, '# Inv0   rake0   rs0');
fprintf (fEQ, '       ');
fprintf (fEQ, 'ds0       ss0       ts0\n');

fprintf (fEQ, '#        (d)     (m)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(m)       (m)       (m)\n');

fprintf (fEQ, '  Inv0   %-5.1f   %-7.4f', O(1:2));
fprintf (fEQ, '   ');
fprintf (fEQ, '%-7.4f   %-7.4f   %-7.4f\n\n', O(3:5));

end