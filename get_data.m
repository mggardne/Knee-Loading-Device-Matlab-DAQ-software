function get_data(event,cal,zdat,fh,ha,ht,hd)
%GET_DATA Gets and plots data from a DAQ session listener.
%
%        GET_DATA(EVENT,CAL,ZDAT,FH,HA,HT,HD) Collects the time and
%        force data from the EVENT structure and puts the data into the
%        global variables ftime and fdata, respectively.  CAL, the
%        loadcell calibration, and ZDAT, the loadcell zero load data,
%        are used to convert the force data to SI units and the loadcell
%        coordinate system.  FH, a figure graphics handle, and HA, an
%        axis graphics handle, are used for plotting the acquired Z
%        force data.  HT, a line graphics handle, is used to plot the
%        target load.  HD, a line graphics handle, is used to plot the
%        Z force data.
%
%        NOTES:  1.  See M-file kld.m for more information.
%
%        18-Jul-2018 * Mack Gardner-Morse
%

%#######################################################################
%
% Global Variables
% idx is the incremental index into the full data arrays fdata and ftime
%
global fdata ftime idx
%
% Get Data
%
t = event.TimeStamps;
ns = size(t,1);         % Number of data points this sample
id = idx:idx+ns-1;
ftime(id) = t;
fdata(id,:) = event.Data;
ide = id(end);
idx = ide+1;
%
% Scale Data
%
id = 1:ide;
nsz = size(id,2);       % Total number of acquired data points
%
if ~mod(nsz,5)          % Plot every half a second assuming 10 Hz rate
%
  dat = fdata(id,:)-repmat(zdat,nsz,1);          % Zero sensor
%
  d = (cal*dat')';      % Scale data
%
% Plot Fz Data
%
  tend = ftime(ide);
  set(ht,'XData',[0; tend]);
  set(hd,'XData',ftime(id),'YData',-d(:,3)./4.44822);
  set(ha,'Xlim',[0 tend]);
  refresh(fh);
%
end
%
return