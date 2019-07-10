function [ r,d_act,d_err ] = EQ_GPSread (vel,data)

%                              EQ_GPSread.m
%              Load GPS data from the velocity and data type
%                    Nathanael Zhixin Wong, Lujia Feng
%
% This function extracts the GPS data from velocity vector based on the
% GPS datatype from the EQ datafile.
%
% INPUT:
% -- vec  : GPS velocity data
% -- data : earthquake data information
%
% OUTPUT:
% -- r     : dimensionality of GPS data
% -- d_act : observed GPS displacement
% -- d_err : errors in the GPS displacement
%
% FORMAT OF CALL: EQ_GPSread (vel,EQdata)
%
% VERSIONS:
% 1) -- Final version validated on 20190419 by Nathanael Wong


pnt = data.type(2);

if     pnt == 1, d_act = vel(:,4);   d_err = vel(:,5);   r = numel(d_act);
elseif pnt == 2, d_act = vel(:,4:5); d_err = vel(:,6:7); r = numel(d_act);
elseif pnt == 3, d_act = vel(:,4:6); d_err = vel(:,7:9); r = numel(d_act);
end

d_act = d_act/1000; d_err = d_err/1000;

end