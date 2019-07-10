function EQ_create_printSlip (fEQ,EQslip)



fprintf (fEQ, '# Slip   Rake    Rig');
fprintf (fEQ, '        ');
fprintf (fEQ, 'rSlip     dSlip     sSlip     tSlip\n');

fprintf (fEQ, '#        (d)     (N m^-2)');
fprintf (fEQ, '   ');
fprintf (fEQ, '(m)       (m)       (m)       (m)\n');

fprintf (fEQ, '  Slip   %-5.1f   %-2d', EQslip.MME);
fprintf (fEQ, '         ');
fprintf (fEQ, '%-7.4f   %-7.4f   %-7.4f   %-7.4f\n\n', EQslip.disp);

end