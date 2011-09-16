%% Initialization of scripts

% %On-site configuration
projectdir='D:\\Projekte\\2011\\0624Bota';
macroroot='D:\\git\\Beamline-B1-macros';
macros_other={'D:\\git\\pilatusnotopenaccess',...
    'D:\\matlabmacros\\2008\\notopenaccess\\analysispilatus',...
    'D:\\othermacros\\cSAXS_matlab_base_package\\cSAXS_matlab_base_package'};

% %Off-site configuration 
%projectdir='/home/andris/kutatas/desy/2011/0624Bota';
%macroroot=[projectdir,filesep,'macros',filesep,'Beamline-B1-macros'];
%macros_other={[projectdir,filesep,'macros',filesep,'pilatusnotopenaccess'],...
%    [projectdir,filesep,'notopenaccess',filesep,'analysispilatus'],...
%    [projectdir,filesep,'cSAXS_matlab_base_package']};

% No site-dependent information below these lines!!!
addpath([projectdir,filesep,'data1']);
addpath([projectdir,filesep,'eval1']);
addpath([macroroot,filesep,'macrospilatus']);
addpath([macroroot,filesep,'macrospilatus',filesep,'macrosmythen']);
addpath([macroroot,filesep,'macrospilatus',filesep,'calibrationfiles']);
addpath([macroroot,filesep,'macrospilatus',filesep,'dataqualitytools']);
for i = 1:length(macros_other)
    addpath(macros_other{i})
end
addpath([projectdir,filesep,'processing']);

%cd D:\git\Beamline-B1-macros\macrospilatus
%mex -v -DRADINT radint3.c -output radint3
cd(projectdir);

% 300k
% sens = ones(619,487);
% 1M
sens = ones(1043,981);
errorsens = zeros(size(sens));

% Calibration of the WAXS detector
mythendistance = 134; 
mythenpixelshift = 318.1858;

mask = maskgaps('1M');
fluorcorr = zeros(size(mask));

%A = GetPilatus('0624Bota','org_',3,1000);
%mask4 = makemask2(mask4,log(A+1));
%save processing/mask4.mat mask4

%A = read2dB1datapilatus('Z:\\0624Bota\\','org_',[9:22],'.cbf');
%DC = fluorcorr;
%mask2 = makemaskPilatus(A,DC,'1M');

load processing/mask4

% Energy scale calibration
energycalib = [13880.70 17995.88 ]; % Pt_L3, Pt_L1, Pt_L2, Zr_K
energymeas = [13862 17981.5]; % The measured positions of 1st inflection points

% Zoomed area axes for determination of beam center through beamstop
pri = [453   473    46    63];

% Correction to the sample-to-detector distance in mm
distminus=0;
detshift = 46;

sens = ones(619,487);
errorsens = zeros(size(sens));

%%%% loading test images
A = GetPilatus(mask,'test_',1,1000);
% Show all data files
getsamplenamespilatus('org_',2:7,'.header');

%%%%%%%%%%%%%%%%%%%
%%%%----------------
%%%%%%%%%%%%%%%%%%%%

thicknesses = struct('sample1',0.01,'sample2',0.01,'Reference_on_GC_holder_after_sample_sequence',0.1); % Thickness in cm
distminus = 0;
mythendistance = 132.2381; % old value 132.0722;
mythenpixelshift = 291.2323; % old value 313.5302;

%%%% LONG distance
B1normintallpilatus([11:17],thicknesses,sens,errorsens,mask,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,detshift,fluorcorr);

%%% SHORT distance
B1normintallpilatus([206:207],thicknesses,sens,errorsens,maskshort,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,detshift,fluorcorr);

[datap,paramp] = readbinnedpilatus(91:400);
legend1 = plotints(datap,paramp,'sample1',[17030],'-',1); hold on
hold off
legend([legend1]);
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
% print -depsc D:\Projekte\2010\project\processing\SAXS

[datap,paramp] = readintnormpilatus(91:400);
plotintstime(datap,paramp,'sample1',[17030],'--',1); hold on
hold off


%%% Reintegrate (rebin) the data
% 4 tubes
reintegrateB1pilatus(2:7,masklong,3625-detshift-distminus,[0.0075:0.002:0.208]);   % 1st data set
% 0 tubes
reintegrateB1pilatus(8:13,mask0,925-detshift-distminus,[0.025:0.008:0.815]);       % 1st data set


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
muds = readxanes('abt_',[??:??],'.fio',energymeas,energycalib,'normal');

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


%%%% Calibrate MYTHEN detector
energy1 = 12000; % Insert here the measurement energy according to the machine in eV
temp = load('waxs_00006.dat'); % Insert here the name of the file to load (data file where the Lanthanum hexaboride measurement is)
%%% Run these without changing anything on Matlab command window

stripwidth = 0.05 % mm, that is 50 micrometers with of strips in the Mythen detector

dataLaB6 = [temp(:,1) temp(:,2)];
energyreal = energycalibration(energymeas,energycalib,energy1);
data = readLaB6calib(dataLaB6,energyreal,1:7); % You can change the last number if you want to include more or less peaks in the fit

mythendistance = stripwidth/data.lamq(1) % 132.2381 = the distance from sample to detector in mm (needed by B1nomintall)
mythenpixelshift = data.lamq(2) % 291.2323 = shift of Mythen from 0 in pixels (needed by B1nomintall)