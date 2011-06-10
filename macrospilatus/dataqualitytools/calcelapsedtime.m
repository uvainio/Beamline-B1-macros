function times = calcelapsedtime(data,param,samplename,energy1,dist)

% function times = calcelapsedtime(data,param,samplename,energy1,dist)
%
% Calculates the elapsed time in minutes starting from first measurement
% found for the samplename and energy. First measurement is 0.
%
% Created 12.8.2009 Ulla Vainio (ulla.vainio@desy.de)

sd = size(data);

times(1) = 0;
counter = 1;
for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename) & round(param(k).Energy) == energy1 & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    header = readheader('org_',param(k).FSN,'.header');
    if(counter == 1)
        time0 = param(k).FSN;
    else
        times(counter) = sub2times(param(k).FSN,time0);
    end;
    counter = counter + 1;
  end;
end; hold off
%legend(legend1);
