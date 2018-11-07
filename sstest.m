%
% Test of inputSingleScan for Plotting Tensioning Data
%
wt = 150;
if exist('izero','var');
  izero = false;
else
  izero = true;
end
%
% Setup Figure
%
fhu = figure('Position',[1120 560 560 420]);
tld = 0.15*wt;          % 15% of body weight
ht = plot([0; 1],[tld; tld],'r-','Linewidth',1);      % Target load
hold on;
hd = plot([0; 1],[NaN; NaN],'b.','Linewidth',1,'MarkerSize',7);
xlabel('Time (s)','FontSize',12,'FontWeight','bold');
ylabel('Force (lbf)','FontSize',12,'FontWeight','bold');
title('Axial Force','FontSize',16,'FontWeight','bold');
hax = get(fhu,'CurrentAxes');
%
% Load Loadcell Calibration Matrix
%
load FT5071cal.mat;
%
% Get DAQ
%
dev = daq.getDevices;
dev_id = dev.ID;
%
s1 = daq.createSession('ni');
%
% Setup Session
%
dur = 10;               % Duration time in seconds
rate = 10;
s1.Rate = rate;         % Rate in Hz
s1.DurationInSeconds = dur;            % Duration time in seconds
%
% Add Channels
%
ai1 = addAnalogInputChannel(s1,dev_id,'ai2','Voltage');
ai1.TerminalConfig = 'SingleEnded';
ai1.Range = [-10 10];
ai1.Name = 'SG0';
%
ai2 = addAnalogInputChannel(s1,dev_id,'ai3','Voltage');
ai2.TerminalConfig = 'SingleEnded';
ai2.Range = [-10 10];
ai2.Name = 'SG1';
%
ai3 = addAnalogInputChannel(s1,dev_id,'ai4','Voltage');
ai3.TerminalConfig = 'SingleEnded';
ai3.Range = [-10 10];
ai3.Name = 'SG2';
%
ai4 = addAnalogInputChannel(s1,dev_id,'ai5','Voltage');
ai4.TerminalConfig = 'SingleEnded';
ai4.Range = [-10 10];
ai4.Name = 'SG3';
%
ai5 = addAnalogInputChannel(s1,dev_id,'ai6','Voltage');
ai5.TerminalConfig = 'SingleEnded';
ai5.Range = [-10 10];
ai5.Name = 'SG4';
%
ai6 = addAnalogInputChannel(s1,dev_id,'ai7','Voltage');
ai6.TerminalConfig = 'SingleEnded';
ai6.Range = [-10 10];
ai6.Name = 'SG5';
%
% Acquire Zero Data
%
if izero
%
  h = msgbox({'       Click "OK" to Collect'; ...
              '10 seconds of Zero Load Data'},'modal');
  ha = get(h,'CurrentAxes');
  hc = get(ha,'Child');
  set(hc,'FontSize',8,'FontWeight','bold');
  uiwait(h);
%
  [zdata,ztime] = startForeground(s1);
%
  zdat = mean(zdata);
%
end
%
% Acquire Unloaded (No Applied Pressure) Data
%
hm = msgbox({'Please start tightening leg straps.'; ...
            'Press OK when finished.'},'Unloaded Data');
ha = get(hm,'CurrentAxes');
hc = get(ha,'Child');
set(hc,'FontSize',8,'FontWeight','bold');
%
ztim = [];
zfor = [];
%
while isvalid(hm)
     [zforc,ztime] = s1.inputSingleScan;
     zfor = [zfor; zforc];
     ns = size(zfor,1);
     ztim = [ztim; ztime];
%
     dat = zfor-repmat(zdat,ns,1);     % Zero sensor
     [~,~,~,~,m,s] = datevec(ztim);
     t = 60*m+s;
     t = t-repmat(t(1),ns,1);          % Zero time
%
     d = (cal*dat')';   % Scale data
%
     tend = t(end);
     if tend==0
       tend = 0.001;
     end
     set(ht,'XData',[0; tend]);
     set(hd,'XData',t,'YData',-d(:,3)./4.44822);
     set(hax,'Xlim',[0 tend]);
     refresh(fhu);
     drawnow;
end
