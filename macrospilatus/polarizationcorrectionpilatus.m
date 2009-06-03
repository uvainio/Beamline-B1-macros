function [Aout,polcor] = polarizationcorrectionpilatus(distance,pixelsize,orix,oriy)

% function Aout = polarizationcorrectionpilatus(distance,pixelsize,orix,oriy)
%
% Corrects for the polarization effects in the scattering, taking
% into account that the radiation is linearly polarised
% on the sample. Acorrected = Ameasured.*Aout
%
% Created 12.10.2007 UV
% Modified for PILATUS 300k

pix = [1:619]; % NUmber of pixels in x-direction
xdist = round(abs(pixelsize*(pix - orix))); % Distance in x-direction
beta = atan(xdist/distance); % Angles in radians
beta = beta(:); % Make it a column vector

Aout = ones(619,487);
for(k = 1:487)
  Aout(:,k) = Aout(487,k)./cos(beta).^2; % Polarization correction cos^2
end;

if(nargin > 3)
  polcor = imageint(Aout,[orix oriy]);
end;