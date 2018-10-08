%#######################################################################
%
%                 * Knee Loading Device IMaGe Program *
%
%          M-File which digitizes the calibration scale, knee marker
%     and fixed origin (usually on the table) in JPEG images of the
%     loaded knee of subjects.  There are usually eight images (before
%     loading, after loading and every two minutes for 12 minutes).
%     The marker positions, displacements, relative displacements and
%     descriptive statistics are written to a MS-Excel spreadsheet,
%     kld_img.xlsx in the same directory as the JPEG images.  Multiple
%     sets of images from the same directory will be added as separate
%     sheets in the spreadsheet.
%
%          Separate windows are opened to show the approximate location
%     (within a pixel) of the knee marker (figure window 2) and fixed
%     origin marker (figure window 3) that were digitized on the
%     previous image.
%
%     NOTES:  1.  The markers must be digitized in a specific order.
%             The knee marker is digitized first and then the fixed
%             origin (table) marker.  The program does not prompt for
%             these markers unless the variable, prmpt, is true.  See
%             lines 49-50 and the standard operating procedure.
%
%             2.  When the small cross hair cursor is visible, the
%             Matlab figure controls can be used to zoom and pan the
%             image (see figure toolbar).  The mouse wheel will also
%             zoom in and out.  When the desired zoomed image is ready
%             to be digitized, press any key (usually the <space bar>)
%             to get the full image cross hair cursor which is used to
%             digitize a marker.
%
%             3.  Stat X and Stat Y columns contain the mean, range,
%             standard deviation and the margin of error of the 95%
%             confidence interval for the relative X and Y 
%             displacements, respectively, for all the images between
%             the second and last image.
%
%             4.  Requires the Matlab Statistics toolbox.
%
%     01-Oct-2018 * Mack Gardner-Morse
%

%#######################################################################
%
% Prompt for Points to Digitize?
%
% prmpt = true;           % Prompts for all points
prmpt = false;          % No prompts
%
% Output MS_Excel Spreadsheet File Name
%
xlsnam = 'kld_img.xlsx';
shtnam = 'kld_img';
irow = 1;
hdrc1 = {'Cal X','Cal Y'};
hdrc2 = {'del Cal X','del Cal Y'};
hdrc3 = {'Cal Dist ='};
hdrc4 = {'Cal (mm/pixel) ='};
hdr1 = {'File','Mrk X','Mrk Y','delta X','delta Y','Dist Mrk X', ...
       'Dist Mrk Y','Total Mrk X','Total Mrk Y','Origin X', ...
       'Origin Y','Rel X','Rel Y','del Rel X','del Rel Y', ...
       'Dist Rel X','Dist Rel Y','Stat X','Stat Y', ...
       'Tot Rel X','Tot Rel Y'};
units = {'','(pixel)','(pixel)','(pixel)','(pixel)','(mm)','(mm)', ...
         '(mm)','(mm)','(pixel)','(pixel)','(pixel)','(pixel)', ...
         '(pixel)','(pixel)', '(mm)','(mm)','(mm)','(mm)', ...
         '(mm)','(mm)'};
%
% Get Image File Names
%
[fnams,pnam] = uigetfile( { '*.jpe*;*.jpg*', ...
             'JPEG image files (*.jpe*, *.jpg*)';
             '*.jpe*;*.jpg*;*.tif*;*.gif*;*.bmp*', ...
             'All image files (*.jpe*, *.jpg*, *.tif*, *.gif*, *.bmp*)';
             '*.*',  'All files (*.*)'},'Please Select Image Files', ...
             'MultiSelect', 'on');
%
if isequal(fnams,0);
  return;
end
%
if iscell(fnams)
  fnams = fnams';
else
  fnams = {fnams};      % Insure names are a cell array
end
%
nf = size(fnams,1);
%
% Get Output MS-Excel Spreadsheet File Path and Name
%
fullxlsnam = fullfile(pnam,xlsnam);
%
% Check for Output MS-Excel Spreadsheet and Get Sheet Name
%
if ~exist(fullxlsnam)
  shtnam1 = [shtnam '0001'];
