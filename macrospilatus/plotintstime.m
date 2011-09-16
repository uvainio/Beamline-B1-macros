function legend1 = plotintstime(data,param,samplename,energies,symboll,mult)

% function legend1 = plotintstime(data,param,samplename,energies,symboll,mult)
%
% Example: plotintstime(data,param,'sample',9793,'--');
%
% Maximum five energies in vector energies
%
% Created 2.11.2007 UV

sd = size(data);
energies = round(energies);
energies2 = zeros(5,1);
energies2(1:length(energies)) = energies;

if(nargin<6)
  mult = 1;
end;
if(nargin<5)
    symboll = '-';
end;


counter2 = 0;
for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename)) % & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    if(round(param(k).Energy) == energies2(1))
        counter2 = counter2+1;
    end;
  end;
end; 

counter = 1; firstmeas = 0;
for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename)) % & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    if(round(param(k).Energy) == energies2(1))
        if(firstmeas == 0)
            fsn1 = param(k).FSN;
            firstmeas = 1;
        end;
        if(length(mult)==1)
            loglog(data(k).q,data(k).Intensity*mult^k,sprintf('%s',symboll),'Color',[(counter-1)/counter2 1/counter^2 ((counter2-counter)/counter2)]); hold on
%      loglog(data(k).q,data(k).Intensity*mult,sprintf('%s%s',symboll,colors(counter))); hold on
        elseif(length(mult)>1)
            loglog(data(k).q,data(k).Intensity*mult(k),sprintf('%s',symboll),'Color',[(counter-1)/counter2 1/counter^2 ((counter2-counter)/counter2)]); hold on
        end;
            header = readheader('org_',param(k).FSN,'.header');
            legend1(counter) = {sprintf('FSN %d %d.%d.%d %02d:%02d, T = %.1f ^oC',param(k).FSN,header.Day,header.Month,header.Year,header.Hour,header.Minutes,param(k).Temperature)};
            %   legend1(counter) = {sprintf('FSN %d, %.f min, T = %.1f ^oC',param(k).FSN,sub2times(fsn1,param(k).FSN),param(k).Temperature)};
            counter = counter + 1;
    end;
  end;
end; hold off
%legend(legend1);
