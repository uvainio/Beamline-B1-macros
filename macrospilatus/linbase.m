function [in,di] = linbase(x,xo);
%  [in,di] = linbase(x,xo);
%
% palauttaa indeksivektorin in ja  lisäyksen di (pisteiden x0
% "osoitteen" kannassa x, x ei välttämättä ole tasavälinen)
%
% Created by Mika Torkkeli
x=x(:);
xo=xo(:);
N=max(size(x))-1;
minx=min(x);
maxx=max(x);
ran=(maxx-minx);
dx=diff(x);

in=zeros(size(xo));
di=zeros(size(xo));
j=find(xo>=minx & xo<=maxx);
xo=xo(j);

s1 = ceil((xo-minx)/ran*N);
jj=find(s1==0);s1(jj)=ones(size(jj));

s2=(xo-x(s1))./dx(s1);

while(min(s2)<0 | max(s2)>1),
jj=find(s2<0);
s1(jj)=s1(jj)-1;
jj=find(s2>1);
s1(jj)=s1(jj)+1;
s2=(xo-x(s1))./dx(s1);
end;

in(j)=s1;
di(j)=s2;



