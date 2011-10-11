function qtheor = checkqrange(energy,tubes,bsR)

% function qtheor = checkqrange(energy,tubes,bsR)
%
% With this macro on ecan check on B1, what will be the q-range of the data
%
% energy = energy of x-rays in eV
% tubes = sample-to-detector distance in TUBES, i.e. 0, 1, 2, 3, or 4
% bsR = radius of beamstop in mm (normally 4 mm)
%
% OUT:
%
% qtheor = estimated q range in 1/Angstrom units
%
% Created 24.9.2008 UV

shiftd = 46;
if(tubes == 0)
    distance = 935-shiftd;
elseif(tubes == 1)
    distance = 1384-shiftd;
elseif(tubes == 2)
    distance = 1835-shiftd;
elseif(tubes == 3)
    distance = 2735-shiftd; 
elseif(tubes == 4)
    distance = 3635-shiftd;
else
    disp('Parameter "tubes" does not correspond to any available distance (0 - 4).')
    return
end;

pixsize = 0.172; % mm
safetylimit = 1.5; % Estimate of how many pixels have to be disregarded near the beamstop
pix = [(bsR/pixsize+safetylimit):1:(sqrt(473^2 + 564^2))]; % Pixel range

theta2 = atan(pix*pixsize/distance);

hc = 197.326960*2*pi; % From X-ray data booklet, page 5-2

lambda = hc/energy;

qtheor = 4*pi*sin(theta2/2)/lambda/10;
disp(sprintf('q(min) = %.3f 1/A and q(max) = %.3f 1/A, q(step) = %.4f 1/A.',qtheor(1),qtheor(end),qtheor(2)-qtheor(1)))