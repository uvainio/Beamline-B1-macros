function f = gaussianline(lam,x)

% function f = gaussianline(lam,x)
%
% NOTE: macro gaussianfit.m uses this.

n = length(lam);
f = 0;
j=1;
while j < n-1
   int    = lam(j);
   pos = lam(j+1);
   width = lam(j+2);
   f = f + int*(exp(-0.5*(x-pos).^2/width^2));
   j = j + 3;
end;

f = f + lam(length(lam)-1)*x + lam(length(lam));
