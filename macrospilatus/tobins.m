function [q,ints2,errs2] = tobins(qs,ints,errs,bins,fq,lq)

% function [q,ints2,errs2] = tobins(qs,ints,errs,bins,fq,lq)
%
% This TOBINS function combines the data in such a way that
% intensity vectors of different length with different
% q ranges will be on the same scale but with less pixels.
% The number of pixels is defined in the 'bins'. It sould
% be less than the number of pixels in each of the ints.
%
% qs       q-values for each intensity curve
% ints     intensities
% errs     errors of the intensities
% bins     e.g. 110
% fq       first q-value
% lq       last q-value
%
%
% UV 4.5.2004
% Edited: 17.12.2007 UV More accurate error propagation and binning region.
%                       Oscillations induced by this routine still persist.

% First we bin the q-range
ssi = size(ints);
q = transpose([fq:((lq-fq)/(bins-1)):lq]); % Modified: bins -> bins -1 on 19.3.2008 UV
ssq = size(q);
dq = (q(2)-q(1))/2;
dqs = zeros(length(qs)-1,ssi(2));
for(k = 2:length(qs))
  dqs(k-1,:) = (qs(k,:)-qs(k-1,:))/2; % Approximation.
end;
ints2 = zeros(ssq(1),ssi(2)); errs2 = ints2;

% Limits of the pixels
limits2 = zeros(length(q));
limits = zeros(length(qs),ssi(2));
for (k = 1:(length(q)-1))
    limits2(k) = (q(k) + q(k+1))/2;
end;
for (l = 1:ssi(2))
  for (k = 1:(length(qs)-1))
    limits(k,l) = (qs(k,l) + qs(k+1,l))/2;
  end;
end;

for(l = 1:ssi(2))
  for(k = 2:length(limits2))
  counter = 0;
     for(kk = 2:(length(limits)-1))
           if((limits(kk,l) >= limits2(k-1)) && (limits(kk-1,l) < limits2(k)))
              % This is complicated but means that if any part of the pixel
	           % is inside the qbit-pixel the if is true 
              % Next: How much is inside the qbit
              prop = min((limits(kk,l)-limits2(k-1))/(limits(kk,l)-limits(kk-1,l)),(limits2(k)-limits(kk-1,l))/(limits(kk+1,l)-limits(kk,l)));
% Modified 17.12.2007 by UV: instead of comparing to 2*dqs, we compare to
% the limit1 - limit2, should be more accurate, but it does not help to the
% oscillations caused by the binning routine to the data.
              if(prop > 1)
                 prop = 1; % The pixel is inside the qbit totally.
              end;
              ints2(k,l) = ints2(k,l) + prop*ints(kk,l);
              errs2(k,l) = sqrt(errs2(k,l)^2 + (prop*errs(kk,l))^2); % Proper error propagation 17.12.2007 UV
              counter = counter + prop;
	   end;
     end;
     if(counter ~= 0)
	   ints2(k,l) = ints2(k,l)/counter;
	   errs2(k,l) = errs2(k,l)/counter;
     end;
  end;
end;
