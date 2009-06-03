function g = tanfit(lamq,qpix,qh,lambda)

% function g = tanfit(lamq,qpix,qh,lambda)
%
% Submacro for qrange.m

g = sum(abs(qh-4*pi*sin(atan(abs(lamq(1))*(qpix+abs(lamq(2))))/2)/lambda));
