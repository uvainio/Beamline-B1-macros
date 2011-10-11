function header = readheader(filename,fsn,fileend)

% function header = readheader(filename,fsn,fileend)
% or
% function header = readheader(filenamecomplete)
%
% Reads the header of file with the specified 'filename' into a 'struct'
% structure called 'header'.
% e.g. header = readheader('ORG',245,'.DAT');
% or   header = readheader('ORG00245.DAT');
%
% Units and information of the data in the header:
% FSN  (file sequence number of this measurement, same as in file name)
% FSNref1 (file sequence number of the reference measured before sample)
% FSNdc (file sequence number of dark current measurement)
% FSNsensitivity  (file sequence number of sensitivity measurement)
% FSNempty (file sequence number of empty beam measurement)
% FSNref2  (file sequence number of reference measured after sample)
% Monitor (cps in the scintillation detector 3)
% Anode (photons per second on the 2D detector anode)
% MeasTime (seconds, measurement time)
% Temperature (degrees Celsius, currently data is not stored)
% Transm (measured transmission of the sample)
% Energy (eV, the position of the virtual motor)
% Dist (sample-to-detector distance, mm)
% Xpixel (pixel size in X direction in mm)
% Ypixel (pixel size in Y direction in mm)
% Title (title of the sample)
% MonitorDORIS (cps in the first scintillation counter before monochromator)
% Owner (Owner of these files, for example DEMO)
% Rot1 (rotation 1 of sample stage in degrees)
% Rot2 (rotation 2 of sample stage in degrees)
% PosSample (position of sample in y direction in mm, 0 out of beam)
% DetPosX (position of detector, in mm, X, this is currently always 0)
% DetPosY (position of detector, in mm, Y, currently 0)
% MonitorPIEZO (cps, second scintillation counter, after monochromator)
% BeamsizeX (opening of slit 2 in x direction, im mm)
% BeamsizeY (opening of slit 2 in y direction, im mm)
% PosRef (position of reference sample holder, in mm, 50 is out of beam)
% Monochromator1Rot (rotation angle in degrees of the first monochromator crystal motor)
% Monochromator2Rot (rotation angle of second crystal)
% Heidenhain1 (Heidenhain encoder values giving the rotation of the
%              first monochromator crystal, currently in the file is
%                written the motor position, not the encoder value)
% Heidendain2 (same thing for the second crystal)
% Current1 (DORIS ring current at beginning of measurement)
% Current2 (DORIS ring current at end of measurement)
% Year   The year of measurement
% Month  The month of measurement
% Day    The day of measurement
% Hour   The hour of measurement
% Minutes   The minutes of hour of measurement
% 
% Can also be used with three input parameters:
% function header = readheader(filename,fsn,fileend)
% 
% Created: 10.8.2007 Ulla Vainio, HASYLAB, DESY, Hamburg
% Bug reports: ulla.vainio@desy.de or ulla.vainio@gmail.com
% Edited 27.11.2007, added changes in title (UV)
% Edited 19.3.2008, added year, month, day, hours, minutes of measurement
%                 event (UV)

if(nargin==3) % if name is given in parts, try to guess
     name = sprintf('%s%05d%s',filename,fsn,fileend);
     fid = fopen(name,'r');
     name1 = name;
     if(fid == -1)
       disp(sprintf('Cannot find FSN %d. Make sure path is correct.',fsn))
       header = 0;
       return
     end;
else
    fid = fopen(filename,'r'); % Open file.
   %if(fid ~= -1)
   %   disp(filename) % shows name that opened
   %end;
   if(fid == -1)
     sprintf('Cannot find file %d. Make sure path is correct.',filename)
     header = 0;
     return
   end;
end;
% FSN 1, FSNref1 24, FSNdc dark current 25, FSNsensitivity 26, FSNempty 27,
% FSNref2 28, Monitor 32, Anode 33, MeasTime 34, Temperature 35, Transm 42,
% Wavelength 44, Dist (sample-to-detector) 47, Xpixel 50, Ypixel 51, Title
% 54, MonitorDORIS 57, Owner 58, Rot1 60, Rot2 61, PosSample 62, DetPosX 63,
% DetPosY 64, MonitorPIEZO 65, PosRef 71, Monochromator1Rot 78,
% Monochromator1Rot 79, Heidenhain1 80, Heidendain2 81
% header = struct('FSN',0,'FSNref1',0,'FSNdc',0,'FSNsensitivity',0,'FSNempty',0,'FSNref2',0,'Monitor',0,'Anode',0,'MeasTime',0,'Temperature',0,'Transm',0,'Energy',0,'Dist',0,'Xpixel',0,'Ypixel',0,'Title',{{}},'MonitorDORIS',0,'Owner',{{}},'Rot1',0,'Rot2',0,'PosSample',0,'DetPosX',0,'DetPosY',0,'MonitorPIEZO',0,'Monochromator1Rot',0,'Monochromator2Rot',0,'Heidenhain1',0,'Heidenhain2',0);
header = struct('FSN',0); % Initialising the structure.

% hc = 197.3269601*2*pi*10;  % from X-ray data booklet Planck constant times
                           % speed of light in eV*Angstrom units
