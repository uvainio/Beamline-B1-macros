function [q,tth,lamq] = qtanfit(qh,qpix,lambda,n)

% [q,tth,lamq] = qtanfit(qh,qpix,lambda,n)
%
% Part of qrange.m macro.
% Fits an arctan function to (qh,qpix)
% 
% qh are the theoretical q (= 4*pi*sin(theta)/lambda) values
% in a vector corresponding to the positions of the peaks
% in the vector qpix (in pixels).
% n is the length of the vector q, and lambda is the used wavelength.
% 
% Author: Ulla Vainio, spring 2003
% April 2009 Ulla Vainio, added the zero point variation

pix = [0:(n-1)];

%lamq = [0.0005 100 300];
lamq = [50/130000 300];
exitflag = 0;
n = 0;

while (exitflag ~=1 & n < 20)
  [lamq,feval,exitflag] = fminsearch('tanfit',lamq,[],qpix,qh,lambda);
  n
  n = n + 1;
end;

if (n < 9) disp('Q values were succesfully fitted.'); end;

%q = lamq(2)*4*pi*sin(atan(lamq(1)*(pix+lamq(3)))/2)/lambda;
q = 4*pi*sin(atan(lamq(1)*(pix+lamq(2)))/2)/lambda;
tth = 2*asin(lambda*q/4/pi)*180/pi;

plot(qpix,qh,'.',pix,q,'-r')
xlabel('Pixel')
ylabel('q [A^{-1}]')
title('Fit to the theoretical values for q at the positions of the diffraction peaks')
