%#######################################################################
%
%                  * Knee Loading Device Program 1 *
%
%          M-File which collects load data from the knee loading device
%     (KLD).
%
%          The program checks for previous data files from that day.
%     If there is no file, the program will prompt the user for zero
%     load data.  If there is a file, it reads the previous subject ID,
%     subject's weight, examiner number and zero load data.  The user
%     is then prompted to verify or input the subject and examiner data.
%     The program reads any previous data file from the day matching the
%     subject and examiner data to determine the trial number.
%
%     For each trial, the program prompts and collects 10 seconds of
%     load data with no applied pressure load to get the loads from the
%     foot resting in the foot holder.  The user is then prompted to 
%     collect 720 seconds (12 minutes) of load data while the subject is
%     loaded at half body weight.  All the load data is collected at
%     10 Hz.
%
%          The load data and test information is saved in a MAT file in
%     the subdirectory "Data" with file name:
%
%     subjID_examN_trial?_DDMMMYYYY.mat
%
%     where ID is the subject initials, N is 1 or 2 for examiner 1 or 2,
%     ? is the trial number and DDMMMYYYY is the test date in day, three
%     letter month and year format.
%
%     NOTES:  1.  For ATI Industrial Automation Mini45 force transducer
%             SI-580-20 S/N FT05071 with NI USB-6210 Multifunction I/O.
%
%             2.  The loadcell calibration file, FT5071cal.mat, must be
%             in the current directory or path.
%
%             3.  M-files cl.m, countdown_clock.m and get_data.m must
%             be in the current directory or path.
%
%     16-Jul-2018 * Mack Gardner-Morse
%
%     09-Oct-2018 * Mack Gardner-Morse * New pressure calibration
%
%     07-Nov-2018 * Mack Gardner-Morse * Added plotting of tensioning
%                                        loads in the unloaded (before
%                                        applied pressure) state with a
%                                        target of 15% body weight.
%

%#######################################################################
%
% Clear WorkSpace
%
cl;
%
% Global Variables
% idx is the incremental index into the full data arrays fdata and ftime
%
global fdata ftime idx
%
% Data Directory
%
ddir = 'Data';
%
% Conversion from Body Weight to Pressure
% See press_cal1.xlsx
%
% wt2psi = 4.44822/10.353;               % Full body weight
% wt2psi = wt2psi/2;      % Half body weight
%
% Conversion from Body Weight to Pressure
% See press_cal3.xlsx
%
lbf2N = 4.448221615;    % N/lbf
wt2psi = [1 10.491904]./10.7133585;    % Coefficient and intercept
%
% Get Todays Date in DDMMMYYYY Format
%
dtxt = datestr(now,'ddmmmyyyy');
%
% Check for Previous MAT Files from Today for Setting Defaults
%
d = dir(fullfile(ddir,['*_' dtxt '.mat']));
if isempty(d)
  defs = {'','','1'};
  izero = true;
else
  [~,ids] = sort([d.datenum]);
  ids = ids(end);       % Index to newest MAT file 
  dnam = fullfile(ddir,d(ids).name);
  load(dnam,'id','wt','exam','zdat','zdata','ztime');
  wt = sprintf('%5.1f',wt);
  defs = {id,wt,int2str(exam)};
  clear d dnam exam id ids wt;
  izero = false;
end
%
% Get Subject ID, Weight and Examiner
%
ttxt = 'Input';
prmpt = {'Two Letter Subject ID', 'Subject Weight (lbs)', ...
        'Examiner (1 or 2)'};
% dims = [1 3; 1 25; 1 1];
nlin = 1;
ok = false;
while ~ok
     answ = inputdlg(prmpt,ttxt,nlin,defs);
     id = upper(answ{1});
     iltr = isletter(id);
     nid = size(id,2);
     wt =  str2double(answ{2});
     exam =  str2double(answ{3});
     if nid==2&&wt>25&&wt<=250&&(exam==1||exam==2)&&all(iltr)
       ok = true;
     end
