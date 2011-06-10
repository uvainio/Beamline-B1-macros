function [legend1,data1,param1] = plotintscrgb(data,param,samplename,energies,symboll,colorrgb,mult)

% function legend1 = plotintscrgb(data,param,samplename,energies,symboll,colorrgb,mult)
%
% Example: plotintscrgb(data,param,'Ta50h',9793,'--',[0.5 1 0.25]);
%
% Maximum one energy
%
% Created 2.11.2007 UV

sd = size(data);
energies = round(energies);
energies2 = zeros(5,1);
energies2(1:length(energies)) = energies;

if(nargin<7)
  mult = 1;
end;

titles = [];
for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename)) % & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    if(round(param(k).Energy) == energies2(1))
      data1 = data(k); param1 = param(k);
      handl = loglog(data(k).q,data(k).Intensity*mult,sprintf('%s',symboll)); hold on
      set(handl,'Color',colorrgb);
      set(handl,'LineWidth',1);
      set(handl,'MarkerSize',5);
%      legend1 = {sprintf('T = %.1f',param(1).Temperature)};
       titleis = [regexprep(sprintf('%s',param(k).Title), '_', ' ')];
       if(isempty(findstr(titles,titleis)))
         legend1 = {titleis};
         titles = [titles,titleis];
       end;
    end;
  end;
end; hold off

set(gca,'LineWidth',1);
set(gca,'FontSize',18);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');