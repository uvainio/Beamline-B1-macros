function [data,param] = readintnormmythen(fsns)

% function [data,param] = readintnormmythen(fsns)
%
%
% Created 22.5.2009 UV

counter = 1;
for(k = 1:length(fsns))
   temp = readintfile(sprintf('waxs_%05d.cor',fsns(k)));
   if(nargout>1)
     if(isstruct(temp))
       temp2 = readlogfilepilatus(sprintf('intnorm%d.log',fsns(k)));
         if(isstruct(temp2))
           data(counter) = temp;
           param(counter) = temp2;
           counter = counter + 1;
         end;
     end;
   else
       data(counter) = temp;
       counter = counter + 1;    
   end;
end;