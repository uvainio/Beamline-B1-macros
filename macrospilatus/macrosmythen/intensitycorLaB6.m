function [cor,theorint,intint] = intensitycorLaB6(qpix,intLaB6,peaks,slit)

% function cor = intensitycorLaB6(qpix,intLaB6,peaks,slit)
%
% IMPUT:
%
% tth     = 2theta scale in a vector
% intLaB6 = intensity of the LaB6 measurement in a vector
% peaks = vector of which peaks are taken into the calculation
%         for example [1:5] takes the five first reflections of LaB6
% slit   = if using the slit with angle 4.8, use 'angle'
%
% OUTPUT:
%
% Multiply your intensity with cor.
%
% Created 16.4.2009 Ulla Vainio

% Theoretical d spacings and intensities of LaB6, calculated with
% PowderCell (for experiment 'none' at 12 keV)
dI = [  4.153     167.893
  2.936     571.984
  2.398     383.544
  2.076     272.064
  1.857     803.568
  1.695     533.051
  1.468     284.786];

theorint = dI(peaks,2)/dI(peaks(1),2);

% Let's determine the intensities of all reflections by zooming into the
% reflections

if(strcmp(slit,'angle'))
   slitcor = 1.3418 + [0:1279]/1279*(6.7082-1.3418);
   intLaB6 = intLaB6./slitcor';
end;

for(k = 1:length(peaks))
    plot(intLaB6);
    xlabel('Pixel');
    ylabel('Intensity (arb. units)');
    if(k == 1)
       disp(sprintf('Zoom into the %d. reflection from LaB6.\nLeave a some space around the peak, so that background can be subtracted.\n Press enter after zooming.',peaks(k)))
    else
       disp(sprintf('Zoom into the %d. reflection from LaB6.',peaks(k)));
    end;
    zoom on
    pause
    xrange = round(axis); % Read in the axis and use them to determine the correct x-range
    bg = (intLaB6(xrange(1))+intLaB6(xrange(1)))/2; % Background
    intint(k) = trapz(intLaB6(xrange(1):xrange(2)))-bg*(xrange(2)-xrange(1)); % Integrated intensity at this peak
end;

intint = intint/intint(1);
intint

plot(theorint,intint,'o');
xlabel('Theoretical integrated intensity');
ylabel('Measured integrated intensity');
pause
handl = plot(qpix,theorint,'s',qpix,intint,'o');
set(handl(1),'MarkerFaceColor','b');
set(handl(2),'MarkerFaceColor','g');
legend('Theoretical','Measured');
xlabel('Pixel');
ylabel('Intensity');

pause
handl = plot(qpix,theorint'./intint,'o');
set(handl(1),'MarkerFaceColor','b');
legend('Theoretical/Measured');
xlabel('Pixel');
ylabel('Intensity');


cor = 1;