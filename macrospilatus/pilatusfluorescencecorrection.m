function [fluorcorr,intensity] = pilatusfluorescencecorrection(fsns,mask)

% fluorcorr = pilatusfluorescencecorrection(fsn,mask)
%
%
% Created: 27.10.2009 Ulla Vainio

if(nargin>1)
   % Integrate over the angle 
   for(k = 1:length(fsns))
      data = read2dB1datapilatus('org_',fsns(k),'.tif');
     [intensity,error] = integrate1pilatus(data,[64 467],mask,400,420,360);
%      I3 = trapz(intensity(270:290));
%      I2 = trapz(intensity(310:330));
      I3 = trapz(intensity(270:290));
      I2 = trapz(intensity(310:330));
      factor1(k) = (I2/I3);
      pause
      plot(intensity);
   end;

   factor = mean(factor1)
   factorstd = std(factor1)
else
    factor = fsns;
end;

A = zeros(619,487);

A(round(619*1/3):round(619*2/3),:) = ones(size(A(round(619*1/3):round(619*2/3),:)))*factor;

fluorcorr = A;