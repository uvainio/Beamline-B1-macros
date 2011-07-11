function datasum = sumintegratedB1pilatus_sigma(data,param,samplename)

% function datasum = sumintegratedB1pilatus(data,param,samplename)
%
% Created 7.11.2007
% Edited: 5.7.2011 UV Changed error calculation and summing to take into account the mean value
% and the error

dist = [935 1384 1835 2735 3635];
energies = [];
temperatures = [];
sd = size(data);
for(p = 1:sd(2)) % Search for all different energies
   if(isempty(find(energies==param(p).EnergyCalibrated)))
     energies = [energies param(p).EnergyCalibrated];
   end;
   if(isempty(find(temperatures==round(param(p).Temperature))) & strcmp(param(p).Title,samplename))
       if(isempty(temperatures))
           temperatures = [temperatures round(param(p).Temperature)];
       elseif(temperatures(1)/round(param(p).Temperature)<0.8 | temperatures(1)/round(param(p).Temperature)>1.2)
               temperatures = [temperatures round(param(p).Temperature)]
       end;
   end;
end;

countertotal = 1;
allfsnssummed = [];
for(h = 1:length(energies))
   for(l = 1:length(temperatures))
      for(m = 1:length(dist))
          counter = 1;
          for(k = 1:sd(2)) % first sum
             if(strcmp(param(k).Title,samplename) && dist(m)/param(k).Dist > 0.92 && dist(m)/param(k).Dist < 1.08 && round(param(k).EnergyCalibrated) == round(energies(h)) && (temperatures(l)/round(param(k).Temperature)>0.8 && temperatures(l)/round(param(k).Temperature)<1.2))
               param(k).FSN
               if(counter == 1) % Create the first structure.
                sumq = data(k).q;
                sumints = data(k).Intensity;
                sumerrs = data(k).Error;
                sumerrsnorm = data(k).Error;
                sumfsns = param(k).FSN;
                counter = counter + 1;
                calibratedenergy = param(k).EnergyCalibrated;
                loglog(data(k).q,data(k).Intensity,'r'); hold on
               elseif(sum(data(k).q - sumq) == 0) % Making sure q-range is the same
                sumints = sumints + data(k).Intensity./data(k).Error;
                sumerrsnorm = sumerrsnorm + 1./data(k).Error;
                sumerrs = sqrt(sumerrs.^2 + (1./data(k).Error).^2); % How to calculate weighted error?
                sumfsns = [sumfsns param(k).FSN];
                counter = counter + 1;
                loglog(data(k).q,data(k).Intensity,'r'); hold on
               else
                disp('Are you sure the data is binned to the same q-spacing?')          
               end;
          end;
      end;
      if(counter > 1)
          for(mm = 1:(counter-1))
            ints = sumints./sumerrsnorm;
            errs = sumerrs/;
          end;
         summed = struct('q',sumq,'Intensity',ints,'Error',errs,'FSN',sumfsns,'Title',samplename,'EnergyCalibrated',calibratedenergy,'Dist',dist(m),'Temperature',temperatures(l));
         disp(sprintf('Summed %d measurements:',counter-1));
          getsamplenamespilatus('org_',summed.FSN,'.header',1);

       % Plotting the summed intensity with the originals in red and this in blue.
         errorbar(summed.q,summed.Intensity,summed.Error,'.'); hold on
         hold off
          pause
          datasum(countertotal) = summed;
          countertotal = countertotal + 1;
          allfsnssummed = [allfsnssummed sumfsns];
         end;
      end;
   end;
end;

% Check if some were not summed and add them in the structure
for(k = 1:sd(2))
    if(isempty(find(allfsnssummed==param(k).FSN)) & strcmp(param(k).Title,samplename))
        temp = struct('q',data(k).q,'Intensity',data(k).Intensity,'Error',data(k).Error,'FSN',param(k).FSN,'Title',param(k).Title,'EnergyCalibrated',param(k).EnergyCalibrated,'Dist',param(k).Dist,'Temperature',param(k).Temperature);
        datasum(countertotal) = temp;
        countertotal = countertotal + 1;
    end;
end;
    
