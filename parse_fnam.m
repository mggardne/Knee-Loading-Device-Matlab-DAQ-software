function [subj,exam,trial,dstr] = parse_fnam(fnam)
%PARSE_FNAM Parses a data file name and returns the string components
%           of the file name.
%
%        PARSE_FNAM(FNAM) returns the sum of square error based on the
%        time T and observed values Y.  X(1) is the sine wave
%        amplitude, X(2) is the sine wave circular frequency, X(3) is
%        the initial time offset and X(4) is the Y offset.
%
%        NOTES:  1.  For data MAT files for the knee loading device
%                trial experiments.  The file names are in a specific
%                format.  See kld.m and kld_plt.m.  The file name
%                format is:
%
%                subjID_examN_trial?_DDMMMYYYY.mat
%
%                where ID is the subject initials, N is 1 or 2 for
%                examiner 1 or 2, ? is the trial number and DDMMMYYYY
%                is the test date in day, three letter month and year
%                format.
%
%        29-Aug-2018 * Mack Gardner-Morse
%

%#######################################################################
%
% Check Inputs
%
if nargin<1
  error(' *** ERROR in parse_fnam:  No input file name string!');
end
%
if ~isstr(fnam)
  error(' *** ERROR in parse_fnam:  Input file name must be a string!');
end
%
% Find Dots and Underscores in File Name
%
idot = findstr(fnam,'.');
idot = idot(end);
%
ius = findstr(fnam,'_');
ius1 = ius(1);
ius2 = ius(2);
ius3 = ius(3);
%
% Get Subject's Initials, Examiner Number, Trial Number and Date Strings
%
subj = fnam(ius1-2:ius1-1);
exam = fnam(ius2-1);
trial = fnam(ius2+6:ius3-1);
dstr = datestr(datevec(fnam(ius3+1:idot-1)));
%
return