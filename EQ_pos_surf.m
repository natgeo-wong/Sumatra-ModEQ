function possurf = EQ_pos_surf (pos,poszsd,data)



%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%

xyz = data.xyz;
lon = pos(:,1);     lat = pos(:,2);
z1  = poszsd (:,1); str = poszsd (:,3); dip = poszsd(:,4);

R_E = 6371e3;
hor = z1 ./ tand (dip);
ang = 180 - str;

%%%%%%%%%%%%%%%%%%% CALCULATING X- AND Y- DISPLACEMENTS %%%%%%%%%%%%%%%%%%%

ydisp = hor .* sind (ang); xdisp = hor .* cosd (ang);

%%%%%%%%%%%%% CALCULATING LONGITUDE / LATITUDE OF PROJECTION %%%%%%%%%%%%%%

latsurf1 = lat + ydisp ./ (2*pi*R_E) * 360;
lonsurf1 = lon + xdisp ./ (2*pi*R_E * cosd (lat)) * 360;

EQlon1 = xyz(1); EQlat1 = xyz(2); EQlon2 = xyz(3); EQlat2 = xyz(4);
latsurf2 = latsurf1 + (EQlat2 - EQlat1);
lonsurf2 = lonsurf1 + (EQlon2 - EQlon1);

possurf = [ lonsurf1 latsurf1 lonsurf2 latsurf2 ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end