function [data,param] = readsummedmythen(fsns)

% function [data,param] = readsummedmythen(fsns)
%
%
% Created 3.5.2010

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('summedwaxs%d.dat',fsns(k)));
   if(isstruct(temp))
       temp2 = readlogfilepilatus(sprintf('intnorm%d.log',fsns(k)));
      if(isstruct(temp2))
        data(counter) = temp;
        param(counter) = temp2;
        counter = counter + 1;
      end;
   end;
end;