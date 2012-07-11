function plotallwaxs(fsns,what,samplenames,energy)
%function plotallwaxs(fsns,what,samplenames,energy)
%
% Plot binned/summed/united data
%
% Inputs:
%     fsns: fsn range (defaults to 1:1000);
%     what: 'binned' or 'summed' or 'united'. The corresponding
%         read<what>pilatus.m macro should exist. Defaults to 'binned'.
%     samplenames: cell array of the sample names (e.g.
%         {'sample1','sample2', 'sample3'} or fieldnames(thicknesses).
%         Defaults to all possible samplenames.
%     energy: photon energy (apparent). Default: autodetection from
%         measurements.
%
% This function respects the hold state at start and keeps it unchanged.
%
% Created: 25.03.2012 Andras Wacha (awacha at gmail dot com)
% Edited: 24.5.2012 Ulla Vainio, changed to WAXS plotting

% Plotting
curvestyle = {'.-b','-og','-xr','-+m','-*k','--sb','--dg','--vr','-^c','--<k','->b','-.ob','-.gs'};

hold_state_at_start=ishold;

if nargin<1
    fsns=1:1000;
end
if nargin<2
   what='binned';
end
eval(sprintf('[datas,params] = read%s(fsns);',what));
if nargin<3
    samplenames=unique({params.Title});
end
if nargin<4
    energy=unique([params.Energy]);
end

legend1={}; patches=[];
for i = 1:numel(samplenames);
    if i>numel(curvestyle)
        error(['Only ',num2str(numel(curvestyle)),' curve styles are defined in function ',mfilename,'. Please add more if you want to plot more than this number of curves.']);
    end
    try
        legend1(i) = plotintsc(datas,params,samplenames{i},energy,curvestyle{i});
        set(gca,'XScale','Lin');
        set(gca,'YScale','Lin');
        ylabel('Intensity (arb. units)');
        patches(i) = max(get(gca,'children'));
    catch xcep
        %rethrow(xcep)
        disp(['Plotting sample ',samplenames{i},' failed, maybe the ', what,' file does not (yet) exist.']);
    end    
    hold on;
end
%grid on;
legend(patches,legend1);
if ~hold_state_at_start
   hold off;
end
