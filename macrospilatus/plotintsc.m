function [legend1,data1,param1] = plotintsc(data,param,samplename,energies,symboll,mult)

% function legend1 = plotints(data,param,samplename,energies,symboll,mult)
%
% Example: plotints(data,param,'Ta50h',[9793 9856 9878 9886],'--');
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

titles = [];
for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename)) % & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    if(round(param(k).Energy) == energies2(1))
        data1 = data(k); param1 = param(k);
      handl = loglog(data(k).q,data(k).Intensity*mult,sprintf('%s',symboll)); hold on
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

