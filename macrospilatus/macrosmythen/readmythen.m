function data = readmythen(prefix,fsns,q,tth,transm,slit)

% function data = readmythen(prefix,fsns,q,tth,transm,slit)
%
% fsns = file sequence numbers of data
% calibdat = structure containing the Silicon calibration data obtained with
%              readSiCalib.m
% transm = transmissions of samples in a vector (optional), if this is
%           provided an angle dependent absorption ocrrection is made
% slit = 'angle' if you use the slit that gets larger with pixel or
%        'straight' if a normal line slit
%
% Created 2.4.2009 Ulla Vainio

badpixels = [6 307 308 309 380 410 491 492 493 1257:1:1280];

counter2 = 1;
for(k = 1:length(fsns))
   fid = fopen(sprintf('%s%05d.dat',prefix,fsns(k)));
   if(fid ~= -1)
      dat1 = load(sprintf('%s%05d.dat',prefix,fsns(k)));

      % exclude bad pixels
      counter = 1;
      for(m = 1:1280)
          data2(counter,counter2) = dat1(m,2);
          if(~isempty(find(m == badpixels)))
            data2(counter,counter2) = 0;
          end;
          counter = counter + 1;
      end;
      
      data(counter2).q = q;
      data(counter2).Intensity = flipud(data2(:,counter2));
      data(counter2).Error = sqrt(data2(:,counter2));

      % Correct for the slit opening by dividing by the slit opening
      % slit opening in the beginning 1.09 mm, in the end 6.96 mm, slit
      % width is 70 mm, detector width is 64 mm
      if(strcmp(slit,'angle'))
          slitcor = 1.3418 + [0:1279]/1279*(6.7082-1.3418);
          data(counter2).Intensity = data(counter2).Intensity./slitcor';
          data(counter2).Error = data(counter2).Error./slitcor';
      end;

      if(nargin==3)
         disp(sprintf('Using transmission %.4f for file %d.',transm(k),fsns(k)))
         cor = absorptionangledependent(tth,transm(k));
         data(counter2).Intensity = data(counter2).Intensity.*cor;
         data(counter2).Error = data(counter2).Error.*cor;
      end;
      
      fclose(fid);
<<<<<<< HEAD:macrospilatus/macrosmythen/readmythen.m
      dat = [data(counter2).q' data(counter2).Intensity data(counter2).Error];
=======
      dat = [data(counter2).q data(counter2).Intensity data(counter2).Error];
>>>>>>> master:macrospilatus/macrosmythen/readmythen.m
      writemythenfile(data(counter2).q,data(counter2).Intensity,data(counter2).Error,fsns(k));
      counter2 = counter2 + 1;
   end;
end;


