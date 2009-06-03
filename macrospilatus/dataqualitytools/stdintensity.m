function [stdI,meanI] = stdintensity(data,param,sample,energy)

% function [q,meanI,stdI] = stdintensity(data,param,sample,energy)
%
% Gives the standard deviation and mean intensity as a function of q
%
% Created 22.9.2008 Ulla Vainio (ulla.vainio@desy.de)

mm = length(param);
counter = 1;
for(k = 1:mm)
    if(round(param(k).Energy) == round(energy) && strcmp(param(k).Title,sample))
        q = data(k).q;
        temp(:,counter) = data(k).Intensity;
        counter = counter + 1;
    end;
end;
meanI = mean(temp');
stdI = std(temp');

plot(q,stdI./meanI)
ylabel('std / mean intensity')
xlabel('q (1/A)')
title(sprintf('%s',sample))