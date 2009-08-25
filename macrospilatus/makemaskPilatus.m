function mask = makemaskPilatus(A,mask,DC)

% function mask = makemaskPilatus(A,mask,DC)
%
% A = measurements (matrix, size 619 x 487, third dimension should be 3)
% mask = staring matrix for the mask, normally ones(619,487)
% DC = matrix of empty current measurement
%
% The measurements are compared and if some pixels have same value,
% those pixels are masked out
%
% Created 11.3.2009 Ulla Vainio
%

n1 = 619;
m1 = 487;
if(nargin < 3)
  mask = ones(n1,m1);
end;

% First mask the zeros between the 100k modules

mask(195:213,:) = 0;
mask(408:425,:) = 0;

% Mask the small part in the left corner (tube edge)
for(k = 1:n1)
    for(l = 1:m1)
        if(k > 606 & l < 16 & (n1-k <= n1-606-l))
            mask(k,l) = 0;
        end;
    end;
end;


% Mask beamstop

imagesc(log(A(:,:,1)+1).*mask);
disp('Zoom to the beamstop tightly to mask it')
zoom on
pause
aksel = axis;
bsarea = round(aksel);
mask(bsarea(3):min(bsarea(4),n1),bsarea(1):min(bsarea(2),m1)) = 0;

% Mask bad pixels that are zero or constant
sA = size(A);
if(sA(3)<2)
    disp('Please provide more than 5 matrices in variable A to get statistics. Stopped.');
    return;
end;
counter = 0;
for(m = 1:m1)
   for(n = 1:n1)
      subvalues = A(n,m,:) - A(n,m,1);
      if(((mean(subvalues) == 0 && std(subvalues) == 0) || DC(n,m)>100) && mask(n,m)==1) % Same pixel is zero or constant in every picture
        mask(n,m) = 0;
        counter = counter + 1;
      end;
   end;
end;
disp(sprintf('Masked %d bad pixels (excluding beamstop area and empty gaps)',counter));


% Check quality
imagesc(mask);
title('Mask')
pause
imagesc(min(A(:,:,1),100).*(1-mask));
title('showing masked areas only, this picture should be black')
pause
title('unmasked areas')
imagesc(min(A(:,:,1),100).*(mask));
