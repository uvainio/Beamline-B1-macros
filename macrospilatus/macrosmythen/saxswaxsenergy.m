function saxswaxsenergy(fsns,samplename,energy)

% function saxswaxsenergy(fsns,samplename,energy)
%
% E.g. saxswaxsenergy([15:200],'MySample',[19000 19500])
% Plots the SAXS and WAXS data saved into intnorm and waxs_***.cor files
% to two pictures with a variable color and legend of temperature.
%
% UV 22.5.2009

[datasaxs,paramsaxs] = readintnormpilatus(fsns);

[datawaxs,paramwaxs] = readintnormmythen(fsns);


subplot(2,1,1)
legend1 = plotints(datasaxs,paramsaxs,samplename,energy,'-');
legend(legend1,-1);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
title(sprintf('Sample %s',samplename))

subplot(2,1,2)
legend1 = plotints(datawaxs,paramwaxs,samplename,energy,'-');
%legend(legend1,-1);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (relative units)');
set(gca,'XScale','Lin');
set(gca,'YScale','Lin');
