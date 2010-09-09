function sumandsaveB1waxsflatfield(data,param,samplename,qwaxs1,qwaxs2,flatfield)

% function sumandsaveB1waxsflatfield(data,param,samplename)
% 
% Sums and then saves into summedwaxs*.dat the data.
%
% Created 18.12.2008 UV

datasum = sumintegratedB1mythen(data,param,samplename);
for(k = 1:length(datasum))
  name = sprintf('summedwaxs%d.dat',min(datasum(k).FSN));
  datasum(k).Intensity = datasum(k).Intensity; %./flatfield;
  counterm = 1; f2 = 0;
  for(mm = 1:length(datasum(k).Intensity)) % removing bad points
     if(datasum(k).Intensity(mm)~= 0)
       f2(counterm,1) = datasum(k).q(mm);
       f2(counterm,2) = datasum(k).Intensity(mm);
       f2(counterm,3) = datasum(k).Error(mm);
       counterm = counterm + 1;
     end;
  end;
  [qbin,intbin,errbin] = tobins(f2(:,1),f2(:,2),f2(:,3),400,qwaxs1,qwaxs2);
  fid = fopen(name,'w');
  if(fid > -1)
    for(pp = 1:length(qbin))
      fprintf(fid,'%e %e %e\n',qbin(pp),intbin(pp),errbin(pp));
    end;
    fclose(fid);
    disp(sprintf('Saved summed data to file %s',name));
  else
    disp(sprintf('Unable to save data to file %s',name));
  end;
  % Write log-file
  name = sprintf('summedwaxs%d.log',min(datasum(k).FSN));
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
     fprintf(fid,'Temperature: %.f\n',datasum(k).Temperature);
     fclose(fid);
     disp(sprintf('Saved %s',name));
   else
     disp(sprintf('Unable to save data to file %s\n',name));
   end;
end;