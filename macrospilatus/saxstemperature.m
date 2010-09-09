function saxstemperature(fsns,samplename,energy)

% function saxstemperature(fsns,samplename,energy)
%
% E.g. saxswaxstemperature([15:200])
% Plots the SAXS data saved into binned files
% to two pictures with a variable color and legend of temperature.
%
% UV 22.5.2009

[datasaxs,paramsaxs] = readbinnedpilatus(fsns);
%[datasaxs,paramsaxs] = readintnormpilatus(fsns);

legend1 = plotintstime(datasaxs,paramsaxs,samplename,energy);
legend(legend1,-1);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
title(sprintf('Sample %s',samplename))

