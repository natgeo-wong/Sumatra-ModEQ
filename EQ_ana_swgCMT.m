function EQ_ana_swgCMT(EQID,data,sites,vel,i,d)

%                                EQ_ana_sw

EQID  = strrep (EQID,'co','');
regID = data.type(5); mu = data.slip(2);
regname = EQ_create_printregname (regID);
File = [ EQID '_' regname '_' 'Rig' num2str(mu) '_swgCMT' ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PEAK 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd GTdef_SW_Misfit; mfitFiles = dir('*.txt');
[ jj,EQswmfit ] = EQ_ana_gmfitsw1 (mfitFiles,i); cd ..
cd GTdef_L_Misfit; mfitFiles = dir('*.txt');
[ EQlmfit ] = EQ_ana_mfitl (mfitFiles,i); cd ..
cd GTdef_SW_Input; EQinFiles = dir('*.txt');
[ lon1,lat1,EQin ] = EQ_ana_ins (EQinFiles,i,jj); cd ..

if exist('Analysis_ve2','dir') ~= 7; mkdir ('Analysis_ve2'); end
cd Analysis_ve2;
iFile = [ File '1' ];
[ Files ] = EQ_print_bfitFile (iFile,data,EQin,sites,vel);
GTdef(Files.in,0); GTdef_project(Files.out);
[ ~ ] = EQ_print_swgCMT (Files.fit,EQswmfit,data,1);
[ ~ ] = EQ_print_swgCMT (Files.fat,EQlmfit,data,1);
[ ~ ] = EQ_print_maxve2 (Files.mve,EQswmfit(jj,:),data,1);
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PEAK 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd GTdef_SW_Misfit; mfitFiles = dir('*.txt');
[ jj,EQswmfit ] = EQ_ana_gmfitsw2 (mfitFiles,i,lon1,lat1,d); cd ..
cd GTdef_L_Misfit; mfitFiles = dir('*.txt');
[ EQlmfit ] = EQ_ana_mfitl (mfitFiles,i); cd ..
cd GTdef_SW_Input; EQinFiles = dir('*.txt');
[ lon2,lat2,EQin ] = EQ_ana_ins (EQinFiles,i,jj); cd ..

if exist('Analysis_ve2','dir') ~= 7; mkdir ('Analysis_ve2'); end
cd Analysis_ve2;
iFile = [ File '2' ];
[ Files ] = EQ_print_bfitFile (iFile,data,EQin,sites,vel);
GTdef(Files.in,0); GTdef_project(Files.out);
[ ~ ] = EQ_print_swgCMT (Files.fit,EQswmfit,data,2);
[ ~ ] = EQ_print_swgCMT (Files.fat,EQlmfit,data,2);
[ ~ ] = EQ_print_maxve2 (Files.mve,EQswmfit(jj,:),data,2);
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PEAK 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd GTdef_SW_Misfit; mfitFiles = dir('*.txt');
[ jj,EQswmfit ] = EQ_ana_gmfitsw3 (mfitFiles,i,lon1,lat1,lon2,lat2,d); cd ..
cd GTdef_L_Misfit; mfitFiles = dir('*.txt');
[ EQlmfit ] = EQ_ana_mfitl (mfitFiles,i); cd ..
cd GTdef_SW_Input; EQinFiles = dir('*.txt');
[ ~,~,EQin ] = EQ_ana_ins (EQinFiles,i,jj); cd ..

if exist('Analysis_ve2','dir') ~= 7; mkdir ('Analysis_ve2'); end
cd Analysis_ve2;
iFile = [ EQID '_' regname '_' 'Rig' num2str(mu) '_swgCMT3' ];
[ Files ] = EQ_print_bfitFile (iFile,data,EQin,sites,vel);
GTdef(Files.in,0); GTdef_project(Files.out);
[ ~ ] = EQ_print_swgCMT (Files.fit,EQswmfit,data,3);
[ ~ ] = EQ_print_swgCMT (Files.fat,EQlmfit,data,3);
[ ~ ] = EQ_print_maxve2 (Files.mve,EQswmfit(jj,:),data,3);
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%