else
  [~,fshtnams] = xlsfinfo(fullxlsnam);      % Get sheet names in file
  idl = strncmpi(shtnam,fshtnams,7);   % Sheets already exists in file?
  if all(~idl)          % Sheet name not found in file
    shtnam1 = [shtnam '0001'];
  else                  % Sheet in the file
    fshtnams = sort(fshtnams(idl));
    fn = fshtnams{end}(8:end);
    nz = size(fn,2)-1;
    fn = eval(fn)+1;
    shtnam1 = [shtnam repmat('0',1,nz-floor(log10(fn))) int2str(fn)];
  end
end
%
% Initialize Variables
%
psx = zeros(2,1);
psy = zeros(2,1);
hs = zeros(2,1);
%
mtxt = {'Please pick the first point.';
        'Please pick the second point.'};
%
msgtxt = {'Please pick the coordinate system origin.';
          'Please pick the coordinate system North (superior)';
          'Please pick the coordinate system East (lateral)'};
%
pcx = zeros(3,nf);
pcy = zeros(3,nf);
hc = zeros(3,1);
%
pmx = zeros(nf,1);
pmy = zeros(nf,1);
%
% Setup Figure Windows
%
hf1 = figure;
orient landscape;
set(hf1,'WindowState','maximized');
drawnow;
pos = reshape(get(hf1,'Position'),2,2)';
posh = floor(diff(pos)/2);             % Half size window
posh = [pos(1,:)+posh posh];
%
hf2 = figure;
orient landscape;
set(hf2,'Position',posh);
%
hf3 = figure;
orient landscape;
set(hf3,'Position',posh);
%
figure(hf1);
%
% Loop through Files
%
for k = 1:nf;
%
% File Name
%
   fnam = fnams{k};
   im_dat = imread(fullfile(pnam,fnam));
%
% Plot Image
%
   ih = imagesc(im_dat);
   axis equal;
   axis tight;
   hold on;
   axlim = axis;
%
% Get Image Calibration
%
  if k==1               % Only get magnification in first image
    uiwait(msgbox(['Please pick two (2) points 50 mm apart on the ', ...
           'scale.'],'Note'));
%
     for l = 1:2;
        if prmpt
          uiwait(msgbox(mtxt{l},'Required Input'));
        else
          zoom on;
          pause;
        end
%
        figure(hf1);
        [psx(l),psy(l)] = ginput(1);
        hs(l) = plot(psx(l),psy(l),'k+','MarkerSize',8,'LineWidth',1);
%
        kans = logical(2-menu('Point OK?','No','Yes'));
        while kans;
             figure(hf1);
             [psx(l),psy(l)] = ginput(1);
             set(hs(l),'XData',psx(l),'YData',psy(l));
             kans = logical(2-menu('Point OK?','No','Yes'));
        end
        zoom off;
        axis(axlim);
     end
%
     ds = diff([psx psy]);             % Differences in scale points
     d = norm(ds);
     imagn = 50.0/d;
%
% Write Calibration to Spreadsheet
%
     xlswrite(fullxlsnam,hdrc1,shtnam1,['A' int2str(irow+2)]);
     xlswrite(fullxlsnam,[psx psy],shtnam1,['A' int2str(irow+3)]);
%
     xlswrite(fullxlsnam,hdrc2,shtnam1,['A' int2str(irow+5)]);
     xlswrite(fullxlsnam,ds,shtnam1,['A' int2str(irow+6)]);
%
     xlswrite(fullxlsnam,hdrc3,shtnam1,['A' int2str(irow+7)]);
     xlswrite(fullxlsnam,d,shtnam1,['B' int2str(irow+7)]);
%
     xlswrite(fullxlsnam,hdrc4,shtnam1,['A' int2str(irow+8)]);
     xlswrite(fullxlsnam,imagn,shtnam1,['B' int2str(irow+8)]);
%
   end
%
% Get Knee Marker Point
%
   if prmpt
     uiwait(msgbox('Please pick the center of the knee marker', ...
            'Required Input'));
   else
     zoom on;
     pause;
   end
%
   figure(hf1);
   [pmx(k),pmy(k)] = ginput(1);
   hm = plot(pmx(k),pmy(k),'r+','MarkerSize',8,'LineWidth',1);
%
   kans = logical(2-menu('Point OK?','No','Yes'));
   while kans;
        figure(hf1);
        [pmx(k),pmy(k)] = ginput(1);
        set(hm,'XData',pmx(k),'YData',pmy(k));
        kans = logical(2-menu('Point OK?','No','Yes'));
   end
