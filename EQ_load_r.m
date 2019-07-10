function r = EQ_load_r (evt)

%                              EQ_load_r.m
%    EQ Function that defines the default rake of the earthquake event
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the default rake for which an earthquake event
% of a given type will take.  This default rake will later be set as the
% centre of the rakes that will be looped through in the forward model.
%
% INPUT:
% -- evt : Event type
%
% OUTPUT:
% -- r : Default rake
%
% FORMAT OF CALL: EQ_load_r (event)
%
% OVERVIEW:
% 1) This function takes in the variable evt denoting the event type.
%
% 2) The function then returns the default rake for that event.
%
% VERSIONS:
% 1) -- Final version validated on 20190419 by Nathanael Wong

if evt == 1,     r = 0;
elseif evt == 2, r = 270;
elseif evt == 3, r = 180;
else,            r = 90;
end