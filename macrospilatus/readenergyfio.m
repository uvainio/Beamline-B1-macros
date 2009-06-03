function [energy,mud,samples,fullfilenamewithoutending] = readenergyfio(filename,files,fileend)

% function [energy,mud,samples] = readenergyfio(filename,files,fileend)
%
% IN:
% filename  =  beginning of the file, e.g. 'abt_'
% files     =  the files, e.g. [250 714:804]
% fileend   =  the ending of the file, e.g. 'fio'
%
% OUT:
% energy    =  energy scale (vector)
% mud       =  linear transmission coefficient times
%              the sample thickness mu * d
% samples   =  sample names
%
% Reads the vector format FIO of B1 beamline (e.g. abt_00018.fio)
% NOTE: Multiple files are read only if the energy scale is the same.
%
% Created: Ulla Vainio, HASYLAB 20.7.2007
% This macro is used by READXANES.M
% Edited 21.12.2007 UV: returns only zeros, if file is not found.

nr = size(files);

counter = 1;
for(l = 1:nr(1))
for(k = 1:nr(2))
        name = sprintf('%s0000%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
        name1 = name;
        fullfilenamewithoutending = sprintf('%s0000%g%s',filename,files(l,k));
    if(fid == -1) % Tries out also all filenames with zeros in between
        name = sprintf('%s000%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
        fullfilenamewithoutending = sprintf('%s000%g%s',filename,files(l,k));
     end;
     if(fid == -1)
        name = sprintf('%s00%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
        fullfilenamewithoutending = sprintf('%s00%g%s',filename,files(l,k));
     end;
     if(fid == -1)
        name = sprintf('%s0%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
        fullfilenamewithoutending = sprintf('%s0%g%s',filename,files(l,k));
     end;
     if(fid == -1)
        name = sprintf('%s%g%s',filename,files(l,k),fileend);
        fid = fopen(name,'r');
        fullfilenamewithoutending = sprintf('%s%g%s',filename,files(l,k));
     end;
     if(fid ~= -1)
        disp(name) % shows name of the FSN that opened
     end;

     if(fid == -1) % If file is not found
         disp(sprintf('Cannot find file with FSN %d. End of reading.\nTried to read files named %s\nand %s and all variants in between.\n', ...
         files(l,k),name,name1));
         energy = 0;
         mud = 0;
         samples = 0;
         return;
     end;

   for(hh = 1:5) % Reading the useless lines
       temp = fgets(fid);
   end;
   
%    sample = fscanf(fid,'%s',1);
    sample = fgets(fid); % Sample name.

    for(hh = 1:35) % Reading the header lines
       temp = fgets(fid);
    end;
   
    mtemp = fscanf(fid,'%e'); % Scan in all data (energy,..., mud)
    counter2 = 1;
    for(j = 1:11:(length(mtemp)))
      if(counter == 1) % Reading energy scale only from the first file.
         energy(counter2,1) = mtemp(j);
      end;
      if(counter > 1) % Checking the energy scale is the same for all.
         if(length(energy)~=length(1:11:(length(mtemp))) | num2str(energy(counter2),'%.1f')~=num2str(mtemp(j),'%.1f'))
            energy(counter2)
            mtemp(j)
            sprintf('Energy scale of FSN %d is different. Stopping.',files(counter))
            return
         end;
      end;
      mud(counter2,counter) = mtemp(j+10); % Reading in mud
      counter2 = counter2 + 1;
    end;
    if(k == 1 && l == 1) % Save sample name to variable samples
        samples = sample;
    else
        samples = strvcat(samples,sample); % Name is saved only if data is read.
    end;
    counter = counter + 1;
    fclose(fid);
end;
end;