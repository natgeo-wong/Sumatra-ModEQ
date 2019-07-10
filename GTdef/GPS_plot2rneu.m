function [] = GPS_plot2rneu(frneuName1,frneuName2)

% compare noise
% frneuName = 'SMT_res1site_NOISE.rneu';
% frneuName = 'SMT_clean_res1site_NOISE.rneu';

figName   = '';
figFlag   = 'on';
scaleIn   = 1;
scaleOut  = 1e-3;
lineCell  = { 'none' };
markCell  = { 'o'; 'o' };
sizeCell  = { 2; 2 };
colorCell = { 'r'; 'g' };

[ rneu1 ] = GPS_readrneu(frneuName1,scaleIn,scaleOut);
[ rneu2 ] = GPS_readrneu(frneuName2,scaleIn,scaleOut);
rneuCell = { rneu1; rneu2 };

GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,[],[],scaleOut);