hc = 12396.4; % Used by Jusifa.pm

% If file was found, start reading:
temp = fscanf(fid,'%d',1);
header = setfield(header,'FSN',temp); % set structure field to the value read
temp = fscanf(fid,'%s',16);        % read lines in between
temp = fscanf(fid,'%d',1);
header = setfield(header,'Hour',temp); % line 18
temp = fscanf(fid,'%d',1);
header = setfield(header,'Minutes',temp); % line 19
temp = fscanf(fid,'%d',1);
header = setfield(header,'Month',temp); % line 20
temp = fscanf(fid,'%d',1);
header = setfield(header,'Day',temp); % line 21
temp = fscanf(fid,'%d',1);
header = setfield(header,'Year',2000+temp); % line 22
linesread = 22; % number of lines read already
temp = fscanf(fid,'%s',23 - linesread);        % read lines in between
temp = fscanf(fid,'%d',1);
header = setfield(header,'FSNref1',temp); % line 24
temp = fscanf(fid,'%d',1);
header = setfield(header,'FSNdc',temp); % line 25
temp = fscanf(fid,'%d',1);
header = setfield(header,'FSNsensitivity',temp); % line 26
temp = fscanf(fid,'%d',1);
header = setfield(header,'FSNempty',temp); % line 27
temp = fscanf(fid,'%d',1);
header = setfield(header,'FSNref2',temp); % line 28
linesread = 28;
temp = fscanf(fid,'%s',31 - linesread);        % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'Monitor',temp); % line 32
temp = fscanf(fid,'%g',1);
header = setfield(header,'Anode',temp); % line 33
temp = fscanf(fid,'%g',1);
header = setfield(header,'MeasTime',temp); % line 34
temp = fscanf(fid,'%g',1);
header = setfield(header,'Temperature',temp); % line 35
linesread = 35;
temp = fscanf(fid,'%s',41 - linesread);        % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'Transm',temp); % line 42
temp = fscanf(fid,'%s',1);                 % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'Energy',hc/temp); % line 44, header gives wavelength
% so it is transformed into energy
linesread = 44;
temp = fscanf(fid,'%s',46 - linesread);        % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'Dist',temp); % line 47
temp = fscanf(fid,'%s',2);                 % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'XPixel',1/temp); % line 50, header gives resolution 1/mm
% so it is transformed into pixel size in mm
temp = fscanf(fid,'%g',1);
header = setfield(header,'YPixel',1/temp); % line 51, header gives resolution 1/mm
% so it is transformed into pixel size in mm
temp = fgets(fid);                 % read lines in between
temp = fgets(fid);                 % read lines in between
temp = fgets(fid);                 % read lines in between
temp = strcat(fgets(fid));
% Converting - and space to _ to ease analysis, because structure cell names cannot
% have the sign -, added space on 27.11.2007
for(k = 1:length(temp))
    if(strcmp(temp(k),'-') | strcmp(temp(k),' '))
        temp(k) = '_';
    end;
    if(strcmp(temp(k),'.'))
        temp(k) = 'p';
    end;
end;
header = setfield(header,'Title',temp); % line 54
temp = fscanf(fid,'%s',2);                 % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'MonitorDORIS',temp); % line 57
temp = fscanf(fid,'%s',1);
header = setfield(header,'Owner',temp); % line 58
temp = fscanf(fid,'%s',1);                 % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'Rot1',temp); % line 60
temp = fscanf(fid,'%g',1);
header = setfield(header,'Rot2',temp); % line 61
temp = fscanf(fid,'%g',1);
header = setfield(header,'PosSample',temp); % line 62
temp = fscanf(fid,'%g',1);
header = setfield(header,'DetPosX',temp); % line 63
temp = fscanf(fid,'%g',1);
header = setfield(header,'DetPosY',temp); % line 64
temp = fscanf(fid,'%g',1);
header = setfield(header,'MonitorPIEZO',temp); % line 65
temp = fscanf(fid,'%g',1);
temp = fscanf(fid,'%g',1);
header = setfield(header,'BeamsizeX',temp); % line 67
temp = fscanf(fid,'%g',1);
header = setfield(header,'BeamsizeY',temp); % line 68
temp = fscanf(fid,'%s',2);   % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'PosRef',temp); % line 71
linesread = 71;
temp = fscanf(fid,'%s',77 - linesread);   % read lines in between
temp = fscanf(fid,'%g',1);
header = setfield(header,'Monochromator1Rot',temp); % line 78
temp = fscanf(fid,'%g',1);
header = setfield(header,'Monochromator2Rot',temp); % line 79
temp = fscanf(fid,'%g',1);
header = setfield(header,'Heidenhain1',temp); % line 80
temp = fscanf(fid,'%g',1);
header = setfield(header,'Heidenhain2',temp); % line 81
temp = fscanf(fid,'%g',1);
header = setfield(header,'Current1',temp); % line 82, ring current at start
temp = fscanf(fid,'%g',1);
header = setfield(header,'Current2',temp); % line 83, ring current at end
linesread = 83;

fclose(fid); % Close file
