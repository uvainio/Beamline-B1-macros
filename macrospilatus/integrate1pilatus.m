function [intensity,error] = integrate1pilatus(A,ori,mask,pix1,pix2,steps)

% function [intensity,error] = intergate1pilatus(A,ori,mask,pix1,pix2,steps)
%
% Integrating the image over a certain pixel range. (Accuracy of one pixel)
%
% IN:
% 
% A = data matrix
% ori = direct beam position on the sample
% mask = mask, so that bad pixels and beamstop etc are excluded from the
%  integration
% pix1 = first pixel for integration (when looking from center of the beam)
% pix2 = last pixel for integration
% steps = how many points in the degree scale
%  (always full circle, so use 360 if you want 1 degree resolution)
%
% OUTPUT:
% Integrated intensity as a function of angle (vector) and its error.
%
% Created: 8.10.2009 Ulla Vainio (ulla.vainio@desy.de)

% From Andras Wacha's code for plotting, plot a figure of the masked areas and the
% center
tmp=A;
tmp(tmp<=0)=min(tmp(tmp(:)>0));
imagesc(log(tmp));
axis image
hold on;
% plot black where the scattered intensity is nonpositive
black=zeros(size(tmp,1),size(tmp,2),3);
h=image(black);
set(h,'AlphaData',A<=0);
% cover masked area with white
white=ones(size(mask,1),size(mask,2),3);
h=image(white);
set(h,'AlphaData',(1-mask)*0.70);
colorbar;
% Plot center
plot([1 size(A,2)],[ori(1) ori(1)],'w-');
plot([ori(2) ori(2)],[1 size(A,1)],'w-');
plot([1 ori(2)],[1 1]*ori(1),'r-'); % Red line indicates where is zero angle
% Plot integration area with circles
radius=pix1;
radius2=pix2;
x=cos((0:0.01:2)*pi)*radius+ori(2); % circle1: x values for circle points
y=sin((0:0.01:2)*pi)*radius+ori(1); % y values for circle points
x2=cos((0:0.01:2)*pi)*radius2+ori(2); % circle2
y2=sin((0:0.01:2)*pi)*radius2+ori(1); 
plot(x,y,'w-','LineWidth',1);
plot(x2,y2,'w-','LineWidth',1); % draw a circle
hold off;
drawnow;

sA = size(A);
C = zeros(steps,1); % One degree step
rarea = C;
intensity = C; error = C;
pix1s = pix1^2;
pix2s = pix2^2;

%B = zeros(size(A(:,:,1)));
for(k = max(round(ori(1))-pix2-1,1):min(round(ori(1))+pix2,619)) % Just go throught the pixels up to the last pixel we want!
   for(m = max(round(ori(2))-pix2-1,1):min(round(ori(2))+pix2,487))
%       B(k,m) = 100;
       r2 = ((k-ori(1))^2+(m-ori(2))^2);
      if(mask(k,m)==1 & r2>=pix1s & r2<=pix2s)
          rady = acos((m-ori(2))/sqrt(r2)); % in radians
          radx = asin((k-ori(1))/sqrt(r2));
          if(radx <= 0 & rady <=0)
             degree1 = abs(radx)*180/pi;
          elseif(radx <= 0 & rady >= 0)
             degree1 = (pi - abs(rady))*180/pi;
          elseif(radx >= 0 & rady >= 0)
             degree1 = (pi + abs(rady))*180/pi;
          elseif(radx >= 0 & rady <= 0)
             degree1 = (2*pi - abs(radx))*180/pi;
          end;       
          % Calculate to which bin the intensity belongs to
          degree1 = round(degree1/(360/steps));
          if(degree1 == steps) % If degree = 360
              degree1 = 0; % Fixing a rounding problem with this
          end;
          C(degree1+1) = C(degree1+1) + A(k,m);
          rarea(degree1+1) = rarea(degree1+1) + 1;
      end;
   end;
end;
%imagesc(A(:,:,1)+B)
% Take care, if some bins in the vector had no intensity, then number of
% pixels added (rarea) is zero and we cannot divide by it.
notzeros = find(rarea>0);
intensity(notzeros) = C(notzeros)./rarea(notzeros);
error(notzeros) = sqrt(C(notzeros))./rarea(notzeros);