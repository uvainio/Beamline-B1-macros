function saxswaxstemperature(fsns,samplename,energy,what)

% function saxswaxstemperature(fsns,samplename,energy,what)
%
% E.g. saxswaxstemperature([15:200])
% Plots the SAXS and WAXS data saved into intnorm and waxs_***.cor files
% to two pictures with a variable color and legend of temperature.
%
% UV 22.5.2009

if nargin<4
   what='binned';
end

if(~strcmp(samplename,'Reference_on_GC_holder_before_sample_sequence'))
    eval(sprintf('[datasaxs,paramsaxs] = read%spilatus(fsns);',what));
else
   [datasaxs,paramsaxs] = readintnormpilatus(fsns);
end;
%[datawaxs,paramwaxs] = readintnormmythen(fsns);
[datawaxs,paramwaxs] = readflatfieldmythen(fsns);


subplot('Position',[0.1 0.55 0.77 0.4])
legend1 = plotintstime(datasaxs,paramsaxs,samplename,energy);
legend(legend1,-1);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
title(sprintf('Sample %s (cyan: FSN %d; dark red: FSN %d)', ...
    [regexprep(sprintf('%s',samplename), '_', ' ')], ...
    fsns(1), fsns(end)))

subplot('Position',[0.1 0.1 0.77 0.4])
plot(0,0)
if(~strcmp(samplename,'Reference_on_GC_holder_before_sample_sequence'))
   legend1 = plotintstime(datawaxs,paramwaxs,samplename,energy);
   %legend(legend1,-1);
   xlabel(sprintf('q (1/%c)',197));
   ylabel('Intensity (relative units)');
   set(gca,'XScale','Lin');
   set(gca,'YScale','Lin');

   set(gcf,'Position',[443    47   786   892]);
   set(gcf,'PaperPosition',[0.634518 0.634517 19.715 28.4084]);
end;
warning off MATLAB:Axes:NegativeDataInLogAxis
