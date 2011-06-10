function uniteB1pilatuswaxsshort(data,param,samplename,uniqwaxs,q1waxs,q2waxs,qwaxs1,qwaxs2,flatfield,waxsshift)

% function uniteB1pilatuswaxsshort(data,param,samplename,uniqwaxs,q1waxs,q2waxs,flatfield,waxsshift)
%
% dist = e.g. [3635 935]
% 
%
% Created 7.11.2007
% Added saving of only summed files, if one distance is missing.
% 16.5.2009 UV: Added samplename2 in case name in short and long distance
% measurements was different, put the same name if they were the same
% Edited: 27.7.2009 UV, added WAXS
% Edited: 13.4.2010 UV: added flatfield option and possibility to shift the
% WAXS data by a few pixels using waxsshift

datasum = data;

disp('Uniting data, please check that curves match before pressing enter.');

for(k = 1:length(param))
    if(strcmp(param(k).Title,samplename))
        short = struct('q',datasum(k).q,'Intensity',datasum(k).Intensity,'Error',datasum(k).Error,'Temperature',param(k).Temperature);
        % Load in WAXS data
        [datawaxs,paramwaxs] = readintnormmythen(param(k).FSN);
        if(isstruct(datawaxs))
            datasumwaxs = datawaxs;
        end;
        if(nargin>9)
             waxstmp = struct('q',datasumwaxs.q*waxsshift,'Intensity',datasumwaxs.Intensity./flatfield,'Error',datawaxs.Error,'Temperature',paramwaxs.Temperature);
             title('WAXS after flatfield correction');
             plot(waxstmp.q,waxstmp.Intensity);
             pause
         else        
           waxstmp = struct('q',datasumwaxs.q,'Intensity',datasumwaxs.Intensity,'Error',datasumwaxs.Error,'Temperature',paramwaxs.Temperature);
         end;
        counterm = 1;
         for(mm = 1:length(waxstmp.Intensity)) % removing bad points
             if(waxstmp.Intensity(mm)~= 0)
                 waxstmp2.q(counterm) = waxstmp.q(mm);
                 waxstmp2.Intensity(counterm) = waxstmp.Intensity(mm);
                 waxstmp2.Error(counterm) = waxstmp.Error(mm);
                 counterm = counterm + 1;
             end;
         end;
         % Unite a few pixels
        [qbin,intbin,errbin] = tobins(waxstmp2.q',waxstmp2.Intensity',waxstmp2.Error',400,qwaxs1,qwaxs2);
        waxs = struct('q',qbin,'Intensity',intbin,'Error',errbin);
         [f,multipl2] = consaxs([waxs.q waxs.Intensity waxs.Error],[short.q short.Intensity short.Error],uniqwaxs,q1waxs,q2waxs,samplename);
         counterm = 1; f2 = 0;
         for(mm = 1:length(f)) % removing bad points
             if(f(mm,2)~= 0)
                 f2(counterm,1) = f(mm,1);
                 f2(counterm,2) = f(mm,2);
                 f2(counterm,3) = f(mm,3);
                 counterm = counterm + 1;
             end;
         end;
         name = sprintf('united%d.dat',min(param(k).FSN));
         title(name);
         fid = fopen(name,'w');
         if(fid > -1)
            for(pp = 1:length(f2))
              fprintf(fid,'%e %e %e\n',f2(pp,1),f2(pp,2),f2(pp,3));
            end;
            fclose(fid);
            disp(sprintf('Saved united data to file %s',name));
         else
            disp(sprintf('Unable to save data to file %s',name));
         end;
         % Write log-file
         name = sprintf('united%d.log',min(param(k).FSN));
         fid = fopen(name,'w');
         if(fid > -1)
            fprintf(fid,'FSNs:');
            temp = param(k).FSN;
            for pp = 1:length(temp)
                fprintf(fid,' %d',temp(pp));
            end;
            fprintf(fid,'\n');
            fprintf(fid,'Sample name: %s\n',param(k).Title);
            fprintf(fid,'Calibrated energy: %e\n',param(k).EnergyCalibrated);
            fprintf(fid,'Temperature: %.f\n',short.Temperature);
            fprintf(fid,'Multiplied WAXS data by: %f\n',multipl2);
            fclose(fid);
            disp(sprintf('Saved %s',name));
         else
            disp(sprintf('Unable to save data to file %s\n',name));
         end;
 %       break; % Break only the inner loop
     end;
 end;
