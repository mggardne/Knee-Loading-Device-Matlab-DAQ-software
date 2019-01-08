%#######################################################################
%
%                        * ZERO CHecK Program *
%
%          M-File which reads the knee loading device MAT files for the
%     zero data.  The zero data is checked for outliers.  The outlier
%     statistics are plotted and printed to a PS file, zero_chk.ps.
%     The outlier zero data is replaced by the mean of the valid zero
%     data from the other trials and subjects, and the results are
%     recomputed and output to a MS-Excel file, kld_forc.xlsx.
%
%     NOTES:  1.  MAT files must be in subdirectory "\Data".
%
%             2.  Requires Excel for Windows to run.  (Will not work
%             correctly on Apple or Unix systems.)
%
%     03-Jan-2018 * Mack Gardner-Morse
%

%#######################################################################
%
% Get and Parse MAT File Names
%
d0 = dir('Data\subj0*.mat');
d1 = dir('Data\subj1*.mat');
fnams = [char(d0.name); char(d1.name)];
[~,~,~,dstr,sn,en,tn] = parse_fnam(fnams);  % Parse file names
%
% Remove Subjects 05 and 09
%
idr = find(sn~=5);
fnams = fnams(idr,:);
dstr = dstr(idr,:);
sn = sn(idr);
en = en(idr);
tn = tn(idr);
%
idr = find(sn~=9);
fnams = fnams(idr,:);
dstr = dstr(idr,:);
sn = sn(idr);
en = en(idr);
tn = tn(idr);
%
% Remove 16-Nov-2018 Trials from Subject 04
%
id4 = find(sn==4);
dd = str2num(datestr(dstr(id4,:),'dd'));
idd = find(dd==16);
idd = id4(idd);
nf = size(sn,1);        % Number of file names
idr = true(nf,1);
idr(idd) = false;
fnams = fnams(idr,:);
dstr = dstr(idr,:);
sn = sn(idr);
en = en(idr);
tn = tn(idr);
%
% Remove 29-Nov-2018 Trials from Subject 06
%
id6 = find(sn==6);
dd = str2num(datestr(dstr(id6,:),'dd'));
idd = find(dd==29);
idd = id6(idd);
nf = size(sn,1);        % Number of file names
idr = true(nf,1);
idr(idd) = false;
fnams = fnams(idr,:);
dstr = dstr(idr,:);
sn = sn(idr);
en = en(idr);
tn = tn(idr);
%
clear d0 d1 dd id*;
nf = size(sn,1);        % Number of file names
%
% Get Visit Numbers
%
subjn = unique(sn);     % Subject numbers
ns = size(subjn,1);     % Number of subjects
dn = datenum(dstr);     % Dates as numbers
vn = zeros(nf,1);       % Visit numbers
%
for k = 1:ns
   id = find(sn==subjn(k));
   dns = dn(id);
   vdates = unique(dns);
   nv = size(vdates,1);
   if nv~=3
     warning([' *** WARNING in zero-chk:  Number of visits not', ...
              ' equal to three!']);
   end
   for l = 1:nv
      idv = find(dns==vdates(l));
      idv = id(idv);
      vn(idv) = l;
   end
end
%
% Loop through Trials for Mean Zero Data
%
zd = zeros(nf,6);
for k = 1:nf
   z = load(fullfile('Data',fnams(k,:)),'zdat');
   zd(k,:) = z.zdat;
