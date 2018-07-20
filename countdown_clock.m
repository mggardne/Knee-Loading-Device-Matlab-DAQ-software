function hf = countdown_clock(time,ptime);
%COUNTDOWN_CLOCK Counts down times less than an hour in seconds. 
%
%        COUNTDOWN_CLOCK(TIME) Opens a figure with a text uicontrol
%        to display a minutes and seconds countdown clock.  The clock
%        counts down for TIME seconds.  TIME must be less than 3600
%        seconds (1 hour).  The figure closes two (2) seconds after the
%        countdown ends.
%
%        COUNTDOWN_CLOCK(TIME,PTIME)  Will close the figure PTIME
%        seconds after the countdown.
%
%        NOTES:  1.  Input countdown time TIME must be in seconds and
%                be less than an hour (3600 seconds).
%
%        13-Jul-2018 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Input Countdown Time
%
if nargin<1
  time = -720;          % Countdown time in seconds
end
%
if nargin<2
  ptime = 2;            % Pause time after countdown in seconds
end
%
if abs(time)>3600
  error(['ERROR in countdown_clock:  Only counts down times less ', ...
         'than an hour!']);
end
%
if time>0
  time = -time;
end
%
if ptime<0
  ptime = 2;
end
%
% Setup Figure and Text UIControl
%
hf = figure('Units','pixels','Position',[600 600 200 80], ...
            'MenuBar','none','Name','Timer','NumberTitle','off', ...
            'Resize','off','HandleVisibility','off', ...
            'DeleteFcn',@del_timer);
%
hd = uicontrol(hf,'Style','text','Position',[10 10 180 60], ...
               'BackgroundColor',[0.8 0.8 0.8],'FontSize',36, ...
               'FontWeight','bold');
%
% Get and Set Initial Times
%
t0 = clock;
%
str = time_frmt(time);
set(hd,'String',str);
%
% Setup and Start Timer
%
ht = timer('TimerFcn',@new_time,'Period',1,'ExecutionMode', ...
           'FixedRate','StopFcn',@end_time,'TasksToExecute', ...
           floor(abs(time-1)));
start(ht);
%
return
%
% Delete Timer Function
%
function del_timer(varargin)
%
% Delete Timer When Figure is Closed
%
        try
          stop(ht);
          delete(ht);
        end
end
%
% Close Countdown Clock Function
%
function end_time(varargin)
%
% Stop and Delete Timer and Delete Figure
%
%         delete(ht);     % Delete timer
        pause(ptime);
        delete(hf);     % Delete figure
end
%
% New Time Function
%
function new_time(varargin)
%
% Get New Time
%
        etim = etime(clock,t0);
        str = time_frmt(time+etim);
        set(hd,'String',str);
end
%
% Time Format Function
%
function str = time_frmt(time)
%
% Format the Time String
%
        time = abs(time);
        if time>3600
          hrs = floor(time/3600);
          time = time-3600*hrs;
        end
        mins = floor(time/60);
        secs = floor(time-60*mins);
%
        m = sprintf('%1.0f:',mins);
%
        if mins < 10
          m = sprintf('0%1.0f:',mins);
        end
%
        s = sprintf('%1.0f',secs);
        if secs < 10
          s = sprintf('0%1.0f',secs);
        end
%
        str = [m s];
%
end
%
end