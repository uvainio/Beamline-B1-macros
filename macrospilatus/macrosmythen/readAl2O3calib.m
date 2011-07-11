function data = readAl2O3calib(data,energy,peaks)

% function data = readAl2O3calib(data,energy,peaks)
%
% dataLaB6 = [pixels intensity] of a Lanthanum hexaboride measurement
% energy = calibrated energy
% peaks = number of reflections of alpha Al2O3
%
% Created 9.4.2009 UV


% exclude bad pixels
badpixels = [6 307 308 309 380 410 491 492 493 1257:1:1280];

%data1 = fliplr(data1);

% setting bad pixels to zero
for(k = 1:1280)
    data2(k) = data(k,2);
    if(find(k == badpixels))
      data2(k) = 0;
   end;
end;

data2 = fliplr(data2);
% determine q-range
% flip data so that small angles are on the left
% d spacings for Al2O3
dAl2O3 = []*10; % in Angstrom

[q,tth,qpix,lamq] = qrange(length(data2),data2,dAl2O3(peaks),energy);

data.q = q;
data.tth = tth;
data.Intensity = data2;
data.Error = sqrt(data2);
data.qpix = qpix;
data.d = dLaB6(peaks);
data.lamq = lamq;
