function header = getsamplenamespilatus(filename,files,fileend,dontshowtitles)

% function header = getsamplenamespilatus(filename,files,fileend)
%
% filename  = beginning of the file, e.g. 'org_'
% files     = the files , e.g. [714:1:804] will open files from with FSN
%             from 714 to 804
% fileend   = e.g. '.header'
%
% OUT: prints out on the screen the names of the samples
% in the sequence, the measurement distances and the energies
% gives a structure variable 'header' which contains
% all the header data from the selected measurements
%
% Created: 9.8.2007 Ulla Vainio, e-mail: ulla.vainio@desy.de or
% ulla.vainio@gmail.com
% Edited: Added the date and time of measurement to be displayed. (UV)

if(numel(files)==0)
   disp('Could not compute. Please give files from smallest FSN to largest FSN.')
   return
end;

% Reading all
counter = 1;
for(k = 1:length(files))  
   temp = readheader(filename,files(k),fileend);
   if(isstruct(temp))
      header(counter) = temp;
      counter = counter + 1;
   end;
end;

sizeA = size(header);
if(nargin==3) % don't show titles if dontshowtitles is given
  disp(sprintf('FSN\tTime\tEnergy\tDist\tPos\tTransm\tT (C)\tRot Y\tRot X\tTitle\t\t\tDate'))
end;
if(numel(sizeA)>1) % If more than one matrix
  for(n = 1:sizeA(2))
    disp(sprintf('%d\t%d\t%.1f\t%d\t%.2f\t%.4f\t%.f\t%.2f\t%.2f\t%s\t%s',getfield(header(n),'FSN'),round(getfield(header(n),'MeasTime')),getfield(header(n),'Energy'),...
    getfield(header(n),'Dist'),getfield(header(n),'PosSample'),getfield(header(n),'Transm'),...
    header(n).Temperature,header(n).Rot2,header(n).Rot1,getfield(header(n),'Title'),sprintf('%d.%d.%d %d:%02d',header(n).Day,...
    header(n).Month,header(n).Year,header(n).Hour,header(n).Minutes)));
  end;
else
    disp(sprintf('%d\t%d\t%.1f\t%d\t%.2f\t%.4f\t%.f\t%.2f\t%.2f\t\t\t%s\t%s',getfield(header,'FSN'),round(getfield(header,'MeasTime')),getfield(header,'Energy'),...
    getfield(header,'Dist'),getfield(header,'PosSample'),getfield(header,'Transm'),...
    header.Temperature,header.Rot2,header.Rot1,getfield(header,'Title'),sprintf('%d.%d.%d %d:%02d',header.Day,...
    header.Month,header.Year,header.Hour,header.Minutes)));
end;
