function [ mfitName ] = EQ_print_swbfit (mfitName,mfitmat,data,k)



fmfit = fopen (mfitName,'w');
mfitmat(:,8:10) = [];

fprintf (fmfit,'# Misfit DataFile for EQID: %s\n',data.EQID);
fprintf (fmfit,'#                     SIZE: BEST MFIT (%d) (SW)\n\n',k);

fprintf (fmfit,'# This file contains all the relevant misfit data for the abovementioned\n');
fprintf (fmfit,'# earthquake event.  This includes the following datasets:\n');
fprintf (fmfit,'#     - Absolute misfit (mm)\n');
fprintf (fmfit,'#     - Variance Explained (%%)\n');
fprintf (fmfit,'#     - Weighted Variance\n');
fprintf (fmfit,'#     - Kernel Density\n\n');

fprintf (fmfit,[ '# ii     ID      lon1 (d)   lat1 (d)' ...
    '   ' ... 
    'clon (d)   clat (d)   rake     varew (%%)\n']);

fprintf (fmfit,[ '  %-4d   %-5d   %-8.3f   %-7.3f' ...
    '    ' ...
    '%-8.3f   %-7.3f    %-6.1f   %-9.4f\n' ], mfitmat');

fclose(fmfit);

end