function [data,param] = readintnormpilatus(fsns)

% function [data,param] = readintnormpilatus(fsns)
%
%
% Created 26.10.2007

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('intnorm%d.dat',fsns(k)));
   if(isstruct(temp))
       temp2 = readlogfilepilatus(sprintf('intnorm%d.log',fsns(k)));
      if(isstruct(temp2))
        data(counter) = temp;
        param(counter) = temp2;
        counter = counter + 1;
      end;
   end;
end;