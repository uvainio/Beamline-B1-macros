function data = readSicalib(fsnsi,fsnagbeh,energy)

% function data = readSicalib(fsnsi,fsnagbeh,energy)
%
% fsnsi = file sequence number of the silicon standard
% energy = calibrated energy
%
% Created 2.4.2009 UV

% Load the silicon measurement
agbeh = load(sprintf('waxs_%05d.dat',fsnagbeh));

% exclude bad pixels
badpixels = [6 307 308 309 380 410 491 492 493 1257:1:1280];
for(k = 1:1280)
    data1(k) = agbeh(k,2);
    if(find(k == badpixels))
      data1(k) = 0;
   end;
end;

data1 = fliplr(data1);

% Load the silicon measurement
si = load(sprintf('waxs_%05d.dat',fsnsi));

% exclude bad pixels
for(k = 1:1280)
    data2(k) = si(k,2);
    if(find(k == badpixels))
      data2(k) = 0;
   end;
end;


data2 = fliplr(data2);
% determine q-range
% flip data so that small angles are on the left
d = [58.373/8 58.373/9 3.1354 1.920];
[q,tth,qpix] = qrange(length(data2),data2+data1,d,energy);

data.q = q;
data.tth = tth;
data.Intensity = data2+data1;
data.Error = sqrt(data2+data1);
data.qpix = qpix;
data.d = d;
