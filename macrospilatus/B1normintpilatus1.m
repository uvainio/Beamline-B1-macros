function [qout,intout,errout,header,errmult,energyreal,distance] = B1normintpilatus1(fsn1,thicknesses,sens,errorsens,mask,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,fluorcorr,orig)

% [qout,intout,errout,header] = B1normintpilatus1(fsn1,thicknesses,sens,errorsens,mask,energymeas,energycalib,distminus,pri,mythendistance,mythenpixelshift,fluorcorr)
%
% IN:
% thicknesses = either one thickness in cm or a structure containing
% thicknesses of all samples.
% distminus = sample-to-detector distance difference between PILATUS
%           detector and the standard position
% pri = [xmin xmax ymin ymax] for determining the center of the beam
%       you get these numbers by zooming around the beam, then type axis
% mythendistance = distance from goniometer center to the WAXS detector (MYTHEN), if WAXS detector was not used, put any number
%                    2009 spring 133.8320 mm
% mythenpixelshift = shift in pixels from 0 of the MYTHEN detector (2009 spring 300.3417)
%
% OUT:
%
% qs = q-scales of intensities
% ints = intensities corresponding to fsn1s (excluding empty beams)
%        normalised to absolute intensities (1/cm)
% errs = errors of intensities
% header = header data of the corresponding intensities (first is glassy carbon)
% errmult = error of the absolute intensity scale calibration
%           multiplication factor
% energyreal = calibrated energy of the measured sample
% distance = measurement distance
%
% Created: 10.9.2007 UV
% Edited: R^2 correction to intensities 30.9.2007 UV
% Edited: 2.11.2007 qfrompixelsizeB1 was called with pix = [1:length(ints)]
%         corrected to [0:length(ints)]
%         In other words, the q-scale was off by one pixel.
% Edited: 27.11.2007 In titles spaces are replaced by "_" sign
% Edited: 2.1.2008 Added gasabsorption correction
% Edited: 7.5.2008 saving the angle corrected data of glassy carbons
% Edited: 10.12.2008 UV, changed energy calibration to an external macro
% (and simultanenously changed from spline fit to a linear fit)
% Edited: 8.5.2009 Andras Wacha (awacha@gmail.com)
% Edited: 5.6.2009 AW now radint is called with 1-MASK and NOT with MASK
% Edited: 24.11.2009 UV: Mythen data reduction moved to B1normintallpilatus.m

GCareathreshold=10;
pixelsize = 0.172; % mm
dclevel = 7/(619*487); % counts per second to one pixel of the detector, estimation for the dark current
distancefromreferencetosample = 219; % mm, distance from reference sample holder to normal sample holder
detshift = 50;

if(isstruct(thicknesses)) % This property does not work yet. 
  % Contains or should contain structure variable 'thicknesses':
  sizethick = size(thicknesses);
  flagthick = 0; % Flag for thickness found from the struct thicknesses
else
    thick = thicknesses;
    flagthick = 1; % Flag for thickness found from the struct thicknesses or not
    disp(sprintf('Using thickness %f cm for all samples except references.',thick))
end;

if(numel(energycalib)~=numel(energymeas) | numel(energycalib)<2)
   disp('STOPPING. Variables energycalib and energymeas should contain equal amount of\npoints and at least two points to be able to make the energy calibration.')
   return
end;    

if(nargin < 13) % Integrate each matrix separately % AW updated parameter list and returned values
  [qs,ints,errs,areas,As,Aerrs,header,ori,injectionEB] = B1integratepilatus(fsn1,dclevel,sens,errorsens,mask,pri,energymeas,energycalib,distminus,detshift,fluorcorr);
else
  [qs,ints,errs,areas,As,Aerrs,header,ori,injectionEB] = B1integratepilatus(fsn1,dclevel,sens,errorsens,mask,pri,energymeas,energycalib,distminus,detshift,fluorcorr,orig);
end;

sizeints = size(ints);
counterref = 0;

