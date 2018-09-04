%#######################################################################
%
%                * Knee Loading Device PLoT Program 1 *
%
%          M-File which reads the knee loading device (KLD) data, plots
%     the axial force time histories and outputs the force data
%     statistics to a spreadsheet.
%
%          The program checks for data MAT files in the DATA
%     subdirectory with file names:
%
%     subjID_examN_trial?_DDMMMYYYY.mat
%
%     where ID is the subject initials, N is 1 or 2 for examiner 1 or 2,
%     ? is the trial number and DDMMMYYYY is the test date in day, three
%     letter month and year format.
%
%          The program reads the output spreadsheet, kld_data.xlsx, from
%     the DATA subdirectory for the file names already processed.  Any
%     file names already in the spreadsheet are flagged with a star.
%
%          The force time history plots are saved to a PS file with
%     the same file name as the MAT file, but with file extension "ps".
%     Descriptive statistics on the force data are output to the
%     MS-Excel spreadsheet, kld_data.xlsx.
%
%     NOTES:  1.  For ATI Industrial Automation Mini45 force transducer
%             SI-580-20 S/N FT05071 with NI USB-6210 Multifunction I/O.
%
%             2.  M-file cl.m must be in the current directory or path.
%
%             3.  The MS-Excel spreadsheet, kld_data.xlsx, must be in
%             the subdirectory "Data".
%
%             4.  The program assumes the data MAT files are in the
%             subdirectory "Data".
%
%             4.  The PS plot files are saved in the subdirectory
%             "Data".
%
%     29-Aug-2018 * Mack Gardner-Morse
%

%#######################################################################
%
% Clear WorkSpace
%
cl;
%
% Load Conversion Factor
%
lbf2N = 4.448221615;    % N/lbf
%
% Data Subdirectory
%
sdir = 'Data';
%
% Get Data MAT File Names
%
d = dir(fullfile(sdir,'*.mat'));
%
fdates = char(d.date);
[~,iord] = sortrows(datevec(fdates));  % Sort by dates
%
fnams = {d.name}';
fnams = fnams(iord);    % Get in date order
nf = size(fnams,1);     % Number of data files
%
% Check MS-Excel Spreadsheet kld_data.xlsx for File Names
%
xnam = fullfile(sdir,'kld_data.xlsx'); % Output spreadsheet file name
fnamss = fnams;         % Processed file names marked with asterisks
%
if exist(xnam,'file')
  [~,txt] = xlsread(xnam);
  fnamsx = txt(2:end,1);
  nrow = size(fnamsx,1);% Number of rows with data
  nx = size(fnams,1);   % Number of processed files
%
  idx = true(nf,1);     % Logical index to files that need processing
%
  for k = 1:nx
     id = find(strcmp(fnamsx{k},fnams));
     if ~isempty(id);
       fnamss{id} = [fnamss{id} '*'];
       idx(id) = false;
     end
  end
else
  idx = true;           % Logical index to files that need processing
  nx = 0;               % Number of processed files
end
%
iv = find(idx);         % Index to files that need processing
if isempty(iv)
  iv = nx;              % Process last file processed
else
  iv = iv(1);           % Start with first file that need processing
end
%
% Get User to Select Files for Processing
%
ok = false;
while ~ok
     [filesel,ok] = listdlg('ListString',fnamss,'Name', ...
     'Data MAT Files','PromptString', ...
     {'Please select a file or files for analysis.'; ...
     'Previously processed files are marked with an asterisk.'}, ...
     'InitialValue',iv,'ListSize',[320 360],'SelectionMode','multiple');
end
%
% Read Data MAT Files
%
irow = nrow+2;          % Row index into output spreadsheet
lbls = {'Fx (N)';'Fy (N)';'Fz (N)';'Mx (Nm)';'My (Nm)';'Mz (Nm)'};
%
for k = filesel
%
% File Name
%
   fnam = fnams{k};
%
   [subj,exams,trial,dstr] = parse_fnam(fnam);   % Parse file name
   ttxt = {['Subject ' subj ' Examiner ' exams ' Trial ' trial]; ...
            dstr};      % Title text
%
   fnamd = fullfile(sdir,fnam);
   load(fnamd);
%
% Get Force Data and Target Force
%
   zdat = mean(zdata);  % Get zero load forces
%
   ns = size(fdata,1);
   dat = fdata-repmat(zdat,ns,1);      % Zero sensor
