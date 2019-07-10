function EQ_ana_svgCMT(EQID,data,sites,vel,i,d)

%                                EQ_ana_sv

EQID  = strrep (EQID,'co','');
regID = data.type(5); mu = data.slip(2);
regname = EQ_create_printregname (regID);
File = [ EQID '_' regname '_' 'Rig' num2str(mu) '_svgCMT' ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PEAK 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd GTdef_SV_Misfit; mfitFiles = dir('*.txt');
[ jj,EQsvmfit ] = EQ_ana_gmfitsv1 (mfitFiles,i); cd ..
cd GTdef_L_Misfit; mfitFiles = dir('*.txt');
[ EQlmfit ] = EQ_ana_mfitl (mfitFiles,i); cd ..
cd GTdef_SV_Input; EQinFiles = dir('*.txt');
[ lon1,lat1,EQin ] = EQ_ana_ins (EQinFiles,i,jj); cd ..

if exist('Analysis_ve1','dir') ~= 7; mkdir ('Analysis_ve1'); end
cd Analysis_ve1;
iFile = [ File '1' ];
[ Files ] = EQ_print_bfitFile (iFile,data,EQin,sites,vel);
GTdef(Files.in,0); GTdef_project(Files.out);
[ ~ ] = EQ_print_svgCMT (Files.fit,EQsvmfit,data,1);
[ ~ ] = EQ_print_svgCMT (Files.fat,EQlmfit,data,1);
[ ~ ] = EQ_print_maxve1 (Files.mve,EQsvmfit(jj,:),data,1);
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PEAK 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd GTdef_SV_Misfit; mfitFiles = dir('*.txt');
[ jj,EQsvmfit ] = EQ_ana_gmfitsv2 (mfitFiles,i,lon1,lat1,d); cd ..
cd GTdef_L_Misfit; mfitFiles = dir('*.txt');
[ EQlmfit ] = EQ_ana_mfitl (mfitFiles,i); cd ..
cd GTdef_SV_Input; EQinFiles = dir('*.txt');
[ lon2,lat2,EQin ] = EQ_ana_ins (EQinFiles,i,jj); cd ..

if exist('Analysis_ve1','dir') ~= 7; mkdir ('Analysis_ve1'); end
cd Analysis_ve1; 
iFile = [ File '2' ];
[ Files ] = EQ_print_bfitFile (iFile,data,EQin,sites,vel);
GTdef(Files.in,0); GTdef_project(Files.out);
[ ~ ] = EQ_print_svgCMT (Files.fit,EQsvmfit,data,2);
[ ~ ] = EQ_print_svgCMT (Files.fat,EQlmfit,data,2);
[ ~ ] = EQ_print_maxve1 (Files.mve,EQsvmfit(jj,:),data,2);
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PEAK 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd GTdef_SV_Misfit; mfitFiles = dir('*.txt');
[ jj,EQsvmfit ] = EQ_ana_gmfitsv3 (mfitFiles,i,lon1,lat1,lon2,lat2,d); cd ..
cd GTdef_L_Misfit; mfitFiles = dir('*.txt');
[ EQlmfit ] = EQ_ana_mfitl (mfitFiles,i); cd ..
cd GTdef_SV_Input; EQinFiles = dir('*.txt');
[ ~,~,EQin ] = EQ_ana_ins (EQinFiles,i,jj); cd ..

if exist('Analysis_ve1','dir') ~= 7; mkdir ('Analysis_ve1'); end
cd Analysis_ve1;
iFile = [ File '3' ];
[ Files ] = EQ_print_bfitFile (iFile,data,EQin,sites,vel);
GTdef(Files.in,0); GTdef_project(Files.out);
[ ~ ] = EQ_print_svgCMT (Files.fit,EQsvmfit,data,3);
[ ~ ] = EQ_print_svgCMT (Files.fat,EQlmfit,data,3);
[ ~ ] = EQ_print_maxve1 (Files.mve,EQsvmfit(jj,:),data,3);
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%