function cor = geomcorrectiontheta(tth,distance)
%function cor = geomcorrectiontheta(tth,distance)
% 
% Usage: intensitycorrected = intensity.*cor
%
% Macro written by Ulla Vainio originally 16.12.2002
% Modified for B1 beamline on 1.10.2007 by UV
% 7.5.2008 UV: Using the plain R^2 correction from now on
% 25.4.2009 AW: Now q does not need to be a vector. cor will be of the same
%           size as q.
% 25.4.2009 AW: Renamed geomcorr->geomcorrtheta. It now has theta as an
%           input parameter, not q. Remember: theta, and not 2*theta.
% 8.5.2009 AW: NOW tth is TWO TIMES THETA, not THETA!

cor = distance^2./(cos(tth).^3);
