function [or,B,I0,hr,hl,vu,vd]=getorizoomed(A,pri);
% [or,B,I0,hr,hl,vu,vd]=getorizoomed(A,pri);
% finds the direct beam position in matrix A. Returns also the beam profile
% and vertical and horizontal slices:
%
% OUT:
% or = center of beam [vertical,horizontal]
% B  = beam profile: interpolated to odd x odd matrix where origin is
%      in the middle pixel (approximately)
% I0 = direct beam intensity
% hr = integral slice to horizontal right
% hl = integral slice to horizontal left
% vu = integral to vertical up
% vd = integral to vertical down
%
% all 1-d slices are interpolated to even channel units
%
% USAGE:
% Zoom appropriate region of data so that the direct beam is inside
% the region.
% 
% Author: Mika Torkkeli
% Modified so that it is already zoomed to 'pri' Ulla Vainio 31.3.2009

figure(1);imagesc(log(A+1)); pause
%j1=input('zoom figure around direct beam position ');
ax=round(pri);
jv=(ax(3)):(ax(4));
jh=(ax(1)):(ax(2));
B=A(jv,jh);
imagesc(log(B+1)); drawnow; pause

I0=sum(sum(B))

vp=sum(B');vp=vp/sum(vp);
hp=sum(B);hp=hp/sum(hp);

TRES=0.05;

N=length(vp);jv=(1:N);
maxi=max(vp);
tres1=vp(1)+(maxi-vp(1))*TRES;
tres2=vp(N)+(maxi-vp(N))*TRES;
j0=find(vp==maxi);j0=j0(1);
jj=find(vp<tres1 & jv<j0);jv1=max(jj)+1;
jj=find(vp<tres2 & jv>j0);jv2=min(jj)-1;

N=length(hp);jh=(1:N);
maxi=max(hp);
tres1=hp(1)+(maxi-hp(1))*TRES;
tres2=hp(N)+(maxi-hp(N))*TRES;
j0=find(hp==maxi);j0=j0(1);
jj=find(hp<tres1 & jh<j0);jh1=max(jj)+1;
jj=find(hp<tres2 & jh>j0);jh2=min(jj)-1;

%plot(jv,vp,jh,hp,jv(jv1:jv2),vp(jv1:jv2),'o',jh(jh1:jh2),hp(jh1:jh2),'o')
%pause;

jv=jv(jv1:jv2)+ax(3)-1;vp=vp(jv1:jv2);
jh=jh(jh1:jh2)+ax(1)-1;hp=hp(jh1:jh2);

or=[sum(jv.*vp)/sum(vp),sum(jh.*hp)/sum(hp)];

%plot(jv,vp,jh,hp)
%pause;

Cv=sum(A(:,jh)')/length(jh);
Ch=sum(A(jv,:))/length(jv);

[N,M]=size(A);

do=rem(or,1);
y1=Cv(1:(N-1))+do(1)*diff(Cv);
x1=Ch(1:(M-1))+do(2)*diff(Ch);

fo=floor(or);

vu=y1(fo(1):-1:1);
vd=y1(fo(1):(N-1));

hl=x1(fo(2):-1:1);
hr=x1(fo(2):(M-1));

%semilogy(0:(length(vu)-1),vu,'o',0:(length(vd)-1),vd,'+',0:(length(hl)-1),hl,'o',0:(length(hr)-1),hr,'+');pause;

mv=ceil(max(abs(jv-or(1))));
mh=ceil(max(abs(jh-or(2))));

y=or(1)+(-mv:mv);
x=or(2)+(-mh:mh);

ox=floor(or(2)-mh):ceil(or(2)+mh);
oy=floor(or(1)-mv):ceil(or(1)+mv);

%figure(1);surf(ox,oy,A(oy,ox));view(0,90);


B=linint2(oy,ox,A(oy,ox),y,x);

%figure(2);surf(x,y,B);view(0,90);



