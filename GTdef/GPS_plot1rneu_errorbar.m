function [] = GPS_plot1rneu_errorbar(frneuName,Drange)

if nargin == 1  
   Drange = [ -Inf Inf ];
end

% comStr is '*.rneu'
figName   = '';
figFlag   = 'on';
scaleIn   = 1;
scaleOut  = 1e-3;
lineCell  = { };
markCell  = {'errorbar'};
sizeCell  = { 2 };
colorCell = { [0.5 0.5 0.5; 0 1 0] };

[ rneu ] = GPS_readrneu(frneuName,scaleIn,scaleOut);
ind = rneu(:,1)>=Drange(1) & rneu(:,1)<=Drange(2);
rneu = rneu(ind,:);
rneuCell = { rneu };
[ figh,axnh,axeh,axuh ] = GPS_plotNrneu(figName,figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,[],[],scaleOut);
set(gcf,'name',frneuName);
