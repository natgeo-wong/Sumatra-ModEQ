function xy = EQ_create_posxy (flt)

%                           EQ_input_fltcoord.m
%          EQ Function that defines input for fault coordinates
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of defining the coordinates of
% the fault rupture and can be used to create variables for all fault
% models that can be analysed in the EQ_ series of functions.
%
% For fault models 1 and 3, we will assume that EQlon1 and EQlat1 are the
% coordinates of the top-left fault-rupture endpoint.  Since for these
% models EQlon2 and EQlat2 will not be used we will assign these parameters
% to have value of NaN.
%
% For fault models 2 and 4, we will assume that EQlon1 and EQlat1 are the
% coordinates of the top-left fault-rupture endpoint and that EQlon2 and
% EQlat2 are the coordinates of the top-right endpoint.  These models are
% used only when we have aftershock data which will help to define the
% edges of the fault rupture.
%
% INPUT:
% -- flt : Type of Fault Model
%
% OUTPUT:
% -- xy  : (lon,lat) coordinates of the fault rupture endpoints at the
%    burial depth
%
% FORMAT OF CALL: EQ_create_posxy (fault model type)
% 
% OVERVIEW:
% 1) This calls as input the flttype in order to determine the appropriate
%    subfunctions to call to define the longitude and latitude coordinates
%    of the epicenter / fault-rupture endpoints.
%
% 2) The function will then call a subfunction to define the epicenter
%    depth, which we assume is vertical burial depth of the fault-rupture
%    at these particular longitude and latitude coordinates.
%
% 3) The subfunctions that are called will define the coordinates of the
%    fault depending on the flttype that was input and return these
%    coordinates as output.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
%    -- Modified on 20160615 by Nathanael Wong
%    -- Input of individual parameters are called by individual functions
%
%    -- Modified on 20160701 by Nathanael Wong
%    -- For fault types 1 & 3, EQlon1 and EQlat1 serve as the coordinates
%       of the epicenter
%    -- For fault types 2 & 4, the function will call for an input of the
%       epicenter coordinates in order to find the depth of the fault
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% IMPORT LONGITUDE AND LATITUDE %%%%%%%%%%%%%%%%%%%%%%

if flt == 1 || flt == 3
    
    disp ('Longitude is between -180 and 180')
	EQlon1 = input ('Recorded Longitude of Epicenter (d): ');
    disp (' ')
    while EQlon1 < -180 || EQlon1 > 180
        disp ('Error!  Longitude must be between -180 and 180')
        EQlon1 = input ('Recorded Longitude of Epicenter (d): ');
        disp (' ')
    end
    
    disp ('Latitude is between -90 and 90')
	EQlat1 = input ('Recorded Latitude of Epicenter (d): ');
    disp (' ')
    while EQlat1 < -180 || EQlon1 > 180
        disp ('Error!  Latitude must be between -90 and 90')
        EQlat1 = input ('Recorded Latitude of Epicenter (d): ');
        disp (' ')
    end
    
    EQlon2 = NaN; EQlat2 = NaN;
    
elseif flt == 2 || flt == 4
    
    disp ('Longitude is between -180? and 180?')
    EQlon1 = input ('Longitude of top-left Fault Endpoint (?): ');
    EQlon2 = input ('Longitude of top-right Fault Endpoint (?): ');
    disp (' ')

    while EQlon1 < -180 || EQlon1 > 180
        disp ('Error!  Longitude must be between -180? and 180?')
        EQlon1 = input ('Longitude of top-left Fault Endpoint (?): ');
        disp (' ')
    end
    while EQlon2 < -180 || EQlon2 > 180
        disp ('Error!  Longitude must be between -180? and 180?')
        EQlon2 = input ('Longitude of top-right Fault Endpoint (?): ');
        disp (' ')
    end
    
    disp ('Latitude is between -90? and 90?')
    EQlat1 = input ('Latitude of top-left Fault Endpoint (?): ');
    EQlat2 = input ('Latitude of top-right Fault Endpoint (?): ');
    disp (' ')

    while EQlat1 < -90 || EQlat1 > 90
        disp ('Error!  Latitude must be between -90? and 90?')
        EQlat1 = input ('Latitude of top-left Fault Endpoint (?): ');
        disp (' ')
    end
    while EQlat2 < -90 || EQlat2 > 90
        disp ('Error!  Latitude must be between -90? and 90?')
        EQlat2 = input ('Latitude of top-right Fault Endpoint (?): ');
        disp (' ')
    end
    
end
    
xy = [ EQlon1 EQlat1 EQlon2 EQlat2 ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end