function sumanduniteB1pilatus(data,param,samplename,uniq,dist,q1,q2,samplename2)

% function sumanduniteB1pilatus(data,param,samplename,uniq,dist,q1,q2,samplename2)
%
% dist = e.g. [3635 935]
% 
%
% Created 7.11.2007
% Added saving of only summed files, if one distance is missing.
% 16.5.2009 UV: Added samplename2 in case name in short and long distance
% measurements was different, put the same name if they were the same
% Edited 1.3.2012 UV: Changed to weighted sum.

datasum = weightedsumintegratedB1pilatus(data,param,samplename);

if(nargin>7)
   datasum2 = weightedsumintegratedB1pilatus(data,param,samplename2);
else
    datasum2 = [];
    samplename2 = samplename;
end;
datasum = [datasum datasum2];
dist = sort(dist);
disp('Uniting data, please check that curves match before pressing enter.');
energies = [];
temperatures = [];
sd = size(datasum);
for(p = 1:sd(2)) % Search for all different energies
   if(isempty(find(energies==datasum(p).EnergyCalibrated)))
     energies = [energies datasum(p).EnergyCalibrated];
   end;
   if(isempty(find(temperatures==round(datasum(p).Temperature))))
     temperatures = [temperatures round(datasum(p).Temperature)];
   end;
end;
bothfound = 0;
for(h = 1:length(energies))
  for(l = 1:length(temperatures))
  for(k = 1:sd(2)) % Allowing 2 eV mismatch in the short and long distance energies
    if((strcmp(datasum(k).Title,samplename) | strcmp(datasum(k).Title,samplename2)) & dist(1)/datasum(k).Dist > 0.93 & dist(1)/datasum(k).Dist < 1.08 & datasum(k).EnergyCalibrated./energies(h) > 0.9997 & datasum(k).EnergyCalibrated./energies(h) < 1.0003) % & temperatures(l)/datasum(k).Temperature > 0.9 & temperatures(l)/datasum(k).Temperature < 1.1)
        bothfound = bothfound + 1; % Short distance
        short = struct('q',datasum(k).q,'Intensity',datasum(k).Intensity,'Error',datasum(k).Error,'Temperature',datasum(k).Temperature);
    elseif((strcmp(datasum(k).Title,samplename) | strcmp(datasum(k).Title,samplename2)) & dist(2)/datasum(k).Dist > 0.93 & dist(2)/datasum(k).Dist < 1.08 & round(datasum(k).EnergyCalibrated) == round(energies(h))) % & temperatures(l)/datasum(k).Temperature > 0.9 & temperatures(l)/datasum(k).Temperature < 1.1)
        bothfound = bothfound + 1; % long distance
        long = struct('q',datasum(k).q,'Intensity',datasum(k).Intensity,'Error',datasum(k).Error,'Temperature',datasum(k).Temperature);
    end;
    if(bothfound == 2) % Short and long distance found so unite them
      if(long.Temperature/short.Temperature <1.1 | long.Temperature/short.Temperature <0.9) %#ok<BDSCA>
         disp(sprintf('Uniting at energy %f.',datasum(k).EnergyCalibrated))
         [f,multipl] = consaxs([short.q short.Intensity short.Error],[long.q long.Intensity long.Error],uniq, q1,q2,samplename);
         name = sprintf('united%d.dat',min(datasum(k).FSN));
         title(name);
         fid = fopen(name,'w');
         if(fid > -1)
            for(pp = 1:length(f))
              fprintf(fid,'%e %e %e\n',f(pp,1),f(pp,2),f(pp,3));
            end;
            fclose(fid);
            disp(sprintf('Saved summed and united data to file %s',name));
         else
            disp(sprintf('Unable to save data to file %s',name));
         end;
         % Write log-file
         name = sprintf('united%d.log',min(datasum(k).FSN));
         fid = fopen(name,'w');
         if(fid > -1)
            fprintf(fid,'FSNs:');
            temp = datasum(k).FSN;
            for(pp = 1:length(temp))
                fprintf(fid,' %d',temp(pp));
            end;
            fprintf(fid,'\n');
            fprintf(fid,'Sample name: %s\n',datasum(k).Title);
            fprintf(fid,'Calibrated energy: %e\n',datasum(k).EnergyCalibrated);
            fprintf(fid,'Multiplied short distance data by: %f\n',multipl);
            fprintf(fid,'Temperature: %.f (long) %.f (short)\n',long.Temperature,short.Temperature);
            fclose(fid);
            disp(sprintf('Saved %s',name));
         else
            disp(sprintf('Unable to save data to file %s\n',name));
         end;
        break; % Break only the inner loop
      else
             disp(sprintf('Both distances found, but temperatures are different: %.f (long) %.f (short)\n',long.Temperature,short.Temperature));
      end;
    elseif(k == sd(2) && bothfound == 1)
        disp(sprintf('NOTE: At energy %f (calibrated) a measurement at one distance is missing.',energies(h)));
%         name = sprintf('united%d.dat',min(datasum(h).FSN));
%         f = [datasum(h).q datasum(h).Intensity datasum(h).Error];
%         fid = fopen(name,'w');
%         if(fid > -1)
%            for(pp = 1:length(f))
%              fprintf(fid,'%e %e %e\n',f(pp,1),f(pp,2),f(pp,3));
%            end;
%            fclose(fid);
%            disp(sprintf('Saved summed data to file %s',name));
%         else
%            disp(sprintf('Unable to save data to file %s',name));
%         end;
%         % Write log-file
%         name = sprintf('united%d.log',min(datasum(h).FSN));
%         fid = fopen(name,'w');
%         if(fid > -1)
%            fprintf(fid,'FSNs:');
%            temp = datasum(k).FSN;
%            for(pp = 1:length(temp))
%                fprintf(fid,' %d',temp(pp));
%            end;
%            fprintf(fid,'\n');
%            fprintf(fid,'Sample name: %s\n',datasum(k).Title);
%            fprintf(fid,'Calibrated energy: %e\n',datasum(k).EnergyCalibrated);
%            fclose(fid);
%            disp(sprintf('Saved %s',name));
%         else
%            disp(sprintf('Unable to save data to file %s\n',name));
%         end;
    end;
  end;
    bothfound = 0; % Reset after each energy
end;
  bothfound = 0; % Reset after each energy
end;