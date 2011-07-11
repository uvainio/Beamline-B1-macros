function energyreal = energycalibration(energymeas,energycalib,energy1)

% function energyreal = energycalibration(energymeas,energycalib,energy1)
%
% Created 10.12.2008 UV Makes easier to control how the energy calibration
% is made in each macro. Now instead of interpolation, we simply fit a
% line and then interpolate and extrapolate.
% Edited 29.06.2011 AW Added possibility to have only one energy pair. In
% this case, just a shift in energy is done, and a warning message is
% printed.
if length(energymeas)==1
    warning('Calibrating energy from only one energy pair. This may be not so accurate...');
    energyreal=energycalib-energymeas+energy1;
else
    [PP,SS] = polyfit(energymeas,energycalib,1);
    energyreal = PP(1)*energy1 + PP(2);
end
