function datasum = sumandsaveB1pilatus(data,param,samplename)

% function sumandsaveB1pilatus(data,param,samplename)
% 
% Sums and then saves into summed*.dat the data.
%
% Created 18.12.2008 UV
% Edited 1.3.2012 UV: Changed to weighted sum.

datasum = weightedsumintegratedB1pilatus(data,param,samplename);
for(k = 1:length(datasum))
  name = sprintf('summed%d.dat',min(datasum(k).FSN));
  fid = fopen(name,'w');
  if(fid > -1)
    for(pp = 1:length(datasum(k).q))
      fprintf(fid,'%e %e %e\n',datasum(k).q(pp),datasum(k).Intensity(pp),datasum(k).Error(pp));
    end;
    fclose(fid);
    disp(sprintf('Saved summed data to file %s',name));
  else
    disp(sprintf('Unable to save data to file %s',name));
  end;
  % Write log-file
  name = sprintf('summed%d.log',min(datasum(k).FSN));
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