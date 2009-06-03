function cor = absorptionangledependent(tth,transm)

% cor = absorptionangledependent(tth,transm)
% 
% Usage: Icorrected = Imeas.*cor
% tth in angles, not radians!
%
% Created: 11.10.2007 UV

mud = -log(transm);
tth = tth*pi/180; % Transforming from degrees to radians

for(k = 1:length(tth))
  if(tth(k) ~= 0) % At tth = 0 this doesn't work
    cor(k) = transm./((1./(1-1./cos(tth(k)))/mud).*(exp(-mud./cos(tth(k)))-exp(-mud)));
  else % So in the special case at 0
    cor(k) = 1;
  end;
end;

cor = cor(:);