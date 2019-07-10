%finName = '20100406_static_out.txt';
%colName = 'len=12000,wid=12000,clat,clon,depkm,slipcm,rake,str,dip';
%origin  = [ 99.9695   -4.2290 ];
%coord   = 'geo';
%outFlag = 'GTdef_topleft';
%[ newflt1,Nd,Ns ] = GTdef_read_geometry(finName,colName,origin,coord,outFlag);

finName = 'inverse2.input';
colName = 'clon,clat,depm,str,dip,len,wid';
origin  = [ 99.9695   -4.2290 ];
coord   = 'geo';
outFlag = 'relax';
[ newflt1,Nd,Ns ] = GTdef_read_geometry(finName,colName,origin,coord,outFlag);
