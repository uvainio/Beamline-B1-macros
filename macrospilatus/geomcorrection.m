function cor = geomcorrection(q,energy,distance)
%function cor = geomcorrection(q,energy,distance)
% 
% Usage: intensitycorrected = intensity.*cor
%
% Macro written by Ulla Vainio originally 16.12.2002
% Modified for B1 beamline on 1.10.2007 by UV
% 7.5.2008 UV: Using the plain R^2 correction from now on

hc = 197.3269601*2*pi*10;  % from X-ray data booklet Planck constant times
                           % speed of light in eV*Angstrom units
lambda = hc/energy;
tth = 2*asin(q*lambda/4/pi); % 2theta in radians

dxr = tan(tth(2)); % dx / R

% Instead of R^2 correction our setup has a little different correction
% which we will try to correct by using the data obtained from
% measurements made at different distances at 11 keV
%dist = [935 1384 1835 2735 3635];
%if(distance < dist(1) | distance/dist(1) < 1.1)
%    distanceorig = dist(1);
%elseif(distance < dist(2) | distance/dist(2) < 1.1)
%    distanceorig = dist(2);
%elseif(distance < dist(3) | distance/dist(3) < 1.1)
%    distanceorig = dist(3);
%elseif(distance < dist(4) | distance/dist(4) < 1.1)
%    distanceorig = dist(4);
%elseif(distance < dist(5) | distance/dist(5) < 1.1)
%    distanceorig = dist(5);
%end;
%corR2 = interp1(dist,[0.7046    0.8736    0.9738    0.9881    1.0000],distanceorig,'linear');

cor = zeros(1,length(q));
for(l = 1:length(q))
%   cor(l) = distance^2./cos(tth(l))^3/corR2;
    cor(l) = distance^2./cos(tth(l))^3;
end;

cor = transpose(cor);