function [] = NIC_formdip(fin_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             NIC_formdip				  %	
% (1) form dip input for Nicoya 					  %
% (2) find the trench surface rojection along interface			  %
%                                                                         %
% use NIC_fitprofile.out (the output from NIC_fitprofile.m) as input      %
%								 	  %
% first created by Lujia Feng Mon Nov 29 04:32:24 EST 2010		  %
% added 200 km length trench lfeng Fri Dec 10 07:23:38 EST 2010		  %
% last modified by Lujia Feng Fri Dec 10 07:23:49 EST 2010		  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fault at trench = 160 km long
%lon1 = -85.52764597; lat1 =  9.00892686; 
%lon2 = -86.55827121; lat2 =  10.02534788;
% fault at trench = 200 km long
lon1 = -85.39900767;  lat1 = 8.88187545;
lon2 = -86.68729517;  lat2 = 10.15240176;
[~,ylen,~,~,~] = azim(lon1,lat1,lon2,lat2);

subfault_size = 5; 	% km

fprintf(1,'.......... reading %s ...........\n',fin_name);
fin = fopen(fin_name,'r');
data_cell = textscan(fin,'%f %f %f %f %f %f %f %f %f %f %f','CommentStyle','#');	 % Delimiter default White Space
model = cell2mat(data_cell);
fclose(fin); 

%p = a*d+b-m*d*d-n*d;

num = size(model,1);
for ii=1:num
    allrow = 0;
    a = model(ii,1); b = model(ii,2); m = model(ii,3); n = model(ii,4); p = model(ii,5); d = model(ii,6);
    fout_name = ['NIC_dis160km_dp100km_bend' num2str(d,'%2d') 'km.dip'];
    fout = fopen(fout_name,'w');
    fprintf(1,'.......... writing %s ...........\n',fout_name);
    fprintf(fout,'# (1) x<=d: a*x+b (2) x>d: m*x^2+n*x+p p=a*d+b-m*d^2-n*d\n# (1)a (2)b (3)m (4)n (5)p (6)d (7)sse (8)r2 (9)def (10)adj_r2 (11)rmse\n');
    fprintf(fout,'# %f  %f  %f  %f  %f  %f\t%f  %f  %f  %f  %f\n',a,b,m,n,p,d,model(ii,7),model(ii,8),model(ii,9),model(ii,10),model(ii,11));

    % linear
    dip = -atand(a);
    % an imaginary row to account for the difference between seafloor and sea level
    xshift = b/tand(dip)*1e3;
    xx = [ xshift xshift ]; yy = [ 0 ylen ]; rot = -45;
    [lon,lat] = ckm2LLd(xx,yy,lon1,lat1,rot);
    fprintf(fout,'# newlon1 newlat1 newlon2 newlat2\n# %-14.8f %-12.8f %14.8f %-12.8f\n',lon(1),lat(1),lon(2),lat(2));
    z1 = 0;  z2 = -b; rownum = 1;
    fprintf(fout,'dip  nicoya  %6.2f %14.6e %14.6e  %d\n',dip,z1*1e3,z2*1e3,rownum);
    allrow = allrow+rownum;
    % real subfault from trench
    x2 = d;  y2 = a*x2+b;
    z1 = z2; z2 = -y2;
    rownum = int32((z2-z1)/sind(dip)/subfault_size);
    fprintf(fout,'dip  nicoya  %6.2f %14.6e %14.6e  %d\n',dip,z1*1e3,z2*1e3,rownum);
    allrow = allrow+rownum;
    
    % quadratic
    ii = 2;
    rownum = 1;
    while z2<=60
       ii = ii+1;
       if ii>100, break; end
       x1 = x2; y1 = y2; z1 = z2;
       func = @(x) (x-x1)^2+(m*x^2+n*x+p-y1)^2-subfault_size^2;
       x2 = fzero(func,x1+1);
       if x2<x1, break; end
       y2 = m*x2^2+n*x2+p;
       dip = -atand((y2-y1)/(x2-x1));
       z2 = -y2;
       fprintf(fout,'dip  nicoya  %6.2f %14.6e %14.6e  %d\n',dip,z1*1e3,z2*1e3,rownum);
       allrow = allrow+rownum;
    end
    fprintf(fout,'# total rows  %d\n# total dips  %d\n',allrow,ii);
    fclose(fout);
end
