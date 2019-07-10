function EQ_ana(d)

%                                 EQ_ana

EQinFile = dir('*.eq'); EQinFile = EQinFile.name; data = EQ_read(EQinFile);
EQID = data.EQID; evt = data.type(4); xyz = data.xyz;
[ loopl ] = EQ_load_loopl (xyz);
[ sites,vel ] = GPS_readvel([EQID '.vel']);
fprintf('Analysing %s ... ',EQID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BESTFIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EQ_ana_svbfit(EQID,data,sites,vel,d); 
EQ_ana_swbfit(EQID,data,sites,vel,d);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

r = EQ_load_r (evt);
gCMTr = data.slip(1);
i = mod(mod((r-gCMTr),360)*10+901,3600);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GCMT BESTFIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EQ_ana_svgCMT(EQID,data,sites,vel,i,d);
EQ_ana_swgCMT(EQID,data,sites,vel,i,d);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SLICE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd GTdef_L_Misfit;  lFiles = dir('*.txt'); cd ..
cd GTdef_SW_Misfit; sFiles = dir('*.txt'); cd ..
data = zeros(12602,11,1801);

parfor ii = 1 : 1801
    
    iiL = lFiles(ii).name; iiS = sFiles(ii).name;
    L = textread(['./GTdef_L_Misfit/' iiL],'%f','commentstyle','shell');
    S = textread(['./GTdef_SW_Misfit/' iiS],'%f','commentstyle','shell');
    L = reshape(L,11,[])'; S = reshape(S,11,[])'; mat = [L ; S]
    
    data (:,:,ii) = mat;
    
end

X = data(:,5,:); Y = data(:,6,:); R = data(:,7,:); VE = data(:,11,:);
X = reshape(X,[],1); Y  = reshape(Y,[],1);
R = reshape(R,[],1); VE = reshape(VE,[],1);

minX = min(X); maxX = max(X); minY = min(Y); maxY = max(Y);
minR = min(R); maxR = max(R);

Y(isnan(X)) = []; R(isnan(X)) = []; VE(isnan(X)) = []; X(isnan(X)) = [];
data = [ X Y R ]; [data,ia,~] = unique(data,'rows');
X = data(:,1); Y = data(:,2); R = data(:,3);

[Xq,Yq,Rq] = meshgrid(minX:.05:maxX,minY:.05:maxY,minR:.1:maxR);
VEq = interp3(X,Y,R,VE(ia),Xq,Yq,Rq);

cd Analysis_ve2; pchF = dir('*_patches.out'); inF = dir('*.in');
parfor ii = 1 : 6
    iipch = pchF(ii).name; iiin = inF(ii).name;
    pchd = textread (iipch,'%s','commentstyle','shell');
    ind  = textread (iiin,  '%s','commentstyle','shell');
    x = str2num(pchd{16}); y = str2num(pchd{17}); r = str2num(ind{11});
    slice(Xq,Yq,Rq,VEq,x,y,r);
    shading flat
    saveas(gcf,['slice' num2str(ii)],'png');
end
cd ..

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Done!\n');