end
%
wth = wt*lbf2N/2;       % Half body weight in N
wt10 = wth/5;           % 10% of body weight in N
psi = polyval(wt2psi,wth);             % Target psi
psis = sprintf('%4.1f',psi);
%
uiwait(msgbox({['Please set pressure to ' psis ' psi for']; ...
              '50% body weight compressive load.'}, ...
              'Action Required','warn','modal'));
%
% Get Trial Number
%
d = dir(fullfile(ddir,['subj' id '_exam' int2str(exam) '_trial*_' ...
        dtxt '.mat']));
if isempty(d)
  n = 1;
else
  fnams = {d.name}';
  fnams = sort(fnams);
  fnam = fnams{end};
  idext = strfind(fnam,['_' dtxt]);
  fnum = fnam(19);
  n = str2double(fnum)+1;
end
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
% Setup Figure for Unloaded (No Applied Pressure) Data
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
% Acquire Unloaded (No Applied Pressure) Data
%
hm = msgbox({'Please start tightening leg straps.'; ...
            '       Press OK when finished.'},'Unloaded Data');
ha = get(hm,'CurrentAxes');
hc = get(ha,'Child');
set(hc,'FontSize',8,'FontWeight','bold');
%
utim = [];
udat = [];
%
while isvalid(hm)
     [udata,utime] = s1.inputSingleScan;
     udat = [udat; udata];
     ns = size(udat,1);
     utim = [utim; utime];
%
     datu = udat-repmat(zdat,ns,1);    % Zero sensor
     [~,~,~,~,m,s] = datevec(utim);
     ut = 60*m+s;
     ut = ut-repmat(ut(1),ns,1);       % Zero time
%
     ud = (cal*datu')'; % Scale data
%
     tend = ut(end);
     if tend==0
       tend = 0.001;
     end
     set(ht,'XData',[0; tend]);
     set(hd,'XData',t,'YData',-ud(:,3)./4.44822);
     set(hax,'Xlim',[0 tend]);
     refresh(fhu);
     drawnow;
end
%
% Setup Trial Session
%
dur = 720;              % Duration time in seconds (12 minutes)
% dur = 30;               % Duration time in seconds (half a minute) - for testing
s1.DurationInSeconds = dur;            % Duration time in seconds
%
npts = dur*rate;
fdata = zeros(npts,6);
ftime = zeros(npts,1);
idx = 1;
fh = figure('Position',[1120 560 560 420]);
xlabel('Time (s)','FontSize',12,'FontWeight','bold');
ylabel('Force (lbf)','FontSize',12,'FontWeight','bold');
title('Axial Force','FontSize',16,'FontWeight','bold');
tld = wt/2;
hax = get(fh,'CurrentAxes');
ht = plot([0; 1],[tld; tld],'r-','Linewidth',1);      % Target load
hold on;
hd = plot([0; 1],[NaN; NaN],'b.','Linewidth',1,'MarkerSize',7);
%
lh = s1.addlistener('DataAvailable', ...
                    @(src,event) get_data(event,cal,zdat,fh,hax,ht,hd));
%
% Acquire 12 minutes of Force Data
%
h = msgbox({['    Pressure is ' psis ' psi?']; ...
           '    Click "OK" to Collect';'      12 minutes of Data'}, ...
           'modal');
ha = get(h,'CurrentAxes');
hc = get(ha,'Child');
set(hc,'FontSize',9.8,'FontWeight','bold');
uiwait(h);
%
startBackground(s1);
uiwait(countdown_clock(dur));
%
delete(lh);             % Delete listener
close(fh);              % Close force plot figure
s1.stop;                % Be sure session has stopped
%
% Save Data
%
fnam = ['subj' id '_exam' int2str(exam) '_trial' int2str(n) ...
        '_' dtxt '.mat'];
fnamd = fullfile(ddir,fnam);           % Put in subdirectory
%
save(fnamd,'cal','dtxt','exam','fdata','ftime','id','lbf2N','psi', ...
     'psis','n','wt','wt2psi','wth','ud','udat','ut','utim', ...
     'zdat','zdata','ztime');
%
return