function mask=makemask(mask,A);
% mask=makemask(mask,A);
%
% MAKEMASK is an interactive program for creating masks. Mask is a logical matrix
% which may be used to remove (or deselect) bad regions of images.
%
% mask = logical matrix, 0=masked , 1 = non-masked 
% A    = background image
%
% Matrix A is used only as a background image to guide the masking/unmasking of regions
% Input mask is taken as a starting point and any non-zero elements are equal to 1.
% Programs masks/unmaskes selected regions and returns the final mask
%
% To select polygon, click LMB in the image. Then mark the corners clockwise
% or counter-clockwise with LMB and the final corner with RMB. Note
% that you cannot change the direction of rotation.
% To select sphere, click RMB in the image. Then mark the center with LMB and
% radius with RMB.
%
% The white curve marks the selected region. You may now mask and unmask this region by clicking
% respective boxes at the left corner below the image. Click the right corner to finish program.
%
% NOTE: when using  integrating macros IMAGEINT etc., the integrated areas
% have zero mask, thus use ~mask
%
% Mika Torkkeli (mika.torkkeli@helsinki.fi) 20/5/02

CON=0.1;

A=A-min(min(A));
A=A+max(max(A))/255;

if(sum(size(mask)==size(A))==2),
mask = (mask~=0);
else,
mask=(mask(1)~=0)*ones(size(A));
end;

figure(1); 
hold off 
IMA=imagesc(log(abs(A.*(mask+CON))));
hold on
zoom off


[N,M]=size(A);
xx=ones(N,1)*(1:M);xx=xx(:);
yy=(1:N)'*ones(1,M);yy=yy(:);
indx=(1:(N*M))';

cur=[];

BUTX=min(40,round(M/10));
BUTY=min(35,round(N/15));

pll=plot([1,BUTX,BUTX,1,1],[1,1,BUTY,BUTY,1]+N,'g-');set(pll,'LineWidth',2);
pll=plot([1,BUTX,BUTX,1,1]+BUTX,[1,1,BUTY,BUTY,1]+N,'g-');set(pll,'LineWidth',2);

pll=plot([1,BUTX,BUTX,1,1]+(M-BUTX),[1,1,BUTY,BUTY,1]+N,'g-');set(pll,'LineWidth',2);

TOF=-BUTX*0.4;
FSIZ=8;

tx=text(BUTX/2+TOF,BUTY/2+N,'MASK');set(tx,'FontSize',FSIZ);set(tx,'Color',[0 0 0]);
tx=text(BUTX*3/2+TOF,BUTY/2+N,'UNMASK');set(tx,'FontSize',FSIZ);set(tx,'Color',[0 0 0]);
tx=text(BUTX/2+TOF+(M-BUTX),BUTY/2+N,'DONE');set(tx,'FontSize',FSIZ);set(tx,'Color',[0 0 0]);

axis([1,M,1,N+BUTY]);

x=1;y=1;
pl=plot(x,y,'w-');



[px,py,BUT0]=ginput(1);

while(~(px>(M-BUTX) & py>N));
   
   if(px<BUTX & py>N),
	if((length(x)<4 & OBJ==1) | (length(x)<2 & OBJ~=1)),
        title('Cannot mask right now');
	else,
	     if(OBJ==1),
        dx=diff(x);
        dy=diff(y);
        cur=indx;rx=xx;ry=yy;
        DI=sign(dy(2)*dx(1)-dy(1)*dx(2));
         for j=1:length(dx),
         tx=rx-x(j);
         ty=ry-y(j);
         jj=find((DI*(ty*dx(j)-tx*dy(j)))<0);
         cur(jj)=[];
         rx(jj)=[];
         ry(jj)=[];
         end;
            else,
		   jj=find(((xx-x(1)).^2+(yy-y(1)).^2)<(RADI^2));
                   cur=indx(jj);
	    end;
        mask(cur)=zeros(size(cur));
        set(IMA,'CData',log(abs(A.*(mask+2*CON))))
        title('Region masked');
        end;
   elseif(px>BUTX & px<BUTX*2 & py>N),
	if((length(x)<4 & OBJ==1) | (length(x)<2 & OBJ~=1)),
        title('Cannot unmask right now');
	else,
	     if(OBJ==1),
        dx=diff(x);
        dy=diff(y);
        cur=indx;rx=xx;ry=yy;
        DI=sign(dy(2)*dx(1)-dy(1)*dx(2));
         for j=1:length(dx),
         tx=rx-x(j);
         ty=ry-y(j);
         jj=find((DI*(ty*dx(j)-tx*dy(j)))<0);
         cur(jj)=[];
         rx(jj)=[];
         ry(jj)=[];
         end;
            else,
		   jj=find(((xx-x(1)).^2+(yy-y(1)).^2)<(RADI^2));
                   cur=indx(jj);
	    end;
        mask(cur)=ones(size(cur));
        set(IMA,'CData',log(abs(A.*(mask+2*CON))))
        title('Region unmasked');
        end;
   else,
    if(BUT0==1),
    OBJ=1;
    title('Mark polygon');
    [x,y,BUT]=ginput(1);
    j=2;
     while(BUT~=3);
     [x(j),y(j),BUT]=ginput(1);
     j=j+1;
     end;
    x(j)=x(1);
    y(j)=y(1);
    set(pl,'YData',y);
    set(pl,'XData',x);
    title('Mask/Unmask selected area');
    else,
    OBJ=2;
    title('Mark sphere');
      [x,y,BUT]=ginput(1);
       while(BUT~=3);
       [x(2),y(2),BUT]=ginput(1);
       end;
	RADI=sqrt((x(2)-x(1))^2+(y(2)-y(1))^2);
      set(pl,'YData',y(1)+RADI*cos((0:0.01:2)*pi));
      set(pl,'XData',x(1)+RADI*sin((0:0.01:2)*pi));
      title('Mask/Unmask selected area');
     end; %if/else 
    end; %if/else
[px,py,BUT0]=ginput(1);
set(IMA,'CData',log(abs(A.*(mask+2*CON))))
end; %while

hold off





