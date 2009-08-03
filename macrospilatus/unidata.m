function dat = unidata(datA, datB, qcon)

% function dat = unidata(datA, datB, qcon)
%
% Unites two data sets A and B at qcon.
%
% datA and datB     [q data error] in a matrix
% qcon              connecting point q
% 
% OUT:
% dat = united data
% Created: Ulla Vainio (about 2000)
% Edited: UV 31.7.2009 corrected i1 and i2 calculations

qA = datA(:,1);      qB = datB(:,1);
dataA = datA(:,2);   dataB = datB(:,2);
errorA = datA(:,3);  errorB = datB(:,3);

temp = find(qA<qcon);
i1 = temp(end);
%if(qA(i1(2:end)) ~= 0)
%  i1 = max(i1); % If the last q-value is zero..
%else
%  i1 = i1 - 1;
%end;

temp = find(qB>qcon);
i2 = temp(1);

q = ones(length(qA(1:i1)) + length(qB(i2:length(qB))),1);
data = q; % Ones.
error = q;

q(1:i1) = q(1:i1).*qA(1:i1);
q(i1+1:length(q)) = q(i1+1:length(q)).*qB(i2:length(qB));

data(1:i1) = data(1:i1).*dataA(1:i1);
data(i1+1:length(data)) = data(i1+1:length(data)).*dataB(i2:length(qB));

error(1:i1) = error(1:i1).*errorA(1:i1);
error(i1+1:length(error)) = error(i1+1:length(error)).*errorB(i2:length(qB)); 

dat = [q data error];


