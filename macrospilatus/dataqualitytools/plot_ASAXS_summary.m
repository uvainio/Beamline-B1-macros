function plot_ASAXS_summary(fsns,samplename,referencename)
%
%
% Created by A. Wacha March 2012

if nargin<3
    referencename='Reference_on_GC_holder_before_sample_sequence';
end

minfsn=min(fsns(:));
maxfsn=max(fsns(:));


clf;
assesstransmissionpilatus(fsns,samplename);
print('-dpng','-r300', sprintf('images/transmission_%s_%d_%d.png',samplename,minfsn,maxfsn));

clf;
assesstransmissionpilatus(fsns,referencename);
print('-dpng','-r300', sprintf('images/transmissionGC_%s_%d_%d.png',referencename,minfsn,maxfsn));


clf;
[data,param] = readsummedpilatus(fsns);
for i = numel(param):-1:1
    if ~strcmp(param(i).Title,samplename)
        param(i)=[];
        data(i)=[];
    end
end
energies=unique([param.Energy]);
legend1 = plotints_new(data,param,samplename,energies,'-'); hold on;
plot(data(2).q,data(1).Intensity-data(end).Intensity,'b.-','displayname','E1-Elast');
plot(data(2).q,data(2).Intensity-data(end).Intensity,'gs-','displayname','E2-Elast');
plot(data(2).q,data(1).Intensity-data(2).Intensity,'rd-','displayname','E1-E2');
legend off
legend('location','southwest');
legend show
grid
title(sprintf('%s #%d : %d',samplename,minfsn,maxfsn),'interpreter','none');
hold off;
print('-dpng','-r300',sprintf('images/ASAXS_%s_%d_%d.png',samplename,minfsn,maxfsn));
