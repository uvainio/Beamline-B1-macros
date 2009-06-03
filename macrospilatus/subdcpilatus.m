function [Aout,Aouterr] = subdcpilatus(A1,header1,summed1,sens,senserr,dclevel,transm)

% function [Aout,Aouterr] = subdcpilatus(A1,header1,summed1,sens,senserr,dclevel)
%
% IN:
% A1 = matrix from which dark currect is to be subtracted
% header1 = headers of the files from which matrix A1 was obtained
% summed1 = put 1 if you haven't added the data
%           otherwise a vector of the FSNs of the added data
% sens = sensitivity matrix of the detector, put ones(256,256) if you don't
%        have one
% senserr = error of sensitivity, put zeros(256,256) if you don't have it
%
% OUT:
% Aout = 
%      The data has been corrected for:
%      - corrected for change in primary intensity (monitor)
%      - the dark current has been subtracted
%      - corrected for detector sensitivity (divided by)
%      - corrected for transmission (divided by)
%      - normalised by beam cross section which is obtained from
%        width of slit 2 (divided by)
%      - corrected for detector dead time (Sum/Total)
% 
% Aouterr = the error matrix of the data
% 
% Created: 20.8.2007 Ulla Vainio, ulla.vainio@desy.de
% Edited: 2.1.2008 UV, normalisation with cm^2 to beamsize instead of mm^2
% Edited: 7.5.2008 UV, normalization changed to pixel size to mm^2,
%         this has no effect in ASAXS, but it
%         does affect the calculation of the primary intensity in absolute units
% Edited: 18.2.2009 UV, modified for PILATUS, which has no dark current

% Take average transmission
if(nargin < 7) % Normal case
  transm1 = getfield(header1(1),'Transm');
else % special case when using theoretical transmission given separately
    transm1 = transm;
end;
% Get anode counts, monitor counts, and measurement time of sample
an1 = getfield(header1(1),'Anode');
mo1 = getfield(header1(1),'Monitor');
meastime1 = getfield(header1(1),'MeasTime');
if(length(summed1)>1) % if matrix is from many measurements
  for(k = 2:length(summed1))
    transm1 = [transm1 getfield(header1(k),'Transm')];
    an1 = an1 + getfield(header1(k),'Anode');
    mo1 = mo1 + getfield(header1(k),'Monitor');
    meastime1 = meastime1 + getfield(header1(k),'MeasTime');
  end;
end;
transm1ave = mean(transm1);
transm1err = std(transm1);
disp(sprintf('FSN %d \tTitle %s \tEnergy %.1f \tDistance %d',getfield(header1(1),'FSN'),getfield(header1(1),'Title'),getfield(header1(1),'Energy'),getfield(header1(1),'Dist')));
disp(sprintf('Average transmission %.4f +/- %.4f',transm1ave,transm1err))


% The dark current from the monitor counts is so small that it does not
% need to be subtracted (less than 1 cps)
monitor1corrected = mo1;

% Subtract dark current level and normalise with monitor and sensitivity
A2 = (A1-dclevel*meastime1)./sens/monitor1corrected;

errA1 = sqrt(A1);

% Error propagation of  dark current subtraction
errA2 = sqrt((1./sens/monitor1corrected).^2.*errA1.^2 + ...
    ((A1)./monitor1corrected./(sens.^2)).^2.*senserr.^2);

% Correct for transmission (angle dependence of transmission
% correction is treated later)
A3 = A2/(transm1ave);
% Error propagation of anode counts and transmission
errA3 = sqrt((1/transm1ave).^2.*errA2.^2 + ...
       (A2/transm1ave^2).^2.*transm1err^2);

% Normalise by pixel size
BX = 0.172; % in mm for PILATUS
BY = 0.172; % in mm
Aout = A3/(BX*BY);
Aouterr = errA3/(BX*BY);
