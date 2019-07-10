function EQ_create_printInvX (fEQ,X)



fprintf (fEQ, '# InvX   rakeX   rsX');
fprintf (fEQ, '       ');
fprintf (fEQ, 'dsX       ssX       tsX\n');

fprintf (fEQ, '#        (d)     (m)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(m)       (m)       (m)\n');

fprintf (fEQ, '  InvX   %-5.1f   %-7.4f', X(1:2));
fprintf (fEQ, '   ');
fprintf (fEQ, '%-7.4f   %-7.4f   %-7.4f\n\n', X(3:5));

end