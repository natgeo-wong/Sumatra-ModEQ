%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Lujia Feng                                             Feb 11, 2007
%  Computer the rate and azimuth of plate motion
%  using angular distance
%  -Knowns
%  1) average radius of the Earth: 6371km
%  2) location of a given point: lat(latitude) and lon(longitude)
%  3) location of Euler pole: pole_lat(latitude) and pole_lon(longitude)
%     rotation magnitude: omega(angular velocity) degree/Myr
%  -Unknowns
%  1) angular distance: delta [0,180]
%  2) azimuth of plate motion: mov_dir
%  3) rate of plate motion: mov_v  mm/yr
%  -Reference
%  1) The solid earth
%     C.M.R. Fowler P20
%  2) An introduction to seismology, earthquakes, and earth structure
%     Seth Stein and Michael Wysession P291
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[mov_v,mov_dir] = Euler2(lat,lon,pole_lat,pole_lon,omega)

R = 6371;
% degree to radian
lat = lat*pi/180;
lon = lon*pi/180;
pole_lat = pole_lat*pi/180;
pole_lon = pole_lon*pi/180;
omega = omega*pi/180;

%calculate the angular distance
b = 0.5*pi - lat;
c = 0.5*pi - pole_lat;
delta = acos(cos(b)*cos(c) + sin(b)*sin(c)*cos(lon - pole_lon))

%disp(delta*R);
%calculate the relative motion velocity(mm/yr)
mov_v = sin(delta)*R*omega;

%calculate the azimuth between location and pole(degree)
[zeta] = Azimuth(lat,lon,pole_lat,pole_lon,delta);
%calculate the relative motion direction(degree)
mov_dir = 90 + zeta;
if mov_dir>360
    mov_dir = mov_dir - 360;
end
