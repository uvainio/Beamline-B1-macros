function saxstemperature(fsns,samplename,energy)

% function saxstemperature(fsns,samplename,energy)
%
% E.g. saxswaxstemperature([15:200])
% Plots the SAXS and WAXS data saved into intnorm and waxs_***.cor files
% to two pictures with a variable color and legend of temperature.
%
% UV 22.5.2009

[datasaxs,paramsaxs] = readbinnedpilatus(fsns);
%[datasaxs,paramsaxs] = readintnormpilatus(fsns);


%subplot('Position',[0.1 0.55 0.77 0.4])
legend1 = plotintstime(datasaxs,paramsaxs,samplename,energy);
legend(legend1,-1);
%xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
xlabel(sprintf('q (1/%c)',197));
title(sprintf('Sample %s',[regexprep(sprintf('%s',samplename), '_', ' ')]))

