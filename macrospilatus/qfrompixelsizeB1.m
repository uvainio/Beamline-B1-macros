function [q,tth] = qfrompixelsizeB1(distance,pixelsize,energy,pix)
%
% function [q,tth] = qfrompixelsizeB1(distance,pixelsize,energy,pix)
%
% distance = sample-to-detector distance in mm
% pixelsize = 0.793 mm in August 2007 for the gas detector on B1, 0.172 for
% Pilatus detector, and 0.050 for Mythen
% energy = calibrated energy of the beam
% pix = pixels for which the q values are calculated, e.g. [0:length(ints)]
%
% Ulla Vainio 28.4.2004

pix = pix(:);
hc = 2*pi*1973.269601;

q = zeros(length(pix),length(energy));
tth = zeros(length(pix),length(energy));
lambda = zeros(length(energy),1);

for(l = 1:length(energy))
    lambda(l) = hc/energy(l);
    tth(:,l) = atan(pixelsize*pix/distance)*180/pi;
    q(:,l) = 4*pi*sin(tth*pi/180/2)/lambda(l);
end;