for(k = 1:sizeints(2))
%AW  Energy calibration was already done by B1integratepilatus.
% % Interpolating the energy to the real energy scale
%   energy1 = getfield(header(k),'Energy');
% %   energyreal(k) = interp1(energymeas,energycalib,energy1,'spline','extrap');
% % Changed to linear fit, thanks Andras! 8.12.2008
%    energyreal(k) = energycalibration(energymeas,energycalib,energy1);
%    transm(k) = getfield(header(k),'Transm');

%AW  The correction for the distance of the reference holder is also done at
% this point. What we need is finding the reference position, the reference
% FSN and the reference number.
% % Correcting for the distance of the reference holder
   if(strcmp(getfield(header(k),'Title'),'Reference_on_GC_holder_before_sample_sequence'))
%      distance(k) = getfield(header(k),'Dist')-distancefromreferencetosample-distminus;
      referencemeas = getfield(header(k),'PosRef');
      referencesfsn = getfield(header(k),'FSN');
      referencenumber = k;
      counterref = counterref + 1;
      currentGC = getfield(header(k),'Current2'); % DORIS current end of measurement
%   elseif(strcmp(getfield(header(k),'Title'),'Reference_on_GC_holder_after_sample_sequence')) % For example AgBeh
%      distance(k) = getfield(header(k),'Dist')-distancefromreferencetosample-distminus;
%      current(k) = getfield(header(k),'Current2');
   else
%      distance(k) = getfield(header(k),'Dist')-distminus;
      current(k) = getfield(header(k),'Current2');
   end;

%AW we do not need to get qs and tths, because qs was supplied by
%B1integratepilatus, and tths is not needed as all the corrections are done
%on the 2D data (also in B1integratepilatus).
%  [qs(:,k),tths(:,k)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[0:(length(ints)-1)]);
end;

if(counterref == 1) % Found at least one reference measurement
% Positions of reference samples in the reference sample holder.
posref155 = 129;
posref500 = 139;
posref1000 = 159;
%posrefGGGC500 = 159.26;
%posref155 = 130.4; % old positions
%posref500 = 140.4;
%posref1000 = 160.4;
 if(round(referencemeas)==round(posref155))
     load calibrationfiles\GC155.dat;
     GCdata(:,1:3) = GC155; thickGC = 143*10^-4; % in cm, According to measurements in autumn 2007
     % Assumption has been made that the density of all samples is the same
 elseif(round(referencemeas)==round(posref500))
     load calibrationfiles\GC500.dat;
     GCdata(:,1:3) = GC500; thickGC = 508*10^-4;% in cm
 elseif(round(referencemeas)==round(posref1000))
     load calibrationfiles\GC1000.dat;
     GCdata(:,1:3) = GC1000; thickGC = 992*10^-4; % in cm
% elseif(round(referencemeas)==round(posrefGGGC500))
%     load calibrationfiles\GC500Guenter_invcm_plateau.dat;
%     GCdata(:,1:3) = GC500Guenter_invcm_plateau; thickGC = 500*10^-4; % in cm
 end;
end;
%     load GC500.dat;
%     GCdata(:,1:3) = GC500; thickGC = 508*10^-4;% in cm
disp(sprintf('FSN %d: Using GLASSY CARBON REFERENCE with nominal thickness %.f micrometers.',referencesfsn,thickGC*10^4));

%AW Instead of binning the measured reference data, we simply re-integrate
% the corrected matrix of the reference measurement to the q-scale of the
% reference data (GCdata(:,1)). After it, q-points at which the effective
% area is less than GCareathreshold are thrown out. To be more specific:
%
% 0. After these steps two data sequences will be present: (q_ref, I_ref,
% err_ref) and (q_meas, I_meas, err_meas, area_meas).
%
% 1. re-integration ensures that q_meas does not contain points, at which
% no valid reference intensity exists.
%
% 2. throwing out points from q_meas and q_ref, at which area_meas is less
% than GCareathreshold ensures that q_ref will not contain points, at which
% the precision of the measured intensities would be questionable.

