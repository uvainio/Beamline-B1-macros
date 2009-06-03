function legend1 = plotints(data,param,samplename,energies,symboll,mult)

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
energies2(1:length(energies)) = sort(energies);

if(nargin<6)
  mult = 1;
end;
if(nargin<5)
    symboll = '-';
end;

for(k = 1:sd(2))
  if(strcmp(param(k).Title,samplename)) % & dist/param(k).Dist > 0.95 & dist/param(k).Dist < 1.05)
    if(round(param(k).Energy) == energies2(1))
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sb',symboll)); hold on
%      legend1 = {sprintf('T = %.1f',param(1).Temperature)};
      legend1(1) = {sprintf('E = %.1f',param(k).Energy)};
%      legend1 = {sprintf('%s',param(k).Title)};
    elseif(round(param(k).Energy) == energies2(2))
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sg',symboll)); hold on
      legend1(2) = {sprintf('E = %.1f',param(k).Energy)};
    elseif(round(param(k).Energy) == energies2(3))
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sr',symboll)); hold on
      legend1(3) = {sprintf('E = %.1f',param(k).Energy)};
    elseif(round(param(k).Energy) == energies2(4))
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sk',symboll)); hold on
      legend1(4) = {sprintf('E = %.1f',param(k).Energy)};
    elseif(round(param(k).Energy) == energies2(5))
      loglog(data(k).q,data(k).Intensity*mult,sprintf('%sm',symboll)); hold on
      legend1(5) = {sprintf('E = %.1f',param(k).Energy)};
    end;
  end;
end; hold off

