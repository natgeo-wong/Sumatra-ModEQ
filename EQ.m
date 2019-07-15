%                                  EQ
%                       Earthquake Modelling Scipt
%                    Nathanael Zhixin Wong, Lujia Feng
%
% This is the master file for the Earthquake Modelling Script.  It triggers
% everything from retrieval of earthquake parameters, to the importing of
% GPS and loading of the subsurface data, to the running of the actual
% model over all known parameters, to the analysis and retrieval of the
% bestfit location and parameters.
%
% INPUT:
% -- N/A
%
% OUTPUT:
% -- Datafiles containing model runs at each point and their misfits
% -- Bestfit locations based on forward models
%
% VERSIONS:
% 1) -- Final Version validated on 20190419 by Nathanael Wong

EQFile = dir('*.eq'); EQFile = EQFile.name; data = EQ_read(EQFile);

strName = strsplit(EQFile,'_'); EQstr = strName{1}; Mwstr = strName{2};
slab = data.type(3); evt = data.type(4); xyz = data.xyz;

disp ('Importing GPS Data ...');
  GPS.sites = {}; GPS.vel = [];
[ GPS.sites, GPS.vel ] = GPS_readvel([EQstr '_' Mwstr 'co.vel']);
disp ('Import completed.');
disp (' ');

[ z,s,d ] = EQ_load_zsd (slab);
[   r   ] = EQ_load_r (evt);
[ loopl ] = EQ_load_loopl (xyz);

  data.z = z; data.s = s; data.d = d; data.r = r;

if exist('GTdef_L_Input','dir') ~= 7,   mkdir ('GTdef_L_Input');   end
if exist('GTdef_L_Output','dir') ~= 7,  mkdir ('GTdef_L_Output');  end
if exist('GTdef_L_Misfit','dir') ~= 7,  mkdir ('GTdef_L_Misfit');  end
if exist('GTdef_SW_Input','dir') ~= 7,  mkdir ('GTdef_SW_Input');  end
if exist('GTdef_SW_Output','dir') ~= 7, mkdir ('GTdef_SW_Output'); end
if exist('GTdef_SW_Misfit','dir') ~= 7, mkdir ('GTdef_SW_Misfit'); end
if exist('GTdef_SV_Input','dir') ~= 7,  mkdir ('GTdef_SV_Input');  end
if exist('GTdef_SV_Output','dir') ~= 7, mkdir ('GTdef_SV_Output'); end
if exist('GTdef_SV_Misfit','dir') ~= 7, mkdir ('GTdef_SV_Misfit'); end

evarmat = zeros(1801,4); wvarmat = zeros(1801,4);

if isempty(gcp('nocreate')), parpool(23); end
parfor ii = 1 : 1801
    
       r = data.r; rakeii = r - (ii-901)/10;
    [  xx  ] = num2str(ii,'%04d');
    
    if exist(['Temp' xx],'dir') ~= 7, mkdir (['Temp' xx]); end
    cd (['Temp' xx]);
    
    tic
    [ lpos ] = loopl.pos1; %#ok<*PFBNS>
    [ size ] = loopl.size(1);
    [ ~,~,lmfitmat ] = EQ_run (ii,rakeii, data,lpos,size, GPS);
    [ evar,wvar ] = EQ_mfit_pos (lmfitmat);
    time1 = toc;
    
    tic
    [ size,spos ] = EQ_load_loops (evar.lon,evar.lat,xyz);
    [ inmat,outmat,smfitmat ] = EQ_run (ii,rakeii, data,spos,size, GPS);
    [ evar,~ ] = EQ_mfit_pos (smfitmat);
    
      insvFile   = EQ_print_insv   (xx,inmat,data);
      outsvFile  = EQ_print_outsv  (xx,outmat,data,GPS);
      mfitsvFile = EQ_print_mfitsv (xx,smfitmat,data);
    
    movefile (insvFile,  '../GTdef_SV_Input/');
    movefile (outsvFile, '../GTdef_SV_Output/');
    movefile (mfitsvFile,'../GTdef_SV_Misfit/');
    time2 = toc;
    
    tic
    [ size,spos ] = EQ_load_loops (wvar.lon,wvar.lat,xyz);
    [ inmat,outmat,smfitmat ] = EQ_run (ii,rakeii, data,spos,size, GPS);
    [ ~,wvar ] = EQ_mfit_pos (smfitmat);
      inswFile   = EQ_print_insw   (xx,inmat,data);
      outswFile  = EQ_print_outsw  (xx,outmat,data,GPS);
      mfitswFile = EQ_print_mfitsw (xx,smfitmat,data);
    
    movefile (inswFile,  '../GTdef_SW_Input/');
    movefile (outswFile, '../GTdef_SW_Output/');
    movefile (mfitswFile,'../GTdef_SW_Misfit/');
    time3 = toc;
    
    tic
    [ lpos ] = loopl.pos2;
    [ size ] = loopl.size(2); 
    [ inmat,outmat,lmfitmat ] = EQ_run (ii,rakeii, data,lpos,size, GPS);
      inlFile    = EQ_print_inl   (xx,inmat,data);
      outlFile   = EQ_print_outl  (xx,outmat,data,GPS);
      mfitlFile  = EQ_print_mfitl (xx,lmfitmat,data);
    
    movefile (inlFile,   '../GTdef_L_Input/');
    movefile (outlFile,  '../GTdef_L_Output/');
    movefile (mfitlFile, '../GTdef_L_Misfit/');
    time4 = toc;
    
    ttime = time1 + time2 + time3 + time4;
    
    fprintf ([ 'PROCESSED EQID: %s | COUNTID : %04d | TOTAL ELAPSED TIME: %.4f sec\n' ...
               '    SIZE: L1 | ELAPSED TIME: %.4f sec\n' ...
               '    SIZE: SV | ELAPSED TIME: %.4f sec\n' ...
               '    SIZE: SW | ELAPSED TIME: %.4f sec\n' ...
               '    SIZE: L2 | ELAPSED TIME: %.4f sec\n\n' ], ...
               data.EQID,ii,ttime,time1,time2,time3,time4);
    
    cd ../
    if exist(['Temp' xx],'dir') == 7, rmdir (['Temp' xx]); end
    
    evarmat(ii,:) = [ evar.ii evar.best evar.lon evar.lat ];
    wvarmat(ii,:) = [ wvar.ii wvar.best wvar.lon wvar.lat ];
    
end
delete(gcp('nocreate'));

EQ_bfit_analysis (evarmat,wvarmat,data);