function dataout = plotsube(sample,e1,e2,const1,filetype,mult1,fsnrange)

% function dataout = plotsube(sample,e1,e2,const1,filetype,mult1,fsnrange)
%
% sample = name of sample, e.g. 'PEI5mgml'
% e1 = energy 1
% e2 = energy 2
% filetype = type of file ('binned', 'norm', 'summed', 'united' etc.).
%      Defaults to 'binned', if not given.
% fsnrange = range of file sequence numbers. Defaults to 1:1000 if absent.
%
% Created: Ulla Vainio, 20??
% Modified: Andras Wacha (awacha at gmail dot com), added 'filetype' and
% 'fsnrange' optional parameters.

if nargin<7
    fsnrange=[1:1000];
end

%[data,param]=readbinnedpilatus([166:169]);
eval(sprintf('[data,param] = read%spilatus(fsnrange);',filetype));

sd = size(data);
for(k = 1:sd(2))
    if(strcmp(param(k).Title,sample) && param(k).Energy<(e2+1) && param(k).Energy>(e2-1))
        intensitywater = data(k).Intensity;
        errorwater =data(k).Error;
        energycalib2 = param(k).EnergyCalibrated;
        q = data(k).q;
    elseif(strcmp(param(k).Title,sample) && param(k).Energy<(e1+1) && param(k).Energy>(e1-1))
        intensitysample = data(k).Intensity;
        errorsample = data(k).Error;
        energycalib1 = param(k).EnergyCalibrated;
        q = data(k).q;
    end;
end;
size(q)
size(intensitysample)
size(intensitywater)

dataout = [q intensitysample-intensitywater+const1 sqrt(errorsample.^2+errorwater.^2)];
loglog(q,intensitysample+const1,'--',q,intensitywater,'.',q,intensitysample-intensitywater*mult1+const1)
sample = [regexprep(sprintf('%s',sample), '_', ' ')];
legend(sprintf('E1 = %.1f eV',energycalib1),sprintf('E2 = %.1f eV',energycalib2),'Difference',3)
xlabel(sprintf('q (1/%c)',197))
ylabel('Intensity (1/cm)')  
title(sprintf('%s',sample));

