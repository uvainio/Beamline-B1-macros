function savebinnedpilatus(fsns,distance,points,q1,q2)

% function savebinnedpilatus(fsns,distance,points,q1,q2)
%
% Optional:
% function savebinned(fsns,distance,points,q1,q2,theor)
%
% distance is the theoretical distance and samples measured at the same
% theoretical distance will be processed (using a sloppy condition) so
% that even when the sample thicness has been subtracted from the distance
% this macro will process it anyway.
%
% When binning data analysed using theoretical transmission for glassy
% carbon put flag 'theor' to 1, otherwise don't use it.
%
% Created 31st October 2007 Ulla Vainio
% Edited 19.3.2008 by Ulla Vainio: replaced the binning algorithm that
% produced artificial oscillations to the data by a simple Matlab
% interpolation with interp1 using the shape-preserving piecewise cubic
% interpolation.

finebin = 800;
% Finebinning is done to put all measurements first on the same scale
% Then the further binning does not induce so much oscillations due to
% different initial binning.


  [datain,param] = readintnormpilatus(fsns);


sd = size(datain);

for(k = 1:sd(2))
   % Sloppy condition to make sure that sample thickness induced difference
   % in distance does not make the macro to exclude samples.
    if(param(k).Dist/distance > 0.99 & param(k).Dist/distance < 1.01) 
      % Find which number of points we have
      pointsorig = length(find(datain(k).q>q1 & datain(k).q<q2));
      if(points>pointsorig)
        disp(sprintf('ERROR: Number of points is larger than in the original (%d). You must decrease the number of points.',pointsorig));
        return
      end;
      %[qbin,intbin,errbin] = tobins(datain(k).q,datain(k).Intensity,datain(k).Error,points,q1,q2);
      % 1.10.2008 Binning after interpolating to same q first
      % Linear interpolation to same q, this loses information and does
      % not take advantage of the intensity per point increase
      %qbin = transpose([q1:((q2-q1)/(points-1)):q2]);
      
      qbin = transpose([q1:((q2-q1)/(finebin-1)):q2]);
      intbin = interp1(datain(k).q,datain(k).Intensity,qbin,'pchip');
      errbin = interp1(datain(k).q,datain(k).Error,qbin,'pchip');
      % Now bin to the desired bin number
      [qbin,intbin,errbin] = tobins(qbin,intbin,errbin,points,q1,q2);
         
      name = sprintf('intbinned%d.dat',param(k).FSN);
      fid = fopen(name,'w');
      if(fid > -1)
            for(m = 1:length(intbin))
              fprintf(fid,'%e %e %e\n',qbin(m),intbin(m),errbin(m));
            end;
            fclose(fid);
            disp(sprintf('Saved data to file %s',name));
         else
            disp(sprintf('Unable to save data to file %s',name));
      end;
    end;
end;
