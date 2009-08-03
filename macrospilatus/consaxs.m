function [f,rel] = consaxs(saxs, usaxs, con, qy1,qy2,samplename)

% Function [f,rel] = consaxs([q saxsdata dataerr], [q usaxsdata dataerr], con, qy1, qy2,samplename) 
%
% IN:
% q = 4*pi*sin(theta)/lambda
% con = the point of connecting the data sets
% qy1, qy2 = the values between a value is integrated to obtain
%            a constant by which the saxs-data is multiplied before
%            connecting the data sets
%
% OUT:
%
% United data set f, which containes in columns the q, data and error.
%
% UV, 1.9.2003 (ulla.vainio@helsinki.fi)
% Edited: 24.5.2004 UV, changed indexing because of extra zeros
% in q-data and normalization to saxs-data instead of usaxsdata.
% Edited: 17.9.2007 UV, changed normalisation so that SAXS data
% is normalised to USAXS data (ulla.vainio@desy.de)

qsaxs = saxs(:,1);      qusaxs = usaxs(:,1);
datasaxs = saxs(:,2);   datausaxs = usaxs(:,2);
errorsaxs = saxs(:,3);  errorusaxs = usaxs(:,3);

% Binning the data


% Finding the indexes corresponding to these values
i1 = min(find(qsaxs > qy1));
i2 = min(find(qsaxs > qy2));
i3 = min(find(qusaxs > qy1));
i4 = min(find(qusaxs > qy2));

% Integrating over the data sets at the same location to get a relation.
const2 = 10000; % To improve accuracy of the calculation.
points = min(length(i1:i2),length(i3:i4));
[qbin1,intbin1] = tobins(qusaxs,datausaxs,errorusaxs,points,qy1,qy2);
[qbin2,intbin2] = tobins(qsaxs,datasaxs,errorsaxs,points,qy1,qy2);
% rel = trapz(qusaxs(i3:i4),datausaxs(i3:i4)*const2)/trapz(qsaxs(i1:i2),datasaxs(i1:i2)*const2)
rel = trapz(qbin1,intbin1*const2)/trapz(qbin2,intbin2*const2);

datasaxs = datasaxs*rel;
errorsaxs = errorsaxs*rel;

loglog(qsaxs,datasaxs,'.',qusaxs,datausaxs,'*'); hold on
plot(qy1*[1 1],[min(intbin2(2:end-1)) max(intbin2(2:end-1))],'-k',qy2*[1 1],[min(intbin2(2:end-1)) max(intbin2(2:end-1))],'-k'); hold off
ylabel('Arbitrary intensity units');
xlabel(sprintf('q (1/%c)',197));
legend('Short dist.','Long dist.')
title(sprintf('Normalization factor for short distance %f',rel));
if(nargin>5)
    title(sprintf('Normalization factor for short distance %f. Sample %s',rel,samplename));
end;
pause

f = unidata([qusaxs datausaxs errorusaxs],[qsaxs datasaxs errorsaxs],con);

loglog(f(:,1),f(:,2),'.');
hold on
errorbar(f(:,1),f(:,2),f(:,3),'.'); hold off
title('United data');
if(nargin>5)
    title(sprintf('United data. Sample %s',samplename));
end;
pause
