
%%%% PILATUS data
addpath D:\Projekte\2009\project\processing
addpath D:\Projekte\2009\project\data1
cd D:\Projekte\2009\project
addpath D:\matlabmacros\2008\macrospilatus
addpath D:\matlabmacros\2008\macrosmythen
addpath D:\matlabmacros\2008\macrospilatus\calibrationfiles
addpath D:\matlabmacros\2008\macrospilatus\analysis
addpath D:\matlabmacros\2008\macrospilatus\dataqualitytools

% Energy scale calibration
energycalib = [13880.70 17995.88 ]; % Pt_L3, Pt_L1, Pt_L2, Zr_K
energymeas = [13862 17981.5]; % The measured positions of 1st inflection points

pri = [453   473    46    63];
sens = ones(619,487);
errorsens = zeros(size(sens));

% A = read2dB1datapilatus('org_',207,'.tif');
% mask = makemask(mask,A);

% save D:\Projekte\2009\project\processing\mask.mat mask
load D:\Projekte\2009\project\processing\mask.mat

%%%% loading test images
A = GetPilatus(mask,'test_',1,1000);
% Show all data files
getsamplenamespilatus('org_',2:7,'.header');

load D:\Projekte\2009\project\processing\mask.mat
load D:\Projekte\2009\project\processing\maskshort.mat

%%%%%%%%%%%%%%%%%%%
%%%%----------------
%%%%%%%%%%%%%%%%%%%%

thicknesses = struct('sample1',0.01,'sample2',0.01,'Reference_on_GC_holder_after_sample_sequence',0.1); % Thickness in cm

%%%% LONG distance
B1normintallpilatus([11:17],thicknesses,sens,errorsens,mask,energymeas,energycalib,0,pri,133,300);

%%% SHORT distance
B1normintallpilatus([206:207],thicknesses,sens,errorsens,maskshort,energymeas,energycalib,0,pri,133,300);

[datap,paramp] = readintnormpilatus(91:400);
legend1 = plotints(datap,paramp,'sample1',[17030],'-',1); hold on
hold off
legend([legend1]);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
% print -depsc D:\Projekte\2009\project\processing\SAXS

[datap,paramp] = readintnormpilatus(91:400);
plotintstime(datap,paramp,'sample1',[17030],'--',1); hold on
hold off


%%% Bin the data
savebinnedpilatus([??:??],3625,100,0.008,0.29); % Long
savebinnedpilatus([??:??],925,100,0.005,1.1); % Short

[data,param] = readbinnedpilatus([1:800]);

errorbar(datap(6).q,datap(6).Intensity,datap(6).Error)

% Unite data
[datap,paramp] = readbinnedpilatus([1:700]);
uniq = 0.07; q1 = 0.06; q2 = 0.09; % Parameters
sumanduniteB1pilatus(datap,paramp,'sample1',uniq,[3635 935],q1,q2);


[datap,paramp] = readunitedpilatus(1:700);
legend1 = plotints(datap,paramp,'sample1',[17000],'-',1); hold on
hold off
legend(legend1)


plot(datap(1).q,datap(1).Error./datap(1).Intensity)

%%%% SUM data measured on only one distance

[data,param] = readbinnedpilatus([??:??]);
sumandsaveB1pilatus(data,param,'sample1');
[datap,paramp] = readsummedpilatus([??:??]);
legend1 = plotints(datap,paramp,'sample1',[16496 16882 16986 17020 17030 ],'.-',1); hold on
hold off
legend(legend1)


%%%%% READ and CORRECT XANES data to the correct energy scale
muds = readxanes('abt_',[??:??],'.fio',energymeas,energycalib);

handl = plot(muds(1).Energy,(muds(1).mud-min(muds(1).mud))/max(muds(1).mud-min(muds(1).mud)));
legend(muds.Title,4)
set(gca,'LineWidth',1);
set(handl,'LineWidth',1);
xlabel('Energy (eV)');
ylabel('\mud (arb. units)');

%%%% Checking beam movement
assesstransmissionpilatus([1:400],'Sample1');

%%%% Plot difference
[data,param] = readunitedpilatus(1:700);
plotdifference(data,param,'Sample1',[16496 16986],0.000001);

plotdifferencebg(data,param,'Sample1',[16496 17030],'Background1'); hold off

