function data = readLaB6AgBehcalib(dataLaB6,energy,peaks,dataAgBeh,peaksAgBeh)

% function data = readLaB6AgBehcalib(dataLaB6,energy,peaks,dataAgBeh,peaks)
%
% dataLaB6 = [pixels intensity] of a Lanthanum hexaboride measurement
% energy = calibrated energy
% peaks = number of reflections of LaB6
% peaksAgBeh = order of the reflection in AgBeh in vector
% 
%
% Created 9.4.2009 UV


% exclude bad pixels
badpixels = [6 307 308 309 380 410 491 492 493 1257:1:1280];

%data1 = fliplr(data1);

% setting bad pixels to zero
for(k = 1:1280)
    data2(k) = dataLaB6(k,2)+dataAgBeh(k,2);
    if(find(k == badpixels))
      data2(k) = 0;
   end;
end;

data2 = fliplr(data2);
% determine q-range
% flip data so that small angles are on the left
% From National Institute of Standards & Technology Certificate
% Standard Reference Material� 660a Lanthanum Hexaboride Powder
% Line Position and Line Shape Standard for Powder Diffraction
% from 0.1695 0.1468 onwards from PowderCell file.
dLaB6 = [0.41569 0.29394 0.24000 0.20785 0.18590 0.1695 0.1468 0.1384 0.1313 0.1252 0.1199 0.1152 0.1110 0.1038 0.1007]*10; % in Angstrom
dAgBeh = 58.18./peaksAgBeh; % in Angstrom

[q,tth,qpix,lamq] = qrange(length(data2),data2,[dAgBeh,dLaB6(peaks)],energy);

data.q = q;
data.tth = tth;
data.Intensity = data2;
data.Error = sqrt(data2);
data.qpix = qpix;
data.d = [dAgBeh,dLaB6(peaks)];
data.lamq = lamq;
