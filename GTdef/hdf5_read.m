function [ resulting_array ] = hdf5_read(filename,dataset_name)

% Copyright (c) 2011,2012 Ilker R Capoglu 
% Reads the array dataset dataset_name from the HDF5 file filename
% downloaded by lfeng Sat Feb  2 16:46:44 SGT 2013
% from http://www.angorafdtd.org/scripts.html

% hdf5 Matlab low-level access functions used!
% filename: The full path of the HDF5 file (string)
% dataset_name: The full path of the array dataset in the HDF5 file (string)

fid = H5F.open(filename);                              % H5F - access file

arrayid = H5D.open(fid,['/' dataset_name]);            % H5D - access dataset

dataspace  = H5D.get_space(arrayid);
[ ~,dims ] = H5S.get_simple_extent_dims(dataspace);

resulting_array = H5D.read(arrayid);
% HDF5 writes in row-major order, and matlab reads in column major order
% The array therefore needs to be permuted to get the dimensions in the same order

if (length(dims)>1)
   resulting_array = permute(resulting_array,length(dims):-1:1);
end

H5F.close(fid);
