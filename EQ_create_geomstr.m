function str = EQ_create_geomstr (flt)

%                            EQ_input_geomstr.m
%         EQ Function that defines user input for the fault strike
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of determining the strike of the
% fault by user input.
%
% INPUT:
% -- flt : fault input type for model
%
% OUTPUT:
% -- str : fault strike
%
% FORMAT OF CALL: EQ_create_geomstr (model type)
%
% OVERVIEW:
% 1) This calls as input flt, which in GTdef expresses the type of fault
%    model input information required.
%
% 2) If flt is equal to 1 and 3, then the strike input is required.
%    Otherwise, flt is set to NaN.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%% IMPORT THE FAULT STRIKE %%%%%%%%%%%%%%%%%%%%%%%%%

if flt == 1 || flt == 3
    
    disp ('The value of strike ranges from 0 to 360.  All angles');
    disp ('measured are clockwise from north.');
    str = input ('Strike of Fault (d): ');
    disp (' ')
    while str(1) < 0 || str(1) > 360
        disp ('Error!  Strike must be between 0 to 360.');
        str = input ('Strike of Fault (d): ');
        disp (' ')
    end
    
elseif flt == 2 || flt == 4
    
    str = NaN;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end