function [ v_ns,v_ew,mov_v,mov_dir ] = Euler1(lat,lon,pole_lat,pole_lon,omega)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Lujia Feng                                             Feb 11, 2007
%  Computer the rate and azimuth of plate motion
%  using NS and EW velocities
%  -Knowns
%  1) average radius of the Earth: 6371km
%  2) location of a given point: lat(latitude) and lon(longitude)
%  3) location of Euler pole: pole_lat(latitude) and pole_lon(longitude)
%     rotation magnitude: omega(angular velocity) degree/Myr
%  -Unknowns
%  1) rate of plate motion: mov_v  mm/yr
%  2) azimuth of plate motion: mov_dir
%  -Reference
%  1) An introduction to seismology, earthquakes, and earth structure
%     Seth Stein and Michael Wysession P291
%  2) The solid earth
%     C.M.R. Fowler P20
% last modified by lfeng Wed Nov  3 20:25:13 EDT 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R = 6371;
% degree to radian
omega = omega*pi/180;

%calculate north-south and east-west velocity(km/Myr=mm/yr)
v_ns = R*omega*cosd(pole_lat)*sind(lon-pole_lon);
v_ew = R*omega*(sind(pole_lat)*cosd(lat)-cosd(pole_lat)*sind(lat)*cosd(lon-pole_lon));

%calculate the rate/velocity of motion(mm/yr)
mov_v = sqrt(v_ns^2+v_ew^2);

%calculate the azimuth of motion(degree)
if(v_ew>=0)
    mov_dir = 90 - atan(v_ns/v_ew)*180/pi;
else
    mov_dir = 270 - atan(v_ns/v_ew)*180/pi;
end
