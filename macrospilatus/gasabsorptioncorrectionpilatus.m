function cor = gasabsorptioncorrectionpilatus(energy,q)

% cor = gasabsorptioncorrectionpilatus(energy,q)
%
% Usage: correcteddata = cor.*data;
% 
% Created 9.10.2007 UV
% Edited: 5.10.2010 UV Absorption correction was wrong! Used mu*d*d instead of mu*d in
% calculation

disp('GAS ABSORPTION CORRECTION USED!!')

detthick = 0.3; % approximately 300 mum thick Si in detector
airthick = 50; % approximately 50 mm thick gas
flighttubewindowthick = 0.15; % approximation for flighttube window thickness

hc = 197.3269601*2*pi*10;  % from X-ray data booklet Planck constant times
                           % speed of light in eV*Angstrom units
lambda = hc/energy;
tth = 2*asin(q*lambda/4/pi); % 2theta in radians

% How many mm the rays travel in the detector
dettravel = 1./cos(tth);
airtravel = 1./cos(tth);
flighttubewindowtravel = 1./cos(tth);

% How much is the relative absorption of rays at that path?
% Detector pressure is about 1.2 atm equivalent to about 910 Torr.
% From http://henke.lbl.gov/optical_constants/gastrn2.html
% we get transmission of 1 mm of Ar at 4 keV - 30 keV energies
% and for 30 - 35 keV we approximate by using the same value as
% at 30 keV, temperature 298 K

load TransmissionSi300mum.dat
tr = TransmissionSi300mum;
if(max(tr(:,1)) > energy && min(tr(:,1)) < energy)
  tr1 = interp1(tr(:,1),tr(:,2),energy,'spline');
elseif(min(tr(:,1)) > energy)
   tr1 = tr(1,2);
else
   tr1 = tr(end,2);
end;
mud = -log(tr1);

% cor1 = (1-exp(-dettravel(1).*mu))./(1-exp(-dettravel.*mu));
cor1 = 1./(1-exp(-dettravel.*mud));

load TransmissionAir760Torr1mm298K.dat
tr = TransmissionAir760Torr1mm298K;
if(max(tr(:,1)) > energy && min(tr(:,1)) < energy)
  tr1 = interp1(tr(:,1),tr(:,2),energy,'spline');
elseif(min(tr(:,1)) > energy)
   tr1 = tr(1,2);
else
   tr1 = tr(end,2);
end;
mud = -log(tr1); 

% cor2 = exp(-airtravel(1).*mu)./exp(-airtravel.*mu);
cor2 = 1./exp(-airtravel.*mud);

load TransmissionPolyimide1mm.dat
tr = TransmissionPolyimide1mm;
if(max(tr(:,1)) > energy && min(tr(:,1)) < energy)
  tr1 = interp1(tr(:,1),tr(:,2),energy,'spline');
elseif(min(tr(:,1)) > energy)
   tr1 = tr(1,2);
else
   tr1 = tr(end,2);
end;
mud = -log(tr1); 

cor3 = 1./exp(-flighttubewindowtravel.*mud); 

cor = cor1.*cor2.*cor3;

%ll = 1:5:length(cor3);
%plot(tth(ll)*180/pi,cor(ll),'-')
%pause
%plot(tth(ll)*180/pi,cor3(ll),'s',tth*180/pi,cor2,'-.',tth(ll)*180/pi,cor1(ll),'.',tth*180/pi,geomcorrection(q,energy,3635),'--',tth*180/pi,geomcorrection(q,energy,3635).*cor)
%legend('Polyimide window 150 \mum','Gas air, 5 cm','Silicon 300 /mum','Geometrical','Total',2)
%legend boxoff
%xlabel('2\theta (degree)')
%pause
%ylabel('Correction to intensity')