%AW but first comment the old method
% % Binning reference data and comparing to reference measurements done
% % earlier
% maxpix = min(find(ints(45:end,referencenumber)==0)); % Finding the last zeros and taking the lowest of them
% if(GCdata(end,1)<qs(maxpix,referencenumber)) % If measurement range exceed that of saved in GC file
%       lq = GCdata(end,1); % Last q-value
%       GCint = GCdata(:,:);
% else
%       lq = qs(maxpix,referencenumber);
%       GCint = GCdata(1:max(find(GCdata(:,1)<lq)),:); % Shorten the reference data
%       lq = GCint(end,1);
% end;
% minpix = max(find(ints(1:30,referencenumber)==0))+2;
% if(GCint(1,1)>qs(minpix,referencenumber))
%       fq = GCint(1,1); % First q-value
% else
%       fq = qs(minpix,referencenumber);
%       GCint2 = GCint(min(find(GCint(:,1)>fq)):end,:); % Shorten the reference data
%       clear GCint; GCint = GCint2;
%       fq = GCint(1,1);
% end;
% points = length(GCint(:,1)); % Number of intervals
% % Geometrical correction for detector flatness (includes R^2 correction).
% spatialcorr = geomcorrection(qs(:,referencenumber),energyreal(referencenumber),distance(referencenumber));
% % Angle dependent transmission correction, 2.1.2008 added gas absorption
% % correction
% transmcorr = absorptionangledependent(tths(:,referencenumber),transm(referencenumber)).*gasabsorptioncorrectionpilatus(energyreal(referencenumber),qs(:,referencenumber));
% % Binning the now measured data to same intervals as the reference data
% % Also divide by thickness of the sample ------ in binning points -1 was
% % changed to points on April 4th 2008.
% [qbinGC,intsbinGC,errsbinGC] = tobins(qs(:,referencenumber),ints(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,errs(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,points,fq,lq);

disp('Re-integrating GC data to the same bins at which the reference is defined');
[qsbinGC,intsbinGC,errsbinGC,areasbinGC]=radint(As(:,:,referencenumber),...
                                          Aerrs(:,:,referencenumber),...
                                          header(referencenumber).EnergyCalibrated,...
                                          header(referencenumber).Dist,...
                                          pixelsize,...
                                          ori(1,referencenumber),...
                                          ori(2,referencenumber),...
                                          1-mask,...
                                          GCdata(:,1));
disp('Re-integration done.');
%AW removing the undefined fields (ie. with too small effective area) from the
% reference data, as well as from the integrated.
GCdata(areasbinGC<GCareathreshold,:)=[];  % reference
intsbinGC(areasbinGC<GCareathreshold)=[]; % measured
errsbinGC(areasbinGC<GCareathreshold)=[];
qsbinGC(areasbinGC<GCareathreshold)=[];
areasbinGC(areasbinGC<GCareathreshold)=[];
GCint=GCdata;
%AW now we have intsbinGC, errsbinGC and qsbinGC, which are the measured GC
% intensities. They are defined on the same q-scale as the reference data
% (so there is no q-bin on this range, where no reference data exists).
% Also, the q-bins where not enough intensity was measured (this means 
% areasGC<GCareathreshold) were removed. Thus, to be short, qsbinGC == GCint(:,1).

% this check was removed as Matlab 7.0 (R14) does not support assert.
%equation=(qsbinGC~=GCint(:,1));
%assert(sum(equation)==0,'qsbinGC not equal to GCint(:,1). This is a coding error');

%AW We divide the intensities by the thicknesses.
disp('Dividing measured GC data by the thickness.');
intsbinGC=intsbinGC/thickGC;
errsbinGC=errsbinGC/thickGC;
%AW the reference data should not be divided, as has already been
%normalized by its thickness.

%AW Integrate (trapezoidal) over the area to get a multiplication factor for the
% intensitities to absolute scale.
ll = 2:(size(GCint,1)-1);
mult_orig = trapz(GCint(ll,2))/trapz(intsbinGC(ll));
% Error estimation:
errmult_orig = trapz(GCint(ll,2)+GCint(ll,3))/trapz(intsbinGC(ll,1)-errsbinGC(ll,1)) - mult_orig;
%AW Error propagation:
%AW Error of the trapezoidal formula:
%
% T=0.5* sum((Int(1:end-1)+Int(2:end)).*(q(2:end)-q(1:end-1)));
% errT = 0.5*sqrt( (q(2)-q(1))^2*errInt(1)^2    +  ...
%        (q(end)-q(end-1))^2*errInt(end)^2   + ...
%        sum( (q(3:end)-q(1:end-2)).^2*errInt(2:end-1).^2 ) );
% or without using q in the integration:
%
% errT1 = 0.5*sqrt( errInt(1)^2 + errInt(end)^2 +...
%                   + 2* sum( errInt(2:end-1).^2) )
numerator = trapz(GCint(ll,2));
denominator = trapz(intsbinGC(ll));
errnumerator = 0.5*sqrt( GCint(ll(1),3)^2 +GCint(ll(end),3)^2 + ...
               4*sum(GCint(ll(2:end-1),3).^2));
errdenominator = 0.5*sqrt( errsbinGC(ll(1))^2 + errsbinGC(ll(end))^2 + ...
               4*sum(errsbinGC(ll(2:end-1)).^2));
mult = numerator/denominator;
errmult = mult*sqrt((errnumerator/numerator)^2+(errdenominator/denominator)^2);
disp(sprintf('Mult and errmult with ORIGINAL method: %f +/- %f',mult_orig, errmult_orig));
disp(sprintf('Mult and errmult with NEW method: %f +/- %f',mult, errmult));
disp('Using NEW method for mult and errmult.');

writelogfilepilatus(header(referencenumber),...
                    ori(:,referencenumber),...
                    thickGC,...
                    dclevel,...
                    header(referencenumber).EnergyCalibrated,...
                    header(referencenumber).Dist,...
                    mult,errmult,...
                    0,thickGC,'n',injectionEB(k),pixelsize);
% %writeintfile(qs(:,referencenumber),mult*ints(:,referencenumber)*distance(referencenumber)^2/thickGC,mult*errs(:,referencenumber)*distance(referencenumber)^2/thickGC,header(:,referencenumber));
% % Saving the angle corrected data instead, starting 7.5.2008
% %writeintfile(qs(:,referencenumber),mult*ints(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,mult*errs(:,referencenumber)/thickGC.*spatialcorr.*transmcorr,header(:,referencenumber));
[qs1,ints1,errs1,Areas1]=sanitizeintegrated(qs(:,referencenumber),...
                                            ints(:,referencenumber),...
                                            errs(:,referencenumber),...
                                            areas(:,referencenumber));
writeintfile(qs1,mult*ints1/thickGC,mult*errs1/thickGC,header(:,referencenumber));

%AW Also normalize the 2D data.
AoutGC = mult*As(:,:,referencenumber)/thickGC;
AerroutGC = mult*Aerrs(:,:,referencenumber)/thickGC;
%AW and when error of the normalization factor is concerned, this reads:
AerroutGC = sqrt((mult*Aerrs(:,:,referencenumber)).^2+(errmult*As(:,:,referencenumber)).^2)/thickGC;
write2dintfile(AoutGC,AerroutGC,header(referencenumber));

%AW also plotting ints(:,referencenumber) with a thin line
% HEY! intsbinGC was a 1D vector. How come it has referencenumber as its
%     SECOND index? What if reference was measured after all samples?
%plot(qbinGC(ll),intsbinGC(ll,referencenumber)*mult,'.',GCint(ll,1),GCint(ll,2),'o');
subplot(1,1,1);
plot(qsbinGC(ll),intsbinGC(ll)*mult,'.',...
    GCint(ll,1),GCint(ll,2),'o',...
    qs(:,referencenumber),mult*ints(:,referencenumber)/thickGC,'-');
xlabel(sprintf('q (1/%c)',197));
ylabel('Intensity (1/cm)');
%legend('Your reference','Calibrated reference')
legend(sprintf('Your reference\n(re-integrated)'),'Calibrated reference',sprintf('Your reference\n(data saved)'))
title(sprintf('Reference FSN %d multiplied by %.2e, error percentage %.2f\n',referencesfsn,mult,100*errmult/mult))
drawnow;
pause

% Normalise to 1/cm

counter = 1;
for(k = 1:sizeints(2))
  if(k ~= referencenumber)
    if(isstruct(thicknesses)) % If thicknesses are given in file       
      if(isfield(thicknesses,header(k).Title))
          thick = getfield(thicknesses,header(k).Title);
          disp(sprintf('Using thickness %f cm for sample %s',thick,header(k).Title));
          flagthick = 1; % Found thickness for this sample
      end;
    end;
    if(flagthick) % Make correction to absolute intensities if thickness was found.
%AW only normalization for sample thickness and absolute calibration with
%mult is performed, as the others were already done in B1integratepilatus.

% % Sample thickness -(10*thick/2) was taken into account in sample-to-detector distance
% % when calculating the q-scale, removed 27.11.2007:
% % 17.2.2009 q-scale starting from zero instead of 1.
%        [qout(:,counter),tthout(:,counter)] = qfrompixelsizeB1(distance(k),pixelsize,energyreal(k),[0:(length(ints)-1)]);
% % Geometrical correction
%        spatialcorr = geomcorrection(qout(:,counter),energyreal(k),distance(k)); % energyreal(counter) to energyreal(k) 12.11.2007
% % Angle dependent transmission correction, 2.1.2008 added gas absorption
% % correction
%       transmcorr = absorptionangledependent(tthout(:,counter),transm(k)).*gasabsorptioncorrectionpilatus(energyreal(k),qout(:,counter)); % transm(counter) to transm(k) on 12.11.2007
%       intout(:,counter) = mult*ints(:,k)/thick.*spatialcorr.*transmcorr;
%       errout(:,counter) = sqrt((mult*errs(:,k)).^2+(errmult*ints(:,k)).^2)/thick.*spatialcorr.*transmcorr;
       qout(:,counter) = qs(:,k);
       intout(:,counter) = mult*ints(:,k)/thick;
       errout(:,counter) = sqrt((mult*errs(:,k)).^2+(errmult*ints(:,k)).^2)/thick;
%AW Also normalize the 2D data.
       Aout(:,:,counter) = mult*As(:,:,k)/thick;
       Aerrout(:,:,counter) = mult*Aerrs(:,:,k)/thick;
%AW and when error of the normalization factor is concerned, this reads:
       Aerrout(:,:,counter) = sqrt((mult*Aerrs(:,:,k)).^2+(errmult*As(:,:,k)).^2)/thick;

       if((current(k)>currentGC) && (k > referencenumber))
            injectionGC = 'y';
       elseif((current(k)<currentGC) && (k < referencenumber))
            injectionGC == 'y'
       else
            injectionGC = 'n'; % (although not necessarily!)
       end;
       writelogfilepilatus(header(k),ori(:,k),thick,dclevel,...
                           header(k).EnergyCalibrated,...
                           header(k).Dist,mult,errmult,referencesfsn,thickGC,injectionGC,injectionEB(k),pixelsize);
       
       writeintfile(qout(:,counter),intout(:,counter),errout(:,counter),header(k));
       write2dintfile(Aout(:,:,counter),Aerrout(:,:,counter),header(k));
%%% 29.5.2009 Added myhen UV, mythendistance 133.8320, mythenpixelshift = 300.3417
%       [qmythen,tthmythen] = qfrompixelsizeB1(mythendistance-distminus,0.05,header(k).EnergyCalibrated,mythenpixelshift+[0:1279]);
       %removed ' from tthmythen AW 4.6.2009
%       mythennormint('waxs_',header(k).FSN,qmythen,tthmythen,'angle');
       counter = counter + 1;
       if(isstruct(thicknesses)) % If thicknesses are given in a structure
         flagthick = 0; % Resetting flag.
       end;
    else
         disp(sprintf('Did not find thickness for sample %s. Stopping.',getfield(header(k),'Title')))
         return;
    end;
  end;
end;