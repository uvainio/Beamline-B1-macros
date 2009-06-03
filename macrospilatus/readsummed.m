function [data,param] = readsummed(fsns)

% function [data,param] = readsummed(fsns)
%
%
% Created 18.12.2008

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('summed%d.dat',fsns(k)));
   if(isstruct(temp))
       temp2 = readlogfile(sprintf('intnorm%d.log',fsns(k)));
      if(isstruct(temp2))
        data(counter) = temp;
        param(counter) = temp2;
        counter = counter + 1;
      end;
   end;
end;