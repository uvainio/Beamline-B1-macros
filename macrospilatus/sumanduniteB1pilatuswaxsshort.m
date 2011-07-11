function sumanduniteB1pilatuswaxsshort(data,param,samplename,dist,uniqwaxs,q1waxs,q2waxs,qwaxs1,qwaxs2,flatfield,bins,waxsshift)

% function sumanduniteB1pilatuswaxsshort(data,param,samplename,dist,uniqwaxs,q1waxs,q2waxs,flatfield,bins,waxsshift)
%
% dist = e.g. [3635 935]
% 
%
% Created 7.11.2007
% Added saving of only summed files, if one distance is missing.
% 16.5.2009 UV: Added samplename2 in case name in short and long distance
% measurements was different, put the same name if they were the same
% Edited: 27.7.2009 UV, added WAXS
% Edited: 13.4.2010 UV: added flatfield option and possibility to shift the
% WAXS data by a few pixels using waxsshift

datasum = sumintegratedB1pilatus(data,param,samplename);
% Load in WAXS data
[datawaxs,paramwaxs] = readintnormmythen(param(1).FSN:param(end).FSN);
if(isstruct(datawaxs))
   % Sum waxs data
   datasumwaxs = sumintegratedB1mythen(datawaxs,paramwaxs,samplename);
end;

dist = sort(dist);
disp('Uniting data, please check that curves match before pressing enter.');
energies = [];
temperatures = [];
sd = size(datasum);
for(p = 1:sd(2)) % Search for all different energies
   if(isempty(find(energies==datasum(p).EnergyCalibrated, 1)))
     energies = [energies datasum(p).EnergyCalibrated];
   end;
   if(isempty(find(temperatures==round(datasum(p).Temperature), 1)))
     temperatures = [temperatures round(datasum(p).Temperature)];
   end;
end;
shortfound = 0;
for(h = 1:length(energies))
  for(l = 1:length(temperatures))
  for(k = 1:sd(2)) % Allowing 2 eV mismatch in the short and long distance energies
    if(strcmp(datasum(k).Title,samplename) && dist(1)/datasum(k).Dist > 0.93 && dist(1)/datasum(k).Dist < 1.08 && datasum(k).EnergyCalibrated/energies(h) > 0.9997 && datasum(k).EnergyCalibrated/energies(h) < 1.0003 && temperatures(l)/datasum(k).Temperature > 0.95 && temperatures(l)/datasum(k).Temperature < 1.05)
        shortfound = 1;
        short = struct('q',datasum(k).q,'Intensity',datasum(k).Intensity,'Error',datasum(k).Error,'Temperature',datasum(k).Temperature);
    end;
    % Find WAXS
    if(k <= length(datasumwaxs) && strcmp(datasumwaxs(k).Title,samplename) && round(datasumwaxs(k).EnergyCalibrated) == round(energies(h)) && temperatures(l)/datasumwaxs(k).Temperature > 0.95 && temperatures(l)/datasumwaxs(k).Temperature < 1.05)
         if(nargin>12)
             waxstmp = struct('q',datasumwaxs(k).q*waxsshift,'Intensity',datasumwaxs(k).Intensity./flatfield,'Error',datasumwaxs(k).Error,'Temperature',datasumwaxs(k).Temperature);
             title('WAXS after flatfield correction');
             plot(waxstmp.q,waxstmp.Intensity);
             pause
         else        
           waxstmp = struct('q',datasumwaxs(k).q,'Intensity',datasumwaxs(k).Intensity,'Error',datasumwaxs(k).Error,'Temperature',datasumwaxs(k).Temperature);
         end;
        counterm = 1;
         for(mm = 1:length(waxstmp.Intensity)) % removing bad points
             if(waxstmp.Intensity(mm)~= 0)
                 waxstmp2.q(counterm) = waxstmp.q(mm);
                 waxstmp2.Intensity(counterm) = waxstmp.Intensity(mm);
                 waxstmp2.Error(counterm) = waxstmp.Error(mm);
                 counterm = counterm + 1;
             end;
         end;
         % Unite a few pixels
        [qbin,intbin,errbin] = tobins(waxstmp2.q',waxstmp2.Intensity',waxstmp2.Error',bins,qwaxs1,qwaxs2);
        waxs = struct('q',qbin,'Intensity',intbin,'Error',errbin);
    end;
    if(shortfound == 1) % Short and long distance found so unite them
         [f,multipl2] = consaxs([waxs.q waxs.Intensity waxs.Error],[short.q short.Intensity short.Error],uniqwaxs,q1waxs,q2waxs,samplename);
         counterm = 1; f2 = 0;
         for(mm = 1:length(f)) % removing bad points
             if(f(mm,2)~= 0)
                 f2(counterm,1) = f(mm,1);
                 f2(counterm,2) = f(mm,2);
                 f2(counterm,3) = f(mm,3);
                 counterm = counterm + 1;
             end;
         end;
         name = sprintf('united%d.dat',min(datasum(k).FSN));
         title(name);
         fid = fopen(name,'w');
         if(fid > -1)
            for(pp = 1:length(f2))
              fprintf(fid,'%e %e %e\n',f2(pp,1),f2(pp,2),f2(pp,3));
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
            for pp = 1:length(temp)
                fprintf(fid,' %d',temp(pp));
            end;
            fprintf(fid,'\n');
            fprintf(fid,'Sample name: %s\n',datasum(k).Title);
            fprintf(fid,'Calibrated energy: %e\n',datasum(k).EnergyCalibrated);
            fprintf(fid,'Temperature: %.f\n',short.Temperature);
            fprintf(fid,'Multiplied WAXS data by: %f\n',multipl2);
            fclose(fid);
            disp(sprintf('Saved %s',name));
         else
            disp(sprintf('Unable to save data to file %s\n',name));
         end;
        break; % Break only the inner loop
    end;
  end;
    shortfound = 0; % Reset after each energy
end;
  shortfound = 0; % Reset after each energy
end;