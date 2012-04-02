function dataout = plotsub(sample,bg,energy,filetype,mult,fsnrange)

% function dataout = plotsub(sample,bg,energy,filetype,mult,fsnrange)
%
% sample = name of sample, e.g. 'PEI5mgml'
% bg = name of background, e.g. 'water'
% mult = multiplication factor for background
% filetype = type of file ('binned', 'norm', 'summed', 'united' etc.).
%      Defaults to 'binned' if not given.
% fsnrange = range of file sequence numbers. Defaults to 1:1000 if absent.
%
% Created: Ulla Vainio, 20??
% Modified: Andras Wacha (awacha at gmail dot com), added 'filetype' and
% 'fsnrange' optional parameters.

if nargin<6
    fsnrange=[1:1000];
end

if(nargin<5)
    mult = 1;
end;

if (nargin<4)
    filetype='binned';
end;

%[data,param]=readbinnedpilatus([166:169]);
eval(sprintf('[data,param] = read%spilatus(fsnrange);',filetype));

sd = size(data);
for(k = 1:sd(2))
    if(strcmp(param(k).Title,bg) && round(param(k).Energy)==round(energy) )
        intensitywater = data(k).Intensity;
        errorwater =data(k).Error;
        energycalibrated = param(k).EnergyCalibrated;
        q = data(k).q;
    elseif(strcmp(param(k).Title,sample) && round(param(k).Energy)==round(energy) )
        intensitysample = data(k).Intensity;
        errorsample = data(k).Error;
        q = data(k).q;
    end;
end;

dataout = [q intensitysample-mult*intensitywater sqrt(errorsample.^2+errorwater.^2)];
loglog(q,intensitysample,'--',q,mult*intensitywater,'.',q,intensitysample-mult*intensitywater)
sample = [regexprep(sprintf('%s',sample), '_', ' ')];
bg = [regexprep(sprintf('%s',bg), '_', ' ')];
legend(sample,bg,'Difference',3)
xlabel(sprintf('q (1/%c)',197))
ylabel('Intensity (1/cm)')  
title(sprintf('Calibrated energy %.1f',energycalibrated));

