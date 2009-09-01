function param = readlogfile(filename)

% function param = readlogfile(filename)
%
% IN:
%
% filename of the log file you would like to open. E.g. 'normint567.log'
%
% OUT:
%
% param = all the parameters written in file only in one struct
%
% Created 14.9.2007 UV
% Edited 2.1.2008 UV, added monitor counts
% 19.6.2009 UV added rotations of sample stage

fid = fopen(filename,'r');
if(fid == -1)
%  disp(sprintf('Could not find file %s.',filename))
  param = 0;
  return
else
% Initialize structure.
param = struct('FSN',0,'Title','-','Dist',0,'Thickness',0,'Transm',0,'PosSample',-1,'Temperature',0,...
    'MeasTime',0,'ScatteringFlux',0,'FSNdc',0,'FSNempty',0,'InjectionEB','-','FSNref1',0,'Thicknessref1',0,'InjectionGC','-',...
    'Energy',0,'EnergyCalibrated',0,'BeamPosX',0,'BeamPosY',0,'NormFactor',0,'NormFactorRelativeError',-1,...
    'BeamsizeX',0,'BeamsizeY',0,'PixelSize',0,'Monitor',0,'PrimaryIntensity',0,'RotXsample',0,'RotYsample',0);
% Read in file and save to structure 'param'.
temp = fscanf(fid,'FSN:\t%d\n',1);
param = setfield(param,'FSN',temp);
temp = fgetl(fid);
param = setfield(param,'Title',sprintf('%s',temp(15:end)));
temp = fscanf(fid,'Sample-to-detector distance (mm):	%f\n',1);
param = setfield(param,'Dist',temp);
temp = fscanf(fid,'Sample thickness (cm):	%f\n',1);
param = setfield(param,'Thickness',temp);
temp = fscanf(fid,'Sample transmission:	%f\n',1);
param = setfield(param,'Transm',temp);
temp = fscanf(fid,'Sample position (mm):	%f\n',1);
param = setfield(param,'PosSample',temp);
temp = fscanf(fid,'Temperature:\t%f\n',1);
param = setfield(param,'Temperature',temp);
temp = fscanf(fid,'Measurement time (sec):	%f\n',1);
param = setfield(param,'MeasTime',temp);
temp = fscanf(fid,'Scattering on 2D detector (photons/sec):	%f\n',1);
param = setfield(param,'ScatteringFlux',temp);
temp = fscanf(fid,'Dark current subtracted (cps):	%f\n',1);
param = setfield(param,'FSNdc',temp);
temp = fscanf(fid,'Empty beam FSN:	%d\n',1);
param = setfield(param,'FSNempty',temp);
temp = fscanf(fid,'Injection between Empty beam and sample measurements?:\t%s\n',1);
param = setfield(param,'InjectionEB',char(temp));
temp = fscanf(fid,'Glassy carbon FSN:\t%d\n',1);
param = setfield(param,'FSNref1',temp);
temp = fscanf(fid,'Glassy carbon thickness (cm):\t%f\n',1);
param = setfield(param,'Thicknessref1',temp);
temp = fscanf(fid,'Injection between Glassy carbon and sample measurements?:\t%s\n',1);
param = setfield(param,'InjectionGC',char(temp));
temp = fscanf(fid,'Energy (eV):\t%f\n',1);
param = setfield(param,'Energy',temp);
temp = fscanf(fid,'Calibrated energy (eV):\t%f\n',1);
param = setfield(param,'EnergyCalibrated',temp);
temp = fscanf(fid,'Beam x y for integration:	%f %f\n',2);
param = setfield(param,'BeamPosX',temp(1));
param = setfield(param,'BeamPosY',temp(2));
temp = fscanf(fid,'Normalisation factor (to absolute units):\t%f\n',1);
param = setfield(param,'NormFactor',temp);
temp = fscanf(fid,'Relative error of normalisation factor (percentage):\t%f\n',1);
param = setfield(param,'NormFactorRelativeError',temp);
temp = fscanf(fid,'Beam size X Y (mm):	%f %f\n',2);
param = setfield(param,'BeamsizeX',temp(1));
param = setfield(param,'BeamsizeY',temp(2));
temp = fscanf(fid,'Pixel size of 2D detector (mm):\t%f\n\n',1);
param = setfield(param,'PixelSize',temp);
temp = fscanf(fid,'Primary intensity at monitor (counts/sec):\t%f\n',1);
param = setfield(param,'Monitor',temp);
temp = fscanf(fid,'Primary intensity calculated from GC (photons/sec/mm^2):\t%e\n',1);
param = setfield(param,'PrimaryIntensity',temp);
temp = fscanf(fid,'Sample rotation around x axis:\t%e\n',1);
param = setfield(param,'RotXsample',temp);
temp = fscanf(fid,'Sample rotation around y axis:\t%e\n',1);
param = setfield(param,'RotYsample',temp);

fclose(fid);
end;