function [ veName ] = EQ_print_maxve1 (veName,vedata,data,k)



fmve = fopen (veName,'w');
vedata(:,10:11) = []; vedata(:,8) = [];

fprintf (fmve,'# Misfit DataFile for EQID: %s\n',data.EQID);
fprintf (fmve,'#                     SIZE: SV (%d)\n',k);
fprintf (fmve,'#\n');
fprintf (fmve,'# This file contains the relevant misfit data for the abovementioned\n');
fprintf (fmve,'# earthquake event.\n');
fprintf (fmve,'#\n');
fprintf (fmve,[ '# ii     ID      lon1 (d)   lat1 (d)' ...
    '   ' ... 
    'clon (d)   clat (d)   rake     vare (%%)\n']);

fprintf (fmve,[ '  %-4d   %-5d   %-8.3f   %-7.3f' ...
    '    ' ...
    '%-8.3f   %-7.3f    %-6.1f   %-9.4f\n' ], vedata');

fclose(fmve);

end