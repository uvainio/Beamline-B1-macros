function [fluorcorr,intensity] = pilatusfluorescencecorrection(fsns,mask)

% fluorcorr = pilatusfluorescencecorrection(fsn,mask)
%
%
% Created: 27.10.2009 Ulla Vainio

if(nargin>1)
   % Integrate over the angle 
   for(k = 1:length(fsns))
      data = read2dB1datapilatus('org_',fsns(k),'.tif');
     [intensity,error] = integrate1pilatus(data,[56 465],mask,430,470,360);
      I3 = trapz(intensity(270:290));
      I2 = trapz(intensity(310:330));
      factor1(k) = (I3-I2)/20;
   end;

   factor = mean(factor1)
   factorstd = std(factor1)
else
    factor = fsns;
end;

A = zeros(619,487);

A(round(619*2/3):end,:) = ones(size(A(round(619*2/3):end,:)))*factor;

fluorcorr = A;