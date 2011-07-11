function [qs,ints,errs,Areas,As,Aerrs,header,orig,injectionEB] = B1integratepilatus(fsn1,dclevel,sens,errorsens,mask,pri,energymeas,energycalib,distminus,detshift,fluorcorr,orig,transm)

% [ints,errs,header,injectionEB] = B1integratepilatus(fsn1,dclevel,sens,errorsens,mask,distminus,detshift,pri)
% 
%
% injectionEB is 'y' if injection was between sample measurement and
%           empty beam measurement, otherwise it is 'n'
% injectionGC is 'y' if injection was between sample and glassy carbon
%           measurement, otherwise it is 'n'
%
% Created: 10.9.2007 UV
% Edited: 17.9.2007 UV Bug in error calculations for others than the first
% file.
% Edited: 27.11.2007 UV Changed naming system in titles, space replaced by "_"
% Edited: 18.2.2009 UV Modified to suit PILATUS 300k
% Edited: 8.5.2009 AW Modified for new integration routines.
% Edited 18.5.2009 UV, field Anode is now set to sum of image after bg correction and masking
% Edited 26.5.2009 AW The default q-range is calculated here, not in
% radint. Also an error was corrected in the calculation of the D-matrix.
% Edited 5.6.2009 AW radint is now called NOT with MASK, BUT 1-MASK!
% Edited 21.7.2009 AW the last edit was not performed correctly and upon
% determining the q-scale, some q-bins with 0 effective area were taken into
% account among the normal q-bins.
% Edited 29.6.2011 AW Updated mechanism for default transmission and origin
% parameters.

%AW parameter "orig" is not used anywhere!


% This is not needed anymore. AW
%maxpix = 750; % Vectors will be of this length to be sure that they fit
pixelsize = 0.172; % It is not used for q-range calibration, only for polarization correction
distancetoreference = 219;
HC=12398.419; %Planck's constant times speed of light, eV*Angstroems, NIST 2006

%29.6.2011. AW the next whole if clause was updated to work well with
%optional parameters.
if(nargin < 12) %AW 7->11 as new input arguments were added.
  [Asub,errAsub,header,injectionEB,orig] = subtractbgpilatus(fsn1,dclevel,sens,errorsens,pri,mask,fluorcorr);
elseif (nargin<13) % Special case if origin is used
  [Asub,errAsub,header,injectionEB,orig] = subtractbgpilatus(fsn1,dclevel,sens,errorsens,pri,mask,fluorcorr,orig);
else % Special case if origin and transmission are used
  [Asub,errAsub,header,injectionEB,orig] = subtractbgpilatus(fsn1,dclevel,sens,errorsens,pri,mask,fluorcorr,orig,transm);
end;
%AW we do not need this, as we will use size(A,3) instead of sizeA(3).
%sizeA = size(Asub);
%if(numel(sizeA)==2) % If only one matrix
%   sizeA(3) = 1;
%end;

% We now do the energy calibration, which was done in B1normint1pilatus in
% the former times.
disp('B1integratepilatus: Doing energy calibration and correction for reference distance');
for k=1:size(Asub,3)
    if(strcmp(header(k).Title,'Reference_on_GC_holder_before_sample_sequence'))
        header(k).Dist=header(k).Dist-distancetoreference-detshift;
        disp(sprintf('Corrected sample-detector distance for fsn %d (ref. before).',header(k).FSN))
    elseif(strcmp(header(k).Title,'Reference_on_GC_holder_after_sample_sequence'))
        header(k).Dist=header(k).Dist-distancetoreference-detshift;
        disp(sprintf('Corrected sample-detector distance for fsn %d (ref. after).',header(k).FSN))
    else
        header(k).Dist=header(k).Dist-distminus-detshift;
    end;
    energyreal(k)=energycalibration(energymeas,energycalib,header(k).Energy);
    header(k).EnergyCalibrated=energyreal(k); %save it into the header structure as well
    disp(sprintf('Calibrated energy for FSN %d (%s): %f -> %f',header(k).FSN,header(k).Title,header(k).Energy,header(k).EnergyCalibrated));
