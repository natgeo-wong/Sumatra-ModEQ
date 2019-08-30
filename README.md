# Sumatran-ModEQ

`EQ` is an earthquake forward-modelling framework based on the `GTdef` (Georgia Tech 
Deformation) code.  It can be configured to model earthquakes along a given slab geometry 
(in our case Slab1.0), or it may otherwise be used to create a fault plane based on given 
input of (longitude,latitude,depth,strike,dip), or lastly along a horizontal plane 
centered around a point (longitude,latitude,depth).  This file is designed to help the 
user set up the code for their own use, with some tips on how to customise model input 
parameters.

Tests indicate that despite the limits of forward modelling data, we are able to relocate 
events with sparse GPS data closer to regional seismic estimates better than their initial 
teleseismic inputs.  This therefore allows those interested to quickly obtain improved 
constrained estimates of event location without requiring detailed seismic data.

Any questions related to the main `EQ` code may be directed to me.  Questions relating to 
the `GTdef` code dependency should be directed to Dr. Lujia Feng, currently at NTU.

Authors:
* Nathanael Zhixin Wong (Main `EQ` code): nathanaelwong@fas.harvard.edu
* Dr. Lujia Feng (`GTdef` dependency): lfeng@ntu.edu.sg


## Download and Requirements

The first step is always to clone/fork the repository
```{bash}
git clone https://github.com/natgeo-wong/Sumatra-ModEQ.git
```

Running `EQ` requires MATLAB 2016b and above, at least.  It also requires the following 
toolboxes:
* Parallel toolbox
* Optimization toolbox


## Setup of `EQ` input files via `EQ_create.m`.

The basis of our forward models is that we must already have a set of predefined inputs.  
We generally take this from gCMT teleseismic estimates.  Based on these estimates, we 
create a `.eq` input file by running the `EQ_create.m` script.  This script creates a 
folder in the current working directory that contains the relevant `.eq` script.  Both the 
working directory and the `.eq` input script are named based on the date, magnitude, 
regression used and the rigidity.

It is advised that the user create a separate directory that contains all these input 
files and directories, because `EQ` will run the modelling and analysis inside these 
directories.

After this, it is necessary to copy the contents of `EQ_sub` into the working directory.  
`EQ_sub` contains both the master script `EQ.m` and submission scripts (e.g. `*.pbs`) that 
are necessary to run these scripts on a server.  The submission scripts will vary 
depending on the different servers and user style of inputs.  It is also necessary to 
modify the `startup.m` file, to add the paths of the main `EQ` codes, slab files and GPS 
velocity input files.

For example, in the server, my codes are found in `/home/nwong002/Codes/EQ/`.  Therefore, 
in my startup folder, I add the following paths:

```{bash}
/home/nwong002/Codes/EQ/         # Folder containing main EQ codes
/home/nwong002/Codes/EQ/Slab/    # Folder containing slab/fault input information
/home/nwong002/Codes/EQ/GPS_vel/ # Folder containing GPS velocity information
/home/nwong002/Codes/EQ/GTdef/   # GTdef code directory, requires a separate download
```


## Running the `EQ` model and analysing the results

In the directory, you should have at least the following files:
```{bash}
*.eq
startup.m
*submission script
```

Once the script has been run, you should see at least the following additional files and 
folders:
```{bash}
./GTdef_L_Input/   # Directory containing input information for L loop
./GTdef_L_Output/  # Directory containing output information for L loop
./GTdef_L_Misfit/  # Directory containing misfit information for L loop
./GTdef_SV_Input/  # Directory containing input information for SV loop
./GTdef_SV_Output/ # Directory containing output information for SV loop
./GTdef_SV_Misfit/ # Directory containing misfit information for SV loop
./GTdef_SW_Input/  # Directory containing input information for SW loop
./GTdef_SW_Output/ # Directory containing output information for SW loop
./GTdef_SW_Misfit/ # Directory containing misfit information for SW loop
*bfit*.txt         # Textfile containing bestfit information
```

Based on this information, you can then run the `analysis.m` script.  Once the script has 
been run, you should see the following additional folders:
```{bash}
./Analysis_ve1/ # Contains information required to plot patchfiles in GMT4 (from SV loop)
./Analysis_ve2/ # Contains information required to plot patchfiles in GMT4 (from SW loop)
```

Generally, I choose to use the SW (GPS-weighted variance explained) information in my plotting and analysis, as it tends to put more weightage on the horizontal displacement observed, and measurements of  horizontal displacements are more accurate than those of vertical displacements for GPS.


## Downloading the GTdef code.

The GTdef code was created by my mentor Dr. Lujia Feng and her advisor Prof. Andrew Newman at Georgia Technological University.  Though the `EQ` code requires the `GTdef` code as a dependency, the `GTdef` code is not opensource and therefore I do not have the rights to distribute it in public.  However, those who are interested in the GTdef code may email Dr. Feng at lfeng@ntu.edu.sg to attain a copy of the code for your use.  If `GTdef` is used in your work, please acknowledge Dr. Feng and her advisor Prof. Andrew Newman in your work.  Any questions relating to the `GTdef` code may be directed towards her.