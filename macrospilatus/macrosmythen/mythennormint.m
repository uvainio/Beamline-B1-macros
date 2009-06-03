function data = mythennormint(prefix,fsns,q,tth,slit)

% function data = mythennormint(prefix,fsns,q,tth,slit)
%
% fsns = file sequence numbers of data
% prefix = 'waxs_'
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
      header = readheader('org_',fsns(k),'.header');
      if(~strcmp(header.Title,'Empty_beam'))

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

      cor = absorptionangledependent(tth,header.Transm);
      data(counter2).Intensity = data(counter2).Intensity.*cor/header.Transm/header.Monitor;
      data(counter2).Error = data(counter2).Error.*cor/header.Transm/header.Monitor;
      
         fclose(fid);
       dat = [data(counter2).q' data(counter2).Intensity data(counter2).Error];
       writemythenfile(data(counter2).q,data(counter2).Intensity,data(counter2).Error,fsns(k));
       counter2 = counter2 + 1;
      end;
   end;
end;


