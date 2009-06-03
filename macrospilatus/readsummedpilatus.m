function [data,param] = readsummedpilatus(fsns)

% function [data,param] = readsummedpilatus(fsns)
%
%
% Created 18.12.2008

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('summed%d.dat',fsns(k)));
   if(isstruct(temp))
       temp2 = readlogfilepilatus(sprintf('intnorm%d.log',fsns(k)));
      if(isstruct(temp2))
        data(counter) = temp;
        param(counter) = temp2;
        counter = counter + 1;
      end;
   end;
end;