function cor = absorptionangledependenttth(tth,transm)

% cor = absorptionangledependenttth(tth,transm)
% 
% Usage: Icorrected = Imeas.*cor
% tth in radians!
%
% Created: 11.10.2007 UV
% Edited: 25.4.2009 AW tth can now be a matrix of arbitrary size. cor will
% be of the same size.
% Renamed to avoid conflict with mythen macro. UV 17.6.2009

mud = -log(transm);

cor = ones(size(tth)); % Changed from zeros to ones UV 17.6.2009
cor(tth~=0) =  transm./((1./(1-1./cos(tth(tth~=0)))/mud).*(exp(-mud./cos(tth(tth~=0)))-exp(-mud)));

%for(k = 1:length(tth))
%  if(tth(k) ~= 0) % At tth = 0 this doesn't work
%    cor(k) = transm./((1./(1-1./cos(tth(k)))/mud).*(exp(-mud./cos(tth(k)))-exp(-mud)));
%  else % So in the special case at 0
%    cor(k) = 1;
%  end;
%end;

%cor = cor(:);