%
% Put Marker and Zoomed Image in Figure 2
%
   axlim2 = round(axis);
   axlim2([2 4]) = axlim2([2 4])-1;    % Stay within image data
   figure(hf2);
   ih2 = imagesc(im_dat(axlim2(3):axlim2(4),axlim2(1):axlim2(2),:));
   axis equal;
   axis tight;
   hold on;
   hm2 = plot(pmx(k)-axlim2(1)+1,pmy(k)-axlim2(3)+1,'r+', ...
              'MarkerSize',8,'LineWidth',1);
%
   figure(hf1);
   zoom off;
   axis(axlim);
%
% Get Coordinate System Origin Point
%
   if prmpt
     uiwait(msgbox(['Please pick one (1) point to define the ', ...
            'origin of the coordinate system.'],'Note'));
   end
%
   for l = 1:1;
%    for l = 1:3;
      if prmpt
        uiwait(msgbox(msgtxt{l},'Required Input'));
      else
        zoom on;
        pause;
      end
%
      figure(hf1);
      [pcx(l,k),pcy(l,k)] = ginput(1);
      hc(l) = plot(pcx(l,k),pcy(l,k),'r+','MarkerSize',8,'LineWidth',1);
%
      kans = logical(2-menu('Point OK?','No','Yes'));
      while kans;
           figure(hf1);
           [pcx(l,k),pcy(l,k)] = ginput(1);
           set(hc(l),'XData',pcx(l,k),'YData',pcy(l,k));
           kans = logical(2-menu('Point OK?','No','Yes'));
      end
%
% Put Origin and Zoomed Image in Figure 3
%
      axlim3 = round(axis);
      axlim3([2 4]) = axlim3([2 4])-1; % Stay within image data
      figure(hf3);
      ih3 = imagesc(im_dat(axlim3(3):axlim3(4),axlim3(1):axlim3(2),:));
      axis equal;
      axis tight;
      hold on;
      hc2 = plot(pcx(l,k)-axlim3(1)+1,pcy(l,k)-axlim3(3)+1,'r+', ...
                 'MarkerSize',8,'LineWidth',1);
%
      figure(hf1);
      zoom off;
      axis(axlim);
   end
%
end
%
% Only Using One Coordinate Point
%
pcx = pcx(1,:)';
pcy = pcy(1,:)';
%
% Get Relative Position
%
r = [pmx pmy]-[pcx pcy];
%
% Get Differences
%
if nf>1
  dm = diff([pmx pmy]);
  distm = dm*imagn;
%
  dr = diff(r);
  distr = dr*imagn;
else
  dm = NaN;
  distm = NaN;
%
  dr = NaN;
  distr = NaN;
end
%
% Get Overall (Total) Distances
%
if nf>2
  tm = diff([pmx([2; end]) pmy([2; end])]);
  tm = tm*imagn;
%
  tr = diff(r([2; end],:));            % Difference between end and beginning positions
  tr = tr*imagn;
%
  distrm = mean(distr(2:end,:),1);     % Mean over loading time
  distrr = range(distr(2:end,:),1);    % Range over loading time
  distrs = std(distr(2:end,:),0,1);    % SD over loading time
  n = size(distr(2:end,1),1);
  t = tinv(0.975,n-1);
  distrc = (t.*distrs)./sqrt(n);
else
  tm = NaN;
  tr = NaN;
  distrm = NaN;
  distrr = NaN;
  distrs = NaN;
  distrc = NaN;
end
%
% Write Points to Spreadsheet
%
xlswrite(fullxlsnam,hdr1,shtnam1,['C' int2str(irow)]);
xlswrite(fullxlsnam,fnams,shtnam1,['C' int2str(irow+1)]);
xlswrite(fullxlsnam,[pmx pmy],shtnam1,['D' int2str(irow+1)]);
xlswrite(fullxlsnam,[dm distm],shtnam1,['F' int2str(irow+2)]);
xlswrite(fullxlsnam,tm,shtnam1,['J' int2str(irow+1)]);
%
xlswrite(fullxlsnam,[pcx pcy r],shtnam1,['L' int2str(irow+1)]);
xlswrite(fullxlsnam,[dr distr],shtnam1,['P' int2str(irow+2)]);
xlswrite(fullxlsnam,[distrm tr],shtnam1,['T' int2str(irow+1)]);
xlswrite(fullxlsnam,[distrr; distrs; distrc],shtnam1, ...
         ['T' int2str(irow+2)]);
%
return