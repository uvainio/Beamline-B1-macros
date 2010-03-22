function legend1 = plotints(data,param,samplename,energies,symboll,mult)

% function legend1 = plotints(data,param,samplename,energies,symboll,mult)
%
% Example: plotints(data,param,'Ta50h',[9793 9856 9878 9886],'--');
%
% Maximum five energies in vector energies
%
% Created 2.11.2007 UV
% Corrected legend to more universal, 10.6.2009 Ulla Vainio

sd = size(data);
energies = round(energies);
energies2 = zeros(5,1);
energies2(1:length(energies)) = sort(energies);

if(nargin<6)
  mult = 1;
end;
if(nargin<5)
    symboll = '-';
end;

flagenergy1 = 0;
flagenergy2 = 0;
flagenergy3 = 0;
flagenergy4 = 0;
flagenergy5 = 0;
counterlegend = 1;
% Plot only for legends
for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename)) % & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    if(round(param(k).Energy) == energies2(1) && flagenergy1 == 0)
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sb',symboll)); hold on
      if(flagenergy1 == 0)% && counterlegend <= length(energies2)) % any(energies2)
         legend1(counterlegend) = {sprintf('E = %.1f',param(k).Energy)};
         counterlegend = counterlegend + 1;
         flagenergy1 = 1;
      end;
    elseif(round(param(k).Energy) == energies2(2) && flagenergy1 == 1 && flagenergy2 == 0)
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sg',symboll)); hold on
      if(flagenergy2 == 0)% && counterlegend <= length(energies2)) % -any(energies2)
         legend1(counterlegend) = {sprintf('E = %.1f',param(k).Energy)};
         counterlegend = counterlegend + 1;
         flagenergy2 = 1;
      end;
    elseif(round(param(k).Energy) == energies2(3) && flagenergy2 == 1 && flagenergy3 == 0)
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sr',symboll)); hold on
      if(flagenergy3 == 0)% && counterlegend <= length(energies2)) % -any(energies2)
         legend1(counterlegend) = {sprintf('E = %.1f',param(k).Energy)};
         counterlegend = counterlegend + 1;
         flagenergy3 = 1;
      end;
    elseif(round(param(k).Energy) == energies2(4) && flagenergy3 == 1  && flagenergy4 == 0)
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sk',symboll)); hold on
      if(flagenergy4 == 0)% && (counterlegend <= length(energies2))) % -any(energies2)
         legend1(counterlegend) = {sprintf('E = %.1f',param(k).Energy)};
         counterlegend = counterlegend + 1;
         flagenergy4 = 1;
      end;
    elseif(round(param(k).Energy) == energies2(5) && flagenergy4 == 1 && flagenergy5 == 0)
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sm',symboll)); hold on
      if(flagenergy5 == 0)% && (counterlegend <= length(energies2))) % -any(energies2)
         legend1(counterlegend) = {sprintf('E = %.1f',param(k).Energy)};
         counterlegend = counterlegend + 1;
         flagenergy5 = 1;
      end;
    end;
  end;
end;

% Plot all
for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename)) % & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    if(round(param(k).Energy) == energies2(1))
      handl = loglog(data(k).q,data(k).Intensity*mult,sprintf('%sb',symboll)); hold on
      set(handl,'LineWidth',1);
    elseif(round(param(k).Energy) == energies2(2))
      handl = loglog(data(k).q,data(k).Intensity*mult,sprintf('%sg',symboll)); hold on
      set(handl,'LineWidth',1);
    elseif(round(param(k).Energy) == energies2(3))
      handl = loglog(data(k).q,data(k).Intensity*mult,sprintf('%sr',symboll)); hold on
      set(handl,'LineWidth',1);
    elseif(round(param(k).Energy) == energies2(4))
      handl = loglog(data(k).q,data(k).Intensity*mult,sprintf('%sk',symboll)); hold on
      set(handl,'LineWidth',1);
    elseif(round(param(k).Energy) == energies2(5))
      handl = loglog(data(k).q,data(k).Intensity*mult,sprintf('%sm',symboll)); hold on
      set(handl,'LineWidth',1);
    end;
  end;
end; hold off

set(gca,'LineWidth',1);
set(gca,'FontSize',18);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
legend(legend1)