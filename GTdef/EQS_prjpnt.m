function [ ] = EQS_prjpnt(fout,pnt,flt_type,flt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EQS_prjpnt				  %
% Project microseismicity onto the main fault surface coordinate	  %
%									  %
% INPUT:					  		  	  %
%  pnt = [ pnt_lon pnt_lat pnt_z ]					  %
%  flt_type = 1 or 2, definition similar to GTdef			  %
%  fault1								  %
%  flt = [ lon0 lat0 z1   z2  len str dip ]     			  %
%  fault2								  %
%  flt = [ lon0 lat0 lon1 lat1 z1 z2  dip ]       			  %
%  process one fault each time						  %
%                                                                         %
% OUTPUT: (output to a file, the format is)				  %
% [ lon lat z Dstr1 Dstr2 Ddip Dvert ]					  %
%    Dstr1 - distance along fault strike from endpoint 1		  %
%            strike direction is positive				  %
%    Dstr2 - distance along fault strike from endpoint 2		  %
%            strike direction is negative				  %
%    Ddip -  distance along fault dip from the fault axis		  %
%    Dvert - distance vertically to the fault plane			  %
%    Dvert is not coded currently yet					  %
%                                                                         %
% Note: unit in [m]						          %
% first created by Lujia Feng Fri Dec 10 15:41:00 EST 2010		  %
% last modified by Lujia Feng Fri Dec 10 17:08:24 EST 2010		  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pnt_datanum = size(pnt,2); flt_num = size(flt);
if pnt_datanum~=3 | flt_num~=[1 7], error('Input for EQS_prjpnt is wrong!'); end

lon0 = flt(1); lat0 = flt(2);
switch flt_type
    case 1
        len = flt(5); str = flt(6); 
    case 2
        lon1 = flt(3); lat1 = flt(4);
        [~,len,~,str,~] = azim(lon0,lat0,lon1,lat1);
    otherwise
        error('Fault type is wrong!'); 
end
str
[pnt_xx,pnt_yy1] = LL2ckmd(pnt(:,1),pnt(:,2),lon0,lat0,-str);
pnt_yy2 = len-pnt_yy1;

out = [ pnt pnt_yy1 pnt_yy2 pnt_xx ]';
fprintf(fout,'%-14.8f %-12.8f %-10.4f %12.4e %12.4e %12.4e\n',out);