end

disp('Integrating data. Press Return after inspecting the image.')
%ints = zeros(maxpix,sizeA(3));
%errs = zeros(maxpix,sizeA(3));

for(l = 1:size(Asub,3))
      % Polarization factor
%    if(strcmp(getfield(header(l),'Title'),'Reference_on_GC_holder_before_sample_sequence')|strcmp(getfield(header(l),'Title'),'Reference on GC holder after sample sequence'))
%      Apolcor = polarizationcorrectionpilatus(getfield(header(l),'Dist')-distancetoreference,pixelsize,orig(1,l));
%    else
%      Apolcor = polarizationcorrectionpilatus(getfield(header(l),'Dist'),pixelsize,orig(1,l));
%    end;
%    imagesc(Apolcor); colorbar; pause
%    temp = imageint(Asub(:,:,l).*Apolcor,orig(1,l),mask);
%AW tried to add polarization correction. Skipped this task for the future.
%    Apolcor = polarizationcorrectionpilatus(getfield(header(l),'Dist'),pixelsize,orig(1,l));
%    disp(size(Apolcor))
%    disp(size(Asub))
%    As(:,:,l)=Asub(:,:,l).*Apolcor;
%    Aerrs(:,:,l)=errAsub(:,:,l).*Apolcor;
    As(:,:,l)=Asub(:,:,l);
    Aerrs(:,:,l)=errAsub(:,:,l);
    %AW Do the corrections for angle-dependent absorption and detector
    %flatness, which were formerly done by B1normint1. We need to carry out
    %these here to have the corrected 2D scattering patterns.
    
    % To accomplish this, we produce a D matrix. Each element corresponds
    % to the distance of that pixel from the origin.
    tic;
    x=pixelsize*[1:size(As,1)].'*ones(1,size(As,2));
    y=pixelsize*ones(size(As,1),1)*[1:size(As,2)];
    D=sqrt((x-pixelsize*orig(1,l)).^2+(y-pixelsize*orig(2,l)).^2);
    tmp=toc;
    disp(sprintf('Generating matrix D took %f seconds',tmp));
    
    %disp('Testing: imagesc(D)');
    %imagesc(D);
    %pause;
    % From this D, we get the theta matrix, which we need to supply to
    % correction functions:
    tth=atan(D/header(l).Dist); % this is 2*theta, not simply theta! in radians
    spatialcorr=geomcorrectiontheta(tth,header(l).Dist);
    absanglecorr=absorptionangledependenttth(tth,header(l).Transm);
    gasabsorptioncorr=gasabsorptioncorrectionpilatustheta(header(l).EnergyCalibrated,tth);
    % Carry out all the corrections on the 2D intensities and errors as
    % well.
    As(:,:,l)=As(:,:,l).*spatialcorr.*absanglecorr.*gasabsorptioncorr;
    
    Aerrs(:,:,l)=Aerrs(:,:,l).*spatialcorr.*absanglecorr.*gasabsorptioncorr;
    
    % now plot the corrected data.
    subplot(111); % reset the graph.
    %removing nonpositive elements from the matrix to be plotted. This
    %is needed for log-plotting to be done correctly.
    tmp=As(:,:,l);
    tmp(tmp<=0)=min(tmp(tmp(:)>0));
    imagesc(log(tmp));
    hold on;
    % plot black where the scattered intensity is nonpositive
    black=zeros(size(tmp,1),size(tmp,2),3);
    h=image(black);
    set(h,'AlphaData',As(:,:,l)<=0);
    % cover masked area with white
    white=ones(size(mask,1),size(mask,2),3);
    h=image(white);
    set(h,'AlphaData',(1-mask)*0.70);
    colorbar;
    title({sprintf('FSN %d (%s) Corrected, log scale',header(l).FSN,header(l).Title),...
        'Black: non-masked nonpositives; Faded: masked pixels'});
    plot([1 size(As(:,:,l),2)],[orig(1,l) orig(1,l)],'w-');
    plot([orig(2,l) orig(2,l)],[1 size(As(:,:,l),1)],'w-');
    hold off;
    drawnow;
    % Now the scattering matrix and the error matrix have been corrected
    % for geometry, angle dependent transmission and gas absorption.

    % 26.5.2009 AW. Calculate the q-range here, not in radint.
    % 21.7.2009 SE. mask==0 -> mask~=0 because of edit AW 5.6.2009.
    dmin=min(min(D(mask~=0))); % the point which is nearest to the origin among the nonmasked points.
    dmax=max(max(D(mask~=0)));
    qmin=4*pi*sin(0.5*atan(dmin/header(l).Dist))*header(l).EnergyCalibrated/HC;
    qmax=4*pi*sin(0.5*atan(dmax/header(l).Dist))*header(l).EnergyCalibrated/HC;
    qrange=linspace(qmin,qmax,0.5*min(size(As(:,:,l))));
    
    % Added by AW. Radial integration.
    disp('Now integrating...');
    tic;
    %AW 5.6.2009 Changed mask -> 1-mask!
    [qs1,ints1,errs1,Areas1]=radint3(As(:,:,l),...
                                 Aerrs(:,:,l),...
                                 header(l).EnergyCalibrated,...
                                 header(l).Dist,...
                                 pixelsize,...
                                 orig(1,l),...
                                 orig(2,l),...
                                 1-mask,qrange);
    tmp=toc;
    disp(sprintf('...done. Integration took %f seconds.',tmp));
    %[qs1,ints1,errs1,Areas1]=sanitizeintegrated(qs1,ints1,errs1,Areas1);
    qs(:,l)=qs1;
    ints(:,l)=ints1;
    errs(:,l)=errs1;
    Areas(:,l)=Areas1;
    hold off;
    
    pause %we put pause here, so while the user checks the 2d data, the integration is carried out.
    subplot(121);
    cla;
    errorbar(qs(:,l),ints(:,l),errs(:,l));
    %set(gca,'xscale','log','yscale','log');
    axis tight;
    % end of Added by AW
    % commented by AW
    %    temp = imageint(Asub(:,:,l),orig(:,l),1-mask);
    %    ints(1:length(temp),l) = temp;
    ylabel('Intensity (arb. units)');
    xlabel(sprintf('q (1/%c)',197));
    title(sprintf('FSN %d ',getfield(header(l),'FSN')));
    hold off;
    % added by AW
    subplot(122);
    plot(qs(:,l),Areas(:,l));
    ylabel('Effective area (pixels)');
    xlabel(sprintf('q (1/%c)',197));
    title(sprintf('%s',header(l).Title));
    hold off;
    drawnow;
    pause
    % end of AW.
% commented by AW. This part did the error propagation before. Now it is
% done by the integration routines.
%    %pause
%    %[temp, NI] = imageint((errAsub(:,:,l).*Apolcor).^2,orig(:,l), mask); 
%    [temp, NI] = imageint((errAsub(:,:,l)).^2,orig(:,l), 1-mask); 
%    title(sprintf('Error matrix of FSN %d',getfield(header(l),'FSN')))
%    errs(1:length(temp),l) = temp;
%    % Error propagation
%    j = find(NI>0); % Don't divide by zero
%    % The next statement is actually
%    % the same as sqrt(errorinpixel1^2 + errorinpixel2^2 + ...)/(number of pixels summed)
%    % because in imageint the vector given out is always divided by NI once
%    errs(j,l) = sqrt(errs(j,l)./NI(j));
end;
%for(k = 1:sizeA(3))
%    loglog([1:length(ints)],ints(:,k),'-','LineWidth',k*0.5); hold on;
%    errorbar([1:length(ints)],ints(:,k),errs(:,k),'.');
%end;
%hold off;
