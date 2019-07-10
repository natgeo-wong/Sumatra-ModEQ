function EQ_bfit_analysis (evarmat,wvarmat,data)



[ ebest,ecount ] = max(evarmat(:,2)); [ wbest,wcount ] = max(wvarmat(:,2));
  eii  = evarmat(ecount,1);              wii  = wvarmat(wcount,1);
  elon = evarmat(ecount,3);              wlon = wvarmat(wcount,3);
  elat = evarmat(ecount,4);              wlat = wvarmat(wcount,4);

EQID = data.EQID; EQID = strrep (EQID,'co','');
regID = data.type(5); mu = data.slip(2);
regname = EQ_create_printregname (regID);

bfitName = [ EQID '_' regname '_' 'Rig' num2str(mu) '_' ...
             'bfit_co.txt' ];

fbfit = fopen (bfitName,'w');

fprintf (fbfit,'# BestFit DataFile for EQID: %s\n\n',data.EQID);

fprintf (fbfit,'# The bestfit data for variance-explained is:\n');
fprintf (fbfit,'#     - Lon (d): %.2f\n',elon);
fprintf (fbfit,'#     - Lat (d): %.2f\n',elat);
fprintf (fbfit,'#     - Var Explained (%%): %.2f\n',ebest);
fprintf (fbfit,'#     - Count: %d\n',ecount);
fprintf (fbfit,'#     - ii Count: %d\n\n',eii);

fprintf (fbfit,'# The bestfit data for weighted variance-explained is:\n');
fprintf (fbfit,'#     - Lon (d): %.2f\n',wlon);
fprintf (fbfit,'#     - Lat (d): %.2f\n',wlat);
fprintf (fbfit,'#     - Weighted Var Explained (%%): %.2f\n',wbest);
fprintf (fbfit,'#     - Count: %d\n',wcount);
fprintf (fbfit,'#     - ii Count: %d',wii);