function saveB1waxsflatfield(fsns,qwaxs1,qwaxs2,bins,flatfield)

% function saveB1waxsflatfield(fsns,qwaxs1,qwaxs2,bins,flatfield)
% 
% Saves into waxsflatfield*.dat the data.
%
% Created 18.12.2008 UV

[data,param] = readintnormmythen(fsns);

for(k = 1:length(data))
  name = sprintf('waxsflatfield%d.dat',min(param(k).FSN));
  data(k).Intensity = data(k).Intensity./flatfield;
  counterm = 1; f2 = 0;
  for(mm = 1:length(data(k).Intensity)) % removing bad points
     if(data(k).Intensity(mm)~= 0)
       f2(counterm,1) = data(k).q(mm);
       f2(counterm,2) = data(k).Intensity(mm);
       f2(counterm,3) = data(k).Error(mm);
       counterm = counterm + 1;
     end;
  end;
  [qbin,intbin,errbin] = tobins(f2(:,1),f2(:,2),f2(:,3),bins,qwaxs1,qwaxs2);
  fid = fopen(name,'w');
  if(fid > -1)
    for(pp = 2:(length(qbin)-1))
      fprintf(fid,'%e %e %e\n',qbin(pp),intbin(pp),errbin(pp));
    end;
    fclose(fid);
    disp(sprintf('Saved summed data to file %s',name));
  else
    disp(sprintf('Unable to save data to file %s',name));
  end;
  % Write log-file
  name = sprintf('waxsflatfield%d.log',min(param(k).FSN));
  fid = fopen(name,'w');
  if(fid > -1)
     fprintf(fid,'FSNs:');
     temp = param(k).FSN;
     for(pp = 1:length(temp))
        fprintf(fid,' %d',temp(pp));
     end;
     fprintf(fid,'\n');
     fprintf(fid,'Sample name: %s\n',param(k).Title);
     fprintf(fid,'Calibrated energy: %e\n',param(k).EnergyCalibrated);
     fprintf(fid,'Temperature: %.f\n',param(k).Temperature);
     fclose(fid);
     disp(sprintf('Saved %s',name));
   else
     disp(sprintf('Unable to save data to file %s\n',name));
   end;
end;