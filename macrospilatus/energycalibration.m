function energyreal = energycalibration(energymeas,energycalib,energy1)

% function energyreal = energycalibration(energymeas,energycalib,energy1)
%
% Created 10.12.2008 UV Makes easier to control how the energy calibration
% is made in each macro. Now instead of interpolation, we simply fit a
% line and then interpolate and extrapolate.

[PP,SS] = polyfit(energymeas,energycalib,1);
energyreal = PP(1)*energy1 + PP(2);
