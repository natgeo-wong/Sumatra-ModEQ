function [ dataset_exists ] = hdf5_exists(filename,dataset_name)

% Copyright (c) 2011,2012 Ilker R Capoglu 
% Returns true if the dataset dataset_name exists in the HDF5 file filename
% downloaded by lfeng Sat Feb  2 16:46:44 SGT 2013
% from http://www.angorafdtd.org/scripts.html

% hdf5 Matlab low-level access functions used!
% filename: The full path of the HDF5 file (string)
% dataset_name: The full path of the array dataset in the HDF5 file (string)

dataset_exists = true;

fid = H5F.open(filename);                        % H5F - access file

try
    arrayid = H5D.open(fid,['/' dataset_name]);  % H5D - access dataset
catch err
    errmsg = err.message;
    if(strfind(errmsg, 'not found'))
       dataset_exists = false;
    end
end

H5F.close(fid);
