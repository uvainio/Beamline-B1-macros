function muds = readxanes(filename,files,fileend,energymeas,energycalib,mode)

% function muds = readxanes(filename,files,fileend,energymeas,energycalib,mode)
%
% A macro to load XANES scans and to put them on correct energy scale.
% This macro saves the corrected absorption curves into ascii files with
% extension '.cor'.
%
% IN:
%
% filename = beginning of file name, e.g. 'abt_'
% files = the scan numbers to be loaded, e.g. [4:10]
% fileend = end of the file name, e.g. '.fio'
% energymeas = energies measured at absorption edges of some elements
% energycalib = the real energies at those absorption edges
% mode      = 'normal' or 'exafs'
%
% OUT:
%
% muds is a structure containing the calibrated energy scales,
%      mud values (linear absorption coefficient times thickness of sample)
%      and sample name (Title)
% The macro also saves the same data in an ascii file 'abt_#####.cor'
%
% Examples of usage:
%
%       Load data into the structure muds:
% muds = readxanes('abt_',4:7,'.dat',[8333 7100],[8331 7111]);
%
%       Plot the data in muds:
% for(k = 1:length(muds))
%   plot(muds(k).Energy,muds(k).mud,'Color',[1/k (length(muds)-k)/length(muds) k/length(muds)]); hold on
% end; hold off
%
%       Check which sample measurements were loaded:
% muds.Title
%
% Created 21.12.2007 UV, ulla.vainio@desy.de
% Edited: 10.12.2008 UV, changed energy calibration to an external macro
% (and simultanenously changed from spline fit to a linear fit)

counter = 1;
muds = struct('Energy',[],'mud',[],'Title','','scan',[]);
for(k = 1:length(files))
  [energy1,mud1,sample1,fullfilenamewithoutending] = readenergyfio(filename,files(k),fileend,mode);  
  if(energy1 ~=0) % If something was found

    %energyreal = interp1(energymeas,energycalib,energy1,'linear','extrap');
    % Changed energy calibration 10.12.2008
     energyreal = energycalibration(energymeas,energycalib,energy1);

    % Save into a structure
    muds(counter).Energy = energyreal;
    muds(counter).mud = mud1;
    muds(counter).Title = sample1;
    muds(counter).scan = files(k);
    counter = counter +1;

    % Save into a file
    name = sprintf('%s.cor',fullfilenamewithoutending);
    fid = fopen(name,'w');
    if(fid > -1)
      disp(sprintf('Saving data to file %s',name));
      for(k = 1:length(mud1))
        fprintf(fid,'%e %e\n',energyreal(k),mud1(k));
      end;
      fclose(fid);
      f = 1;
    else
      f = 0;
    end;
  end;
end;

