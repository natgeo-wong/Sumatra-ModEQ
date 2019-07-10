function EQ_create_printType (fEQ,EQtype)



fprintf (fEQ, '# Type   flt   pnt   slab   evt   reg\n');
fprintf (fEQ, '  Type   %d     %d     %3.1f    %d     %d\n\n', EQtype);

end