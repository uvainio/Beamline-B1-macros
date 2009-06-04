function cor = absorptionangledependent(tth,transm)

% cor = absorptionangledependent(tth,transm)
% 
% Usage: Icorrected = Imeas.*cor
% tth in angles, not radians!
%
% Created: 11.10.2007 UV
% Edited: 25.4.2009 AW tth can now be a matrix of arbitrary size. cor will
% be of the same size. 

mud = -log(transm);
tth = tth*pi/180; % Transforming from degrees to radians

cor = zeros(size(tth));
cor(tth~=0) = transm./((1./(1-1./cos(tth(tth~=0)))/mud).*(exp(-mud./cos(tth(tth~=0)))-exp(-mud)));
cor(tth==0) = 1;

%for(k = 1:length(tth))
%  if(tth(k) ~= 0) % At tth = 0 this doesn't work
%    cor(k) = transm./((1./(1-1./cos(tth(k)))/mud).*(exp(-mud./cos(tth(k)))-exp(-mud)));
%  else % So in the special case at 0
%    cor(k) = 1;
%  end;
%end;

%cor = cor(:);