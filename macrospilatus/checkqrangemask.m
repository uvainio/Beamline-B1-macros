function [qmin,qmax,Nq]=checkqrangemask(mask,energy,tubes,center,distminus,detshift,pixelsize)
%function [qmin,qmax,Nq]=checkqrangemask(mask,energy,tubes,center,distminus,detshift,pixelsize)
%
%Calculate the optimal q-range for the measurement
%
% Inputs (parameters in [brackets] are optional):
%    mask: mask matrix (1 is non-masked, 0 is masked)
%    energy: calibrated photon energy, eV
%    tubes: number of flight tube parts, 0 to 4
%    [center]: beam center vector ([X,Y], X=row coordinate, Y=column
%        coordinate, both starting from 1)
%    [distminus]: sample holder distance correction (default 0)
%    [detshift]: detector distance correction (default 46)
%    [pixelsize]: pixel size in mm (default 0.172)
%
% Outputs:
%    [qmin]: estimated q_min
%    [qmax]: estimated q_max
%    [Nq]:   estimated number of bins
% 
% If no outputs are defined, a message will be printed to the console.
% This find the maximum and minimum distance of unmasked pixels from the
% beam center. These are converted into 'q' and returned as qmin and qmax.
% The proposed number of q-bins (Nq) is ceil(pixmax-pixmin).
%
%Created: 24.06.2011 By Andras Wacha, using concepts and codes from Ulla
% Vainio's checkqrange macro

% EDIT HERE if you want to change these magic constants...
HC=12398.419; %Planck's constant times speed of light, eV*Angstroems, NIST 2006
default_beamcenter=[488.7,477.8]; % default for Pilatus 1M
default_detshift=46; % mm
default_distminus=0; % mm default sampleholder
default_pixelsize=0.172; %mm, default for Pilatus series
dist0=935; %original distance with 0 tubes
dist1=1384; %original distance with 0 tubes
dist2=1835; %original distance with 0 tubes
dist3=2735; %original distance with 0 tubes
dist4=3635; %original distance with 0 tubes
qbinforpixel=1; %average number of q-bins covering a pixel
if nargin<4
    warning('You may get better results if you give the beam center (4th argument)!')
    center=default_beamcenter; %approximate beam position for Pilatus 1M
end
if nargin<5
    distminus=default_distminus;
end
if nargin<6
    detshift=default_detshift;
end
if nargin<7
    pixelsize = default_pixelsize;
end

shiftd=distminus+detshift;
if(tubes == 0)
    distance = dist0-shiftd;
elseif(tubes == 1)
    distance = dist1-shiftd;
elseif(tubes == 2)
    distance = dist2-shiftd;
elseif(tubes == 3)
    distance = dist3-shiftd; 
elseif(tubes == 4)
    distance = dist4-shiftd;
else
    disp('Parameter "tubes" does not correspond to any available distance (0 - 4 incl.).')
    return
end;

[col,row]=meshgrid(1:size(mask,2),1:size(mask,1));
pix=sqrt((col-center(2)).^2+(row-center(1)).^2);
pixmin=min(pix(mask~=0));
pixmax=max(pix(mask~=0));
qmin=4*pi*sin(0.5*atan(pixmin*pixelsize/distance))/HC*energy;
qmax=4*pi*sin(0.5*atan(pixmax*pixelsize/distance))/HC*energy;
Nq=(ceil(pixmax-pixmin))*qbinforpixel;
if nargout==0
    disp(sprintf('Pix_min: %g',pixmin));
    disp(sprintf('Pix_max: %g',pixmax));
    disp(sprintf('Q_min: %g 1/%c',qmin,197));
    disp(sprintf('Q_max: %g 1/%c',qmax,197));
    disp(sprintf('Proposed number of bins: %d (dq=%.4f; %d bins for each pixel)',Nq,(qmax-qmin)/Nq,qbinforpixel));
end

end