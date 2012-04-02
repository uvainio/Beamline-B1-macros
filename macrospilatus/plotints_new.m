function [legend1, patches1] = plotints_new(data,param,samplename,energies,symboll,mult)

% function [legend1,patches1] = plotints(data,param,samplename,energies,symboll,mult)
%
% Example: plotints(data,param,'Ta50h',[9793 9856 9878 9886],'--');
%
% Maximum 7 energies in vector energies (can be increased easily)
%
% Created 2.11.2007 UV
% Corrected legend to more universal, 10.6.2009 Ulla Vainio
% Refactored 27.03.2012 AW

%Add more colors if you want to use more energies...
colors={'b','g','r','k','m','c','y'};

%Find the unique energy values, but we don't use matlab's unique(), because
%of the finiteness of numeric precision
energies_sorted=sort(energies);
for i = numel(energies_sorted):-1:2
    if compare_energies(energies_sorted(i),energies_sorted(i-1))
        energies_sorted(i)=[];
    end
end

if(nargin<6)
  mult = 1;
end;
if(nargin<5)
    symboll = '-';
end;

%pre-allocate: for each energy there will correspond a legend name and a
%graphics handle in patches1
legend1=cell(1,numel(energies_sorted));
legend1(:)='';
patches1=zeros(1,numel(energies_sorted));
% Plot all
saved_hold_state=ishold;
for k = 1:numel(data)
    if ~strcmp(param(k).Title,samplename)
        continue % do not go further if this is not the sample we want
    end
    energy_idx=0;
    for i = 1:numel(energies_sorted)
        if compare_energies(param(k).Energy,energies_sorted(i))
            energy_idx=i;
        end
    end
    if energy_idx<=0 %energy of the file is not in energies: skip it
        continue
    end
    patches1(energy_idx) = loglog(data(k).q, data(k).Intensity*mult, sprintf('%s%s',symboll,colors{energy_idx}),'displayname',sprintf('%.1f eV',energies_sorted(energy_idx))); hold on;
    set(patches1(energy_idx),'LineWidth',1);
    legend1{energy_idx}=sprintf('%.1f eV',energies_sorted(energy_idx));
end; 
if ~saved_hold_state
    hold off;
end
set(gca,'LineWidth',1);
set(gca,'FontSize',18);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
legend(legend1)

function equals=compare_energies(e1,e2,tolerance)
%Compare two energies, return 1 if they can be considered the same, 0 if
%not
%
% Inputs:
%     e1: energy 1
%     e2: energy 2
%     tolerance: threshold for  the absolute difference of e1 and e2.
%         Defaults to 0.5 eV if not given.
%
% Outputs: 1 if abs(e1-e2)<tolerance, 0 otherwise
if nargin<3
    tolerance=0.5;
end
equals=abs(e1-e2)<tolerance;
