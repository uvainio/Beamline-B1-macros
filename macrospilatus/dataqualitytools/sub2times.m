function difftime = sub2times(fsn1,fsn2)

% function difftime = sub2times(fsn1,fsn2)
%
% Subtracts the two times (first from second). Output is in minutes.
%
% Created 12.8.2009 Ulla Vainio (ulla.vainio@desy.de)

header1 = readheader('org_',fsn1,'.header');
header2 = readheader('org_',fsn2,'.header');

time1 = datenum(header1.Year,header1.Month,header1.Day,header1.Hour,header1.Minutes,0);
time2 = datenum(header2.Year,header2.Month,header2.Day,header2.Hour,header2.Minutes,0);

difftime = (time2 - time1)*24*60;

