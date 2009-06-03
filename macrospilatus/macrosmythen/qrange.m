function [q,tth,qpix,lamq] = qrange(npix,data,d,energy)

% function [q,tth,qpix,lamq] = qrange(npix,data,d,energy)
%
% IN:
%
% npix       The number of pixels wanted in the q-vector.
%            For example npix = length(data).
% data       The calibration standard data (silver behenate) in a vector.
% d          The distances between the diffraction planes in Angstroms in a vector.
%            For silicon 3.1354 and 1.920.
%            For silver behenate use value 58.373/n.
%            (T.C. Huang, H. Toraya, T.N. Blanton and Y. Wu (1993)
%            X-ray Powder Diffraction Analysis of Silver Behenate, a Possible
%            Low-Angle Diffraction Standard. Journal of Applied Crystallography
%            26, 180 - 184.)
% energy     Calibrated measurement energy
%
% OUT:
%
% q          Scattering vector q at pixels pix.
% tth        2theta scattering angle.
% qpix       The places of the fitted peaks at the scale 0:(length(data)-1)
%
% USAGE:
% After the initiation fo the macro it will ask you to zoom to the
% first visible diffraction peak. This should be the peak you have
% indicated to the macro with 'firstpeak'. Then zoom to each peak
% until you reach the last peak.
% 
% NOTE:
% First q-value is zero, since it corresponds to the first
% pixel in the intensity profiles gained from the integration
% by imageint.m, sectint.m etc.
%
% NEEDS MACROS: guespeak.m, gaussianfit.m, gaussianline.m and tanfit.m
%
% Authored by Ulla Vainio 6.1.2003
% Editions
% 3.4.2003 (UV): qpix = [0 lam(:,2)'] => qpix = [0 (lam(:,2)'-1)]

pix = [0:(npix-1)];
data = data;

figure(1);plot(data);zoom on
j1 = input('Zoom figure around the first visible diffraction peak. Leave a few pixels around the peak.');
ax = round(axis);
axv = ax(3):ax(4);
axh = ax(1):ax(2);


lam = zeros(length(d),5);

n = 0; exitflag = 0;
for(j=1:length(d))           % Minimize the parameters.
  if(j>1)
    figure(1);plot(data);zoom on
    sprintf('Zoom figure around the %g. diffraction peak.',j)
    j1 = input('');
    ax = round(axis);
    axv = ax(3):ax(4);
    axh = ax(1):ax(2);
  end;
  lam(j,:) = guespeak(data,axv,axh);    % Gues the parameters.
  plot([1:length(data)],data,'.',axh,gaussianline(lam(j,:),axh));axis(ax);
  title('First guess.'); xlabel('Pixel'); ylabel('Intensity');
  pause
  while(exitflag == 0 & n < 10),
    n
    [lam(j,:),fval,exitflag] = fminsearch('gaussianfit',lam(j,:),[],data(axh),axh);
    n = n + 1;
  end;
  plot([1:length(data)],data,'.',axh,gaussianline(lam(j,:),axh));axis(ax);
  title('Final fit.'); xlabel('Pixel'); ylabel('Intensity');
  pause
  n = 0; exitflag = 0;
end;

qh = 2*pi./d;
qpix = [(lam(:,2)'-1)]
lambda = 2*pi*1973.269601/energy;

lamq = [50/130000 300];

exitflag = 0;
n = 0;
while (exitflag ~=1 & n < 20)
  [lamq,feval,exitflag] = fminsearch('tanfit',lamq,[],qpix,qh,lambda);
  n
  n = n + 1;
end;
if (n < 9) disp('Q values were succesfully fitted.'); end;

q = 4*pi*sin(atan(lamq(1)*(pix+lamq(2)))/2)/lambda;
tth = 2*asin(lambda*q/4/pi)*180/pi;

plot(qpix,qh,'.',pix,q,'-r')
xlabel('Pixel')
ylabel('q [A^{-1}]')
title('Fit to the theoretical values for q at the positions of the diffraction peaks')





