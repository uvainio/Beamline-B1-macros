function [C,NC]=imageint(A,or,p,x,y);
% C=imageint(A,or,mask,x,y);
%
% Performs radial averaging of the image A. The image is essentially a matrix
% (as seen by MATLAB functions IMAGE and IMAGESC), i.e. a two-dimensional 
% function A(x,y) where x and y are the vertical and horizontal coordinates
% respectively. Values of x run from top to bottom and y from left to right.
%
%
% INPUT:
%
%  A    = image to be averaged, size NxM
%
% or    = origin of image [vertical,horizontal] 
%         NOTE! The origin is given in (x,y) coordinates
%
% mask  = (OPTIONAL) informs which pixels are to be used for averaging. The mask
%         may be given in two ways:
%         1) Either a list (vector) of indeces in sets of four, each set
%            defining a square which is NOT INCLUDED in the average, e.g.
%            mask = [firstcolumn,lastcolumn,firstrow,lastrow,...] 
%            They are defined this way so that zooming the image (IMAGESC) around the "bad" region
%            and calling pt=round(axis) will return the desired set of indeces.
%         2) If size(mask)==size(A) all pixels for which mask is NON-ZERO (!) are excluded. 
%
% x,y   = (OPTIONAL) The vertical and horizontal coordinates. These may also be provided in 
%         different ways:
%         1) If either one is empty, the corresponding coordinate is, for x say,  
%            x = (1:N)-or(1)
%         2) They may be scalars, in which case
%            x = x*(1:N)-or(1)
%         3) or vectors of length N and M
%            x = x -or(1)
%         4) or, in the most general case, vectors (or matrices) of length (or size) NxM giving
%            corresponding coordinates for each pixel separately
%            x = x - or(1)
%            
%         Pixels for which x or y are NaN are automatically discarded   
%
% OUTPUT:
%
%  C    = vector which contains the radial average. The average is always CALCULATED AT INTEGER BINS
%         starting from zero to the largest (unmasked) pixel coordinate
%
% For averaging over sector instead of full sphere, use programs PIEINT.M and SECTINT.M 
%
% Latest edit: 28/02/2002 Mika Torkkeli
%

[N,M]=size(A);A=A(:);

if(nargin<5),
     y = ones(N,1)*((1:M)-or(2));y=y(:);
elseif(length(y)==0),
     y = ones(N,1)*((1:M)-or(2));y=y(:);
elseif(length(y)==1),
     y = ones(N,1)*(y*(1:M)-or(2));y=y(:);
elseif(prod(size(y))==M),
     y = ones(N,1)*(y(:)'-or(2));y=y(:);
elseif(prod(size(y))==(N*M)),
     y = y(:)-or(2);
else,
disp('Error in size of y');
return;
end;

if(nargin<4),
     x = ((1:N)'-or(1))*ones(1,M);x=x(:);
elseif(length(x)==0),
     x = ((1:N)'-or(1))*ones(1,M);x=x(:);
elseif(length(x)==1),
     x = (x*(1:N)'-or(1))*ones(1,M);x=x(:);
elseif(prod(size(x))==N),
     x = (x(:)-or(1))*ones(1,M);x=x(:);
elseif(prod(size(x))==(N*M)),
     x = x(:)-or(1);
else,
disp('Error in size of x');
return;
end;

if(nargin>2),

 if(size(p)==[N,M]),
 ioff=find(p);
        %to display:
        A(ioff)=min(min(A))*ones(size(ioff));B=reshape(A,N,M);imagesc(log(max(B+1,1)));drawnow; 
 A(ioff)=[];
 x(ioff)=[];
 y(ioff)=[]; 
 elseif(max(size(p))>0),
 NP=length(p);
  if(rem(NP,4)~=0),
  disp('patch index vector should be of length 4*N');
  return;
  else,
  MP=NP/4;
  ij=1:4;
  ioff=[];
   for jj=1:MP,
   indx=p((jj-1)*4+ij);
   indx=max(indx,1);
   indx(2)=min(indx(2),M);
   indx(4)=min(indx(4),N);
 %  disp(['removing cols ',int2str(indx(1)),':',int2str(indx(2)),' by rows ',int2str(indx(3)),':',int2str(indx(4))]);
   ih=indx(1):indx(2);
   iv=indx(3):indx(4);
   tioff=N*(ones(size(iv'))*(ih-1))+iv'*ones(size(ih));
   ioff=[ioff;tioff(:)];
   end;
  A(ioff)=min(min(A))*ones(size(ioff));B=reshape(A,N,M);imagesc(log(max(B+1,1)));drawnow;
  A(ioff)=[];
  x(ioff)=[];
  y(ioff)=[]; 
 end; %for jj 
  end; %if rem(NP,4)

end; %if nargin, else

ioff = find(isnan(x) | isnan(y));
  A(ioff)=[];
  x(ioff)=[];
  y(ioff)=[]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


d=sqrt(x.^2+y.^2);
md=ceil(max(max(d)))+1;
ind=round(d)+1;

C=zeros(md,1);
NC=zeros(md,1);

for j=1:length(ind),
  C(ind(j))=C(ind(j))+A(j);
  NC(ind(j))=NC(ind(j))+1;
end;

jj=find(NC>0);
C(jj)=C(jj)./NC(jj);
