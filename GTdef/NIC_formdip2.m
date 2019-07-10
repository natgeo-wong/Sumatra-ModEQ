function [] = NIC_formdip2()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             NIC_formdip				  %	
% Define the subduction interface for Nicoya Peninsula			  %
% using linear for shallow and quadratic for deep			  %
%									  %
% Independent Parameters: x						  %
% Coefficients: a,b,c,d							  %
% Dependent Parameters: y                                                 %
%                                                                         %
% first created by Lujia Feng Mon Nov 29 04:32:24 EST 2010		  %
% last modified by Lujia Feng Mon Nov 29 06:15:47 EST 2010		  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subfault_size = 4; 	% 4 km
% y = a*x+b; y = m*x^2+n*x+p
% short linear 120km
a = -0.267179;
b = -4.5;  
m = -0.007700;  
n = 0.789772; 
d = 43.173008;

% long linear 120km
%a = -0.213301;  
%b = -4.500000; 
%m = -0.007374; 
%n = 0.711849;
%d = 80.000000;

p = a*d+b-m*d*d-n*d;
fout = fopen('NIC_dip','w');
% 1.linear
dip = -atand(a);
x2 = d;
y2 = a*x2+b;
z1 = 0; z2 = -a*d;
rownum = int32(z2/sind(dip)/subfault_size);
fprintf(fout,'dip  nicoya  %5.1f %10.3e %10.3e  %d\n',dip,z1*1e3,z2*1e3,rownum);

% cut the top of quadratic
x1 = x2; y1 = y2; z1 = z2;
dip = 0;
x2 = d+2*(-0.5*n/m-d);
z1 = 0; z2 = -a*d;
rownum = int32(z2/sind(dip)/subfault_size);
fprintf(fout,'dip  nicoya  %5.1f %10.3e %10.3e  %d\n',dip,z1*1e3,z2*1e3,rownum);

% cut the top of quadratic
% quadratic
ii = 0;
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
   z2 = b-y2;
   fprintf(fout,'dip  nicoya  %5.1f %10.3e %10.3e  %d\n',dip,z1*1e3,z2*1e3,rownum);
end
fclose(fout);

