function transm1 = assesstransmissionpilatus(fsns,titleofsample)

% function transmission = assesstransmissionpilatus(fsns,titleofsample)
%
% Gives average of transmissions measured at different times for the sample
% with sample name 'titleofsample' within the wanted file sequence numbers
% (fsns) e.g. [1:400].
%
% Created: 19.3.2008 UV (ulla.vainio@gmail.com)
%
% Uses: READHEADER.M and READLOGFILEPILATUS.M

% Converting - and space to _ to ease analysis, because structure cell names cannot
% have the sign - or space, this is used also by READHEADER.M so they
% should work together well..
for(k = 1:length(titleofsample))
    if(strcmp(titleofsample(k),'-') | strcmp(titleofsample(k),' '))
        titleofsample(k) = '_';
    end;
end;

% First find the files related only to this sample
% Assuming that only this sample is named this way
% Finding different energies
energies = [];
counter = 1;
for(k = 1:length(fsns))
  temp = readheader('org_',fsns(k),'.header');
  if(isstruct(temp))
      if(strcmp(temp.Title,titleofsample))
         fsnsample(counter) = fsns(k);
         param(counter) = temp;
         temp2 = readlogfilepilatus(sprintf('intnorm%d.log',fsns(k))); % Read intnorm.log files
         if(isstruct(temp2))
           orix(counter) = temp2.BeamPosX; % Read in the determined beam centers
           oriy(counter) = temp2.BeamPosY;
           doris(counter) = temp.Current1;
           if(length(energies)==1) minindex = fsnsample(counter); end; %first fsn
           if(isempty(find(round(energies)==round(temp2.Energy))))
             energies = [energies temp2.Energy];
           end;
           counter = counter + 1;
         end;
      end;
  end;
end;
if(counter == 1)
    disp('Could not find any files with this sample name. Stopping.');
    return;
end;
maxindex = fsnsample(counter-1);
energies = sort(energies)

legend1 = {};
legend2 = {};
legend3 = {};
legend4 = {};
% Finding the transmissions at different measurement energies.
for(l = 1:length(energies))
  transm1 = [];
  timefsn = [];
  fsn1 = [];
  orix1 = [];
  oriy1 = [];
  doris1 = [];
  energy1 = energies(l);
  for(k = 1:(counter-1))
    if(round(param(k).Energy) == round(energy1))
       transm1 = [transm1 param(k).Transm];
       fsn1 = [fsn1 param(k).FSN];
       orix1 = [orix1 orix(k)];
       oriy1 = [oriy1 oriy(k)];
       doris1 = [doris1 doris(k)];
    end;
  end;
% transmission
  subplot(4,1,1);
  handl = plot(fsn1,transm1,'-o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  legend1 = [legend1 sprintf('Energy (not calibrated) = %.1f eV\n Mean T = %.4f, std %.4f',energy1,mean(transm1),std(transm1))];
  set(handl,'LineWidth',1); 
  ylabel('Transmission');
  xlabel('FSN');
  grid on
% Orix
  subplot(4,1,2);
  handl = plot(fsn1,orix1,'-o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  legend2 = [legend2, sprintf('Energy (not calibrated) = %.1f eV\n Mean x = %.4f, std %.4f',energy1,mean(orix1),std(orix1))];
  set(handl,'LineWidth',1); 
  ylabel('Position of beam center in X');
  xlabel('FSN');
  grid on
% Oriy
  subplot(4,1,3);
  handl = plot(fsn1,oriy1,'-o'); hold on
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  legend3 = [legend3, sprintf('Energy (not calibrated) = %.1f eV\nMean y = %.4f, std %.4f',energy1,mean(oriy1),std(oriy1))];
  set(handl,'LineWidth',1); 
  ylabel('Position of beam center in Y');
  xlabel('FSN');
  grid on
% DORIS current
  subplot(4,1,4);
  handl = plot(fsn1,doris1,'o'); hold on
  legend4 = [legend4, sprintf('Energy (not calibrated) = %.1f eV\n Mean I = %.4f',energy1,mean(doris1))];
  set(handl,'MarkerFaceColor',[1/l (length(energies)-l)/length(energies) 0.6]);
  set(handl,'LineWidth',1); 
  ylabel('Doris current (mA)');
  xlabel('FSN');
  grid on
end;

subplot(4,1,1); legend(legend1,'Location','EastOutside');
axis auto
hold off
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
title(sprintf('Sample: %s, period: %02d.%02d. %02d:%d - %02d.%02d. %02d:%02d',titleofsample,param(1).Day,param(1).Month,param(1).Hour,param(1).Minutes,param(end).Day,param(end).Month,param(end).Hour,param(end).Minutes)); 
subplot(4,1,2); legend(legend2,'Location','EastOutside');
axis auto
hold off
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
subplot(4,1,3); legend(legend3,'Location','EastOutside');
axis auto
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
hold off
subplot(4,1,4); legend(legend4,'Location','EastOutside');
axis auto
%ax = axis; axis([minindex-10 maxindex+10 ax(3) ax(4)]);
hold off
