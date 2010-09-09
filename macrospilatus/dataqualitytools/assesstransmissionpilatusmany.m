function assesstransmissionpilatusmany(fsns,titleofsample)

% function assesstransmissionpilatusmany(fsns,titleofsample)
%
% Gives average of transmissions measured at different times for the sample
% with sample name 'titleofsample' within the wanted file sequence numbers
% (fsns) e.g. [1:400].
%
% Created: 19.3.2008 UV (ulla.vainio@gmail.com)
%
% Uses: READHEADER.M and READLOGFILEPILATUS.M
% Edited: 24.8.2010 Ulla Vainio

% Converting - and space to _ to ease analysis, because structure cell names cannot
% have the sign - or space, this is used also by READHEADER.M so they
% should work together well..

% First find the files related only to this sample
% Assuming that only this sample is named this way
% Finding different energies
counter = 1;
   for(k = 1:length(fsns))
    temp = readheader('org_',fsns(k),'.header');
    if(isstruct(temp))
            fsnsample(counter) = fsns(k);
            param(counter) = temp;
            temp2 = readlogfilepilatus(sprintf('intnorm%d.log',fsns(k))); % Read intnorm.log files
            counter = counter + 1;
     end;
   end;

legend1 = {};
% Finding the transmissions at different samples.
for(m = 1:length(titleofsample))
   transm1 = [];
   fsn1 = [];
   for(k = 1:(counter-1))
       if(strcmp(titleofsample(m),param(k).Title))
        transm1 = [transm1 param(k).Transm];
        fsn1 = [fsn1 param(k).FSN];
       end;
   end;
   %  transmission
   handl = plot(fsn1,transm1,'-o'); hold on
   set(handl,'MarkerFaceColor',[1/m (length(titleofsample)-m)/length(titleofsample) 0.6]);
   legend1 = [legend1 sprintf('Sample = %s \n Mean T = %.4f, std %.4f',char(titleofsample(m)),mean(transm1),std(transm1))];
   set(handl,'LineWidth',1); 
   ylabel('Transmission');
   xlabel('FSN');
   grid on
end;

legend(legend1,'Location','EastOutside');
axis auto
hold off
