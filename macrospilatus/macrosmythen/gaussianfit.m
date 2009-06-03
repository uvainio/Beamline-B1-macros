function g = gaussianfit(lam,data,x)

% function g = gaussianfit(lam,data,x)
%
% NOTE: Used by macro qrange.m!

f = gaussianline(lam,x(:));

g = sum(abs(data(:)-f));
