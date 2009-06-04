function [q,I,e,A]=sanitizeintegrated(q,I,e,A,threshold)
% function [q,I,e,A]=sanitizeintegrated(q,I,e,A,threshold)
%
% Perform sanitization on the data, returned by radint, asimint or
% sectorint.
%
% Inputs (as returned by asimint, radint or sectorint):
%        q: vector with the values of the momentum-transfer (or angle in
%           case of an asimuthally averaged curve)
%        I: the intensity vector
%        e: the error vector
%        A: the area vector
%        threshold [optional]: the sanitization threshold. Default value is 1
% Outputs:
%        q,I,e,A sanitized.
% 
% Sanitization means to delete elements at which A is less than threshold
%
% Created: 27.04.2009. Andras Wacha (awacha at gmail dot com)
if (nargin<5)
    threshold=1;
end;
q(A<threshold)=[];
I(A<threshold)=[];
e(A<threshold)=[];
A(A<threshold)=[];
