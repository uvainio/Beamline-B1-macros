function datasum = sumintegratedB1mythen(data,param,samplename)

% function datasum = sumintegratedB1mythen(data,param,samplename)
%
% Created 27.7.2009 UV

if(iscell(samplename)~=1)
    samplename = {samplename,samplename};
end;

energies = [];
temperatures = [];
sd = size(data);
for(p = 1:sd(2)) % Search for all different energies
   if(isempty(find(energies==param(p).EnergyCalibrated)))
     energies = [energies param(p).EnergyCalibrated];
   end;
   if(isempty(find(temperatures==round(param(p).Temperature))) & (strcmp(param(p).Title,char(samplename(1))) || strcmp(param(p).Title,char(samplename(2)))))
       if(isempty(temperatures))
           temperatures = [temperatures round(param(p).Temperature)];
       elseif(temperatures(1)/round(param(p).Temperature)<0.9 | temperatures(1)/round(param(p).Temperature)>1.1)
               temperatures = [temperatures round(param(p).Temperature)];
       end;
   end;
end;

countertotal = 1;
allfsnssummed = [];
for(h = 1:length(energies))
   for(l = 1:length(temperatures))
          counter = 1;
          for(k = 1:sd(2)) % first sum
             if((strcmp(param(k).Title,char(samplename(1))) || strcmp(param(k).Title,char(samplename(2)))) && round(param(k).EnergyCalibrated) == round(energies(h)) && temperatures(l)/param(k).Temperature > 0.9 && temperatures(l)/param(k).Temperature < 1.1)
               if(counter == 1) % Create the first structure.
                sumq = data(k).q;
                sumints = data(k).Intensity/max(data(k).Intensity);
                sumerrs = data(k).Error/max(data(k).Intensity);
                sumfsns = param(k).FSN;
                counter = counter + 1;
                calibratedenergy = param(k).EnergyCalibrated;
                loglog(data(k).q,data(k).Intensity/max(data(k).Intensity),'r'); hold on
               elseif(sum(data(k).q - sumq) == 0) % Making sure q-range is the same
                sumints = sumints + data(k).Intensity/max(data(k).Intensity);
                sumerrs = sqrt(sumerrs.^2 + (data(k).Error/max(data(k).Intensity)).^2);
                sumfsns = [sumfsns param(k).FSN];
                counter = counter + 1;
                plot(data(k).q,data(k).Intensity/max(data(k).Intensity),'r'); hold on
               else
                disp('Are you sure the data is binned to the same q-spacing?')          
               end;
          end;
        end;
        if(counter > 1)
          for(mm = 1:(counter-1))
            ints = sumints/(counter-1);
             errs = sumerrs/(counter-1);
          end;
         summed = struct('q',sumq,'Intensity',ints,'Error',errs,'FSN',sumfsns,'Title',char(samplename(1)),'EnergyCalibrated',calibratedenergy,'Temperature',temperatures(l));
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

% Check if some were not summed and add them in the structure
for(k = 1:sd(2))
    if(isempty(find(allfsnssummed==param(k).FSN)) & (strcmp(param(k).Title,char(samplename(1))) || strcmp(param(k).Title,char(samplename(2)))))
        temp = struct('q',data(k).q,'Intensity',data(k).Intensity,'Error',data(k).Error,'FSN',param(k).FSN,'Title',param(k).Title,'EnergyCalibrated',param(k).EnergyCalibrated,'Temperature',param(k).Temperature);
        datasum(countertotal) = temp;
        countertotal = countertotal + 1;
    end;
end;
    