%
   d = (cal*dat')';     % Scale data
%
   trgt = (-wt/2)*lbf2N;
%
% Plot All the Force and Moment Data
%
   figure;
   orient tall;
   for l = 1:6
      subplot(6,1,l);
      plot(ftime,d(:,l),'b.-','LineWidth',1);
      ylabel(lbls(l,:),'FontSize',12,'FontWeight','bold');
      if l==1
        title({['Subject ' subj ' Examiner ' exams ' Trial ' trial]; ...
               dstr});
      end
      if l==3
        hold on;
        axlim = axis;
        plot(axlim(1:2),[trgt trgt],'r-','LineWidth',2);
        text(mean(axlim(1:2)),trgt+7,'50% BW','FontSize',10, ...
             'FontWeight','bold','Color','r', ...
             'HorizontalAlignment','center');
      end
      if l==6
        xlabel('Time (s)','FontSize',12,'FontWeight','bold');
      end
   end
%
   idot = strfind(fnam,'.');
   pnam = fullfile(sdir,[fnam(1:idot(end)) 'ps']);
   print('-dpsc','-r600','-fillpage',pnam);
%
% Plot Axial Force Data with Descriptive Statistics
%
   mnfz = mean(d(:,3)); % Mean of Fz
   sdfz = std(d(:,3));  % SD of Fz
   figure;
   orient landscape;
%
   plot(ftime,d(:,3),'b.-','LineWidth',1);
%
   hold on;
%
   axlim = axis;
   plot(axlim(1:2),[trgt trgt],'r-','LineWidth',2);
%
   plot(axlim(1:2),[mnfz mnfz],'g-','Color',[0 0.7 0],'LineWidth',2);
   plot(axlim(1:2),[mnfz mnfz]+3*sdfz,'g:','Color',[0 0.7 0], ...
        'LineWidth',2);
   plot(axlim(1:2),[mnfz mnfz]-3*sdfz,'g:','Color',[0 0.7 0], ...
        'LineWidth',2);
%
   axlim = axis;
   offst = 0.025*(axlim(4)-axlim(3));
%
   text(mean(axlim(1:2)),trgt+offst,['50% BW = ' sprintf('%.1f',trgt), ...
        ' N'],'FontSize',10,'FontWeight','bold','Color','r', ...
        'HorizontalAlignment','center');
%
   text(mean(axlim(1:2)),mnfz+offst,['Mean = ' sprintf('%.1f',mnfz), ...
        ' N'],'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
   text(mean(axlim(1:2)),mnfz+3*sdfz+offst,'Mean+3SD', ...
        'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
   text(mean(axlim(1:2)),mnfz-3*sdfz+offst,'Mean-3SD', ...
        'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
%
   xlabel('Time (s)','FontSize',12,'FontWeight','bold');
   ylabel(lbls(3,:),'FontSize',12,'FontWeight','bold');
%
   title(ttxt);
%
   print('-dpsc','-r600','-fillpage','-append',pnam);
%
% Plot Center of Pressure with Descriptive Statistics
%
   dx = -d(:,5)./d(:,3);               % X position of center of pressure
   dx = 1000*dx;        % Convert from m to mm
   mndx = mean(dx);     % Mean of Dx
   sddx = std(dx);      % SD of Dx
%
   dy = d(:,4)./d(:,3);                % Y position of center of pressure
   dy = 1000*dy;        % Convert from m to mm
   mndy = mean(dy);     % Mean of Dy
   sddy = std(dy);      % SD of Dy
%
   figure;
   orient landscape;
%
   plot(ftime,dx,'b.-','LineWidth',1);
%
   hold on;
%
   axlim = axis;
%
   plot(axlim(1:2),[mndx mndx],'g-','Color',[0 0.7 0],'LineWidth',2);
   plot(axlim(1:2),[mndx mndx]+3*sddx,'g:','Color',[0 0.7 0], ...
        'LineWidth',2);
   plot(axlim(1:2),[mndx mndx]-3*sddx,'g:','Color',[0 0.7 0], ...
        'LineWidth',2);
%
   axlim = axis;
   offst = 0.025*(axlim(4)-axlim(3));
%
   text(mean(axlim(1:2)),mndx+offst,['Mean = ' sprintf('%.1f',mndx), ...
        ' mm'],'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
   text(mean(axlim(1:2)),mndx+3*sddx+offst,'Mean+3SD', ...
        'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
   text(mean(axlim(1:2)),mndx-3*sddx+offst,'Mean-3SD', ...
        'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
%
   xlabel('Time (s)','FontSize',12,'FontWeight','bold');
   ylabel('X Displacement (mm)','FontSize',12,'FontWeight','bold');
%
   title(ttxt);
%
   print('-dpsc','-r600','-fillpage','-append',pnam);
%
   figure;
   orient landscape;
%
   plot(ftime,dy,'b.-','LineWidth',1);
%
   hold on;
%
   axlim = axis;
%
   plot(axlim(1:2),[mndy mndy],'g-','Color',[0 0.7 0],'LineWidth',2);
   plot(axlim(1:2),[mndy mndy]+3*sddy,'g:','Color',[0 0.7 0], ...
        'LineWidth',2);
   plot(axlim(1:2),[mndy mndy]-3*sddy,'g:','Color',[0 0.7 0], ...
        'LineWidth',2);
%
   axlim = axis;
   offst = 0.025*(axlim(4)-axlim(3));
%
   text(mean(axlim(1:2)),mndy+offst,['Mean = ' sprintf('%.1f',mndy), ...
        ' mm'],'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
   text(mean(axlim(1:2)),mndy+3*sddy+offst,'Mean+3SD', ...
        'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
   text(mean(axlim(1:2)),mndy-3*sddy+offst,'Mean-3SD', ...
        'FontSize',10,'FontWeight','bold','Color',[0 0.7 0], ...
        'HorizontalAlignment','center');
%
   xlabel('Time (s)','FontSize',12,'FontWeight','bold');
   ylabel('Y Displacement (mm)','FontSize',12,'FontWeight','bold');
%
   title(ttxt);
%
   print('-dpsc','-r600','-fillpage','-append',pnam);
%
% Write Descriptive Statistics to MS-Excel Spreadsheet
%
   lrow = int2str(irow);
   xlswrite(xnam,{fnam,subj,exams,trial,dstr},1,['A' lrow]);
   data = [wt wt*lbf2N trgt mnfz sdfz mndx sddx mndy sddy];
   xlswrite(xnam,data,1,['F' lrow]);
%
   irow = irow+1;       % Row index into output spreadsheet
%
% Clear Figures
%
   fprintf(1,'\n *** Hit any key to clear figures and continue. ***\n');
   pause;
%
end
%
return                                                                                                                              