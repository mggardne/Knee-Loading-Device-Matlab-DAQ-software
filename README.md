# Knee-Loading-Device-Matlab-DAQ-software
Matlab DAQ software for collecting and plotting force data from an MRI knee loading device.

20 July 2018

The main Matlab DAQ script file is kld.m which uses the function files countdown_clock.m and get_data.m.  See comments in kld.m for more information.

The main Matlab image digitizing script file is kld_img.m.  See the comments in kld_img.m for how to use the program to digitize the JPEG images of the subject's knee.  The Matlab Statistics toolbox is required, but the "range" command could be easily replaced by "max()-min().
