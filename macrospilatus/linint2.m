function z0=linint2(x,y,z,x0,y0);
%  z0=linint2(x,y,z,x0,y0);
% Mika's 2 dimentional linear interpolation
% Mikan kaksiulotteinen lineaarinen interpolaatio 
%
% x on rivien koordinaatti
% y on sarakkeiden koordinaatti
% z on interpoloitava matriisi
%    x ja y ei tarvitse olla tasav‰liset (mutta kasvavat kuitenkin)
%
% x0 on uusi rivien koordinaatti
% y0 on uusi sarakkeiden koordinaatti
% z0 on interpoloitu matriisi
%
% Created by Mika Torkkeli (around year 2000?)

[N,M]=size(z);
if(max(size(x))~=N),disp('x:n koko on v‰‰r‰');return;end;
if(max(size(y))~=M),disp('y:n koko on v‰‰r‰');return;end;
Fx=[diff(z);zeros(1,M)];
Fy=[diff(z')',zeros(N,1)];
Fxy=[diff(Fy);zeros(1,M)];
[inx,dx]=linbase(x,x0);
j=find(x0<=min(x));
inx(j)=ones(size(j));
j=find(x0>=max(x));
inx(j)=N*ones(size(j));
[iny,dy]=linbase(y,y0);
j=find(y0<=min(y));
iny(j)=ones(size(j));
j=find(y0>=max(y));
iny(j)=M*ones(size(j));
z0=z(inx,iny)+(dx*ones(size(iny'))).*Fx(inx,iny)+(ones(size(inx))*dy').*Fy(inx,iny)+(dx*dy').*Fxy(inx,iny);

