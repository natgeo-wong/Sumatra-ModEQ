function cpos = EQ_cpos (fout)

%                                EQ_cpos.m
%       EQ Function that extracts the position of the patch centre
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function extracts the position of the patch centre from the GTdef
% output file
%
% INPUT:
% -- fout : GTdef output file
%
% OUTPUT:
% -- cpos : vector containing coordinates of patch centre
%           (lon,lat)
%
% FORMAT OF CALL: EQ_cpos (file)
%
% OVERVIEW:
% 1) This function take in as input the filename, opens the file, extracts
%    the patch centre positions, and exports it as output
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

[ cenlon,cenlat ] = textread(fout, ...
    [ '%*s %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f ' ...
      '%f %f %*f %*f %*f %*f %*f %*f %*f %*f' ], ...
      'commentstyle','shell');
  cpos = [ cenlon cenlat ];

end