end
%
% Get Statistics on Zero Data
%
avg = mean(zd);
sd = std(zd);
llim = avg-3*sd;
ulim = avg+3*sd;
%
% Find Outliers
%
outgt = zd>repmat(ulim,nf,1);
outlt = zd<repmat(llim,nf,1);
outl = any([outgt outlt]')';
%
% Recalculate Statistics on Zero Data without Outliers
%
avg2 = mean(zd(~outl,:));
sd2 = std(zd(~outl,:));
llim2 = avg2-3*sd2;
ulim2 = avg2+3*sd2;
%
% Plot Zero Data by Subject Numbers
%
figure;
orient tall;
%
for k = 1:6
   l = 2*k;
   if k<4
     l = l-1;;
   else
     l = l-6;
   end
   ha = subplot(3,2,l);
   plot(sn,zd(:,k),'b.','LineWidth',1,'MarkerSize',8);
   hold on;
   plot([1; 12],repmat(avg(k),2,1),'k--','LineWidth',1);
   plot([1; 12],repmat(llim(k),2,1),'r--','LineWidth',1);
   plot([1; 12],repmat(ulim(k),2,1),'r--','LineWidth',1);
   plot([1; 12],repmat(avg2(k),2,1),'k-','LineWidth',1.5);
   plot([1; 12],repmat(llim2(k),2,1),'r-','LineWidth',1.5);
   plot([1; 12],repmat(ulim2(k),2,1),'r-','LineWidth',1.5);
   ttxt = ['S_' int2str(k)];
   title(ttxt,'FontSize',16,'FontWeight','bold');
   if k==3|k==6
     xlabel('Subject Number','FontSize',12,'FontWeight','bold');
   end
   ylabel(ttxt,'FontSize',12,'FontWeight','bold');
   axlim = axis;
   axis([1 axlim(2:4)]);
   set(ha,'XTick',1:12);
end
%
print -dpsc -fillpage zero_chk.ps;
%
% Get Data in Order
%
datai = [sn vn en tn];                 % Data index
[datai ids] = sortrows(datai);
fnams = fnams(ids,:);
dstr = dstr(ids,:);
outl = outl(ids);
%
% Read Data MAT Files
%
datan = zeros(nf,44);
%
for k = 1:nf
%
% File Name
%
   fnam = fnams(k,:);
   fnamd = ['Data\' fnam];
   load(fnamd);
%
% Get Force Data and Target Force
%
   if outl(k)
     zdat = avg2;
   else
     zdat = mean(zdata);               % Get zero load forces
   end
%
   nd = size(fdata,1);
   dat = fdata-repmat(zdat,nd,1);      % Zero sensor
%
   d = (cal*dat')';     % Scale data
%
%    kans = menu('Target as percent (%) of body weight?','25%','50%');
   kans = 2;            % 50% body weight
   trgt_div = 4/kans;
   trgt = (-wt/trgt_div)*lbf2N;
%
% Get Descriptive Statistics of the Force Data
%
   dataa = zeros(1,40);
%
   for l = 1:6
      m = 5*l;
      m = m-4:m;
      mn = min(d(:,l));
      mx = max(d(:,l));
      rng = mx-mn;
      dataa(1,m) = [mean(d(:,l)) std(d(:,l)) mn mx rng];                    
   end
%
% Center of Pressure with Descriptive Statistics
%
   dx = -d(:,5)./d(:,3);               % X position of center of pressure
   dx = 1000*dx;        % Convert from m to mm
   l = 7;
   m = 5*l;
   m = m-4:m;
   mn = min(dx);
   mx = max(dx);
   rng = mx-mn;
   dataa(1,m) = [mean(dx) std(dx) mn mx rng];
%
   dy = d(:,4)./d(:,3);                % Y position of center of pressure
   dy = 1000*dy;        % Convert from m to mm
   l = 8;
   m = 5*l;
   m = m-4:m;
   mn = min(dy);
   mx = max(dy);
   rng = mx-mn;
   dataa(1,m) = [mean(dy) std(dy) mn mx rng];
%
% Get Resultant Force and Combine the Data
%
   v = dataa(1,1:5:11);
   v = v*v';
   v = sqrt(v);         % Resultant vector
   datan(k,:) = [wt wt*lbf2N trgt dataa v];
%
end
%
% Create Header Labels
%
f = ['F'; 'M'; 'D'];    % Force and displacement labels
c = ['x'; 'y'; 'z'];    % Coordinate axis labels
t = {'Mean_'; 'SD_'; 'Min_'; 'Max_'; 'Rng_'};    % Type of measurement
ul = {'(N)'; '(Nm)'; '(mm)'};          % Units
h = cell(1,45);
u = cell(1,45);
for k = 1:3
   for l = 1:3
      for m = 1:5
         n = 15*k+5*l+m-20;
         h{n} = [t{m} f(k) c(l)];
         u{n} = ul{k};
      end
   end
end
%
h = h(1:40);            % Remove Dz labels
u = u(1:40);            % Remove Dz units
%
% Write Header Labels and Data to MS-Excel Spreadsheet kld_forc.xlsx
%
hdr = {'File_Name','Subject','Visit','Examiner','Trial','Date', ...
       'Wt','Wt','Target', h{:}, 'Result_Frc'};
units = {'', '', '', '', '', '', '(lbf)', '(N)', '(N)', u{:}, '(N)'};
%
xnam = fullfile('kld_forc.xlsx');      % Output spreadsheet file name
snam = 'kld';
%
xlswrite(xnam,hdr,snam,'A1');
xlswrite(xnam,units,snam,'A2');
xlswrite(xnam,cellstr(fnams),snam,'A3');
xlswrite(xnam,datai,snam,'B3');
xlswrite(xnam,cellstr(dstr),snam,'F3');
xlswrite(xnam,datan,snam,'G3');
%
return