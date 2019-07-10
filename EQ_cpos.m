function cpos = EQ_cpos (outFile)



[ cenlon,cenlat ] = textread (outFile, ...
    [ '%*s %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f ' ...
      '%f %f %*f %*f %*f %*f %*f %*f %*f %*f' ], ...
      'commentstyle','shell');
  cpos = [ cenlon cenlat ];

end