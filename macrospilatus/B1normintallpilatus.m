function B1normintallpilatus(fsn1,thicksfile,sens,errorsens,mask,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,fluorcorr)

% function B1normintallpilatus(fsn1,thicksfile,sens,errorsens,mask,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,fluorcorr)
%
% Finds automatically empty beam and reference measurements and the samples
% related to those measurements and integrates, subtract dark current,
% divides by detector sensitivity, angle dependent transmission, absorption due
% to air and windows in the beam path and for geometrical distortion,
% subtracts empty beam background
% and normalises the data to the glassy carbon references.
% Finally the matrices are integrated to get 1d patterns.
%
% IN:
%
% fsn1 = all FSNs that you want to analyse (including empty beams
%        and references)
% thicksfile = either a number in cm (same thickness for all samples)
%              or the name of the file where the thicknesses
%              of each sample are found
% fsndc = FSN of the dark current measurement
% orifsn = which measurement counting from the empty beam (0) is the
%          measurement from which the center of the beam is to be
%          determined from, use 1 for glassy carbon before measurement
%          sequence
% sens = sensitivity matrix of the detector
% errorsens = error of the sensitivity matrix
% mask = mask to mask out the center area, detector edges and bad spots
%        caused by for example reflections form beamstop
% energymeas = two or more measured energies in a vector
%             (1st inflection points of foils)
% energycalib = the true energies corresponding to the measured 1st
%               inflection points (for example from Kraft et al. 1996)
% mythendistance = distance from goniometer center to the WAXS detector (MYTHEN), if WAXS detector was not used, put any number
%                    2009 spring 133.8320 mm
% mythenpixelshift = shift in pixels from 0 of the MYTHEN detector (2009 spring 300.3417)
% orig = (optional) initial guess for center of the beam e.g. [122.5 124.2]
%
% OUT:
%
% Saved files:
%
% intnormFSN.dat has three columns in which there are the q-scale,
%                intensity in 1/cm units and the error of the intensity,
%                likewise in 1/cm units
% If the same sample name repeats at same energy and distance these files
% are further processed to
%
% sumFSN.dat   These contain the summed intnorm files with q, error and
%              intensity
%
% Created 26.10.2007 UV (ulla.vainio@desy.de)
% Edited 31.3.2009 UV Edited to fit PILATUS 300k data
% Edited Andras Wacha, 6. Dec. 2008. (awacha@gmail.com):
% Because if only one sequence is processed, with only one empty beam
% measurement, emptys will be [[fsn_of_eb, 1]]. The length command returns
% MAX(SIZE(emptys)), which will be 2, instead of 1. This really is not a
% bug, as this macro is intended for normalizing and integrating multiple
% runs. B1normint1 is written for a single sequence.
% Edited 24.11.2009 UV: Added Mythen data reduction here and now it also
% subtracts the empty beam (which is very close to zero..) from the data)


% Finding the empty beams from fsn1s

counter = 1;
for(l = 1:length(fsn1))
    temp = readheader('org_',fsn1(l),'.header');
   if(isstruct(temp))
    header(counter) = temp;
    fsn1found(counter) = fsn1(l);
    counter = counter + 1;
   end;
end;

emptys(1,:) = [0 0];
counter = 1;
for(k = 1:length(fsn1found))
    if(strcmp(getfield(header(k),'Title'),'Empty_beam'))
        emptys(counter,:) = [getfield(header(k),'FSN') k];
        counter = counter + 1;
    end;
end;

% AW this line was not good:
%for(m = 1:(length(emptys)-1))
sz_emptys=size(emptys);
for(m =1:(sz_emptys(1)-1))
  if(emptys(m+1,1) > fsn1found(emptys(m+1,2)-1)) % Process only if next file from empty is not empty
      B1normintpilatus1(fsn1found(emptys(m,2):(emptys(m+1,2)-1)),thicksfile,sens,errorsens,mask,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,fluorcorr);
      % Read in calibrated energy
      paramm = readlogfilepilatus(sprintf('intnorm%d.log',fsn1found(emptys(m,2)+1)));
      % Correct for Mythen data
      [qmythen,tthmythen] = qfrompixelsizeB1(mythendistance-distminus,0.05,paramm.EnergyCalibrated,mythenpixelshift+[0:1279]);
      mythennormint('waxs_',fsn1found(emptys(m,2):(emptys(m+1,2)-1)),qmythen,tthmythen,'angle');
  end;
end;
% And the last one separately
B1normintpilatus1(fsn1found(emptys(end,2):end),thicksfile,sens,errorsens,mask,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,fluorcorr);
% Read in calibrated energy
paramm = readlogfilepilatus(sprintf('intnorm%d.log',fsn1found(emptys(end,2)+1)));
% Correct for Mythen data
[qmythen,tthmythen] = qfrompixelsizeB1(mythendistance-distminus,0.05,paramm.EnergyCalibrated,mythenpixelshift+[0:1279]);
mythennormint('waxs_',fsn1found(emptys(end,2):end),qmythen,tthmythen,'angle');
