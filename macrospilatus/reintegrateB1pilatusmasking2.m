function reintegrateB1pilatusmasking2(fsn,mask,sddistance,qrange,samplenames)
% function reintegrateB1pilatusmasking2(fsn,mask,sddistance,qrange,samplenames)
%
% Re-integrate 2d scattering patterns
%
% Inputs:
%        fsn: file sequence numbers (a matrix can be also supplied).
%           The files int2dnorm*.dat and err2dnorm*.dat, as well as
%           intnorm*.log should exist and be accessible.
%        mask: mask to be used for the integration. 0 means masked, nonzero
%           means nonmasked.
%        sddistance: sample-to-detector distance. Only measurements with
%           this distance are re-integrated. Giving more than one is
%           possible. Give empty to re-integrate measurements with every
%           distance.
%        qrange: a range of q values, onto which the integrated data should
%           fall. If omitted, a common q-range is created by taking the mask
%           into account. If a scalar is supplied, it is regarded as the
%           desired number of q-bins.
%        samplenames: the names of the samples to re-integrate. Either one
%           string or a cell array. Supply an empty cell {} to re-integrate
%           every sample.
%
%
% Notes:
%        1. This script also writes qs, ints, errs to intbinned*.dat files.
%        2. Automatic guessing of the q-range is done this way:
%              a) determine the q-range for each energy by taking the two
%                 unmasked pixels which are the nearest and the most far
%                 from the beam.
%              b) the automatic q-range will be the intersection of all
%                 these.
%  
%
% Created: 27.4.2009 Andras Wacha
% Edited: 20.5.2009 AW. save data to intbinned*.dat, do not overwrite intnorm*.dat
% Edited: 27.5.2009 AW modified for pilatus300k
% Edited: 27.5.2009 AW the 2d data are read one-by-one, when they are
% needed, not all together at the beginning.
% Edited: 27.5.2009 AW the q-range is generated from the mask. Also the
% meaning of qrange has changed.
% Edited: 5.6.2009 AW now radint is called with 1-MASK and NOT with MASK
% Edited: 24.5.2009 AW guessing the common q-range is done by taking the
%     mask into account. Giving a scalar value for the q-range now should
%     work.
% Edited: 27.9.2009 AW now it is capable to handle multiple samples
%     measured at multiple distances. The return values are removed!
% Edited: 29.10.2009 UV: first q-value is not saved anymore, because it is
%     not correct anyway
% Edited: 13.5.2010 AW: put in safety checks, so the program won't die if
%     no measurement is found from a given sample or a given distance.
% Edited: 16.7.2010 UV: Added masking of cosmic rays using median filter

hc = 2*pi*1973.269601; % from qfrompixelsizeB1

masklimit = 25;
fsn=fsn(:);

if nargin<3 % if sddistance was not supplied, set it to [], which activates
            % the "autodetect" mechanism.
    sddistance=[];
end

if nargin<4 %qrange was not supplied. 3 before, 4 after adding sddistance UV
    disp('Determining common q-range for given FSN range.');
    Nq=sqrt(size(mask,2)^2+size(mask,1)^2); % default number of auto-generated q-bins
    qrange=[]; %empty to signal that this should be generated.
elseif numel(qrange)==1 % if qrange was supplied and is a scalar
    Nq=qrange; % regard it as the preferred number of q-bins.
    qrange=[]; % empty it to signal that this should be generated.
else
    %qrange is given. Nq is its length\
    Nq=numel(qrange);
    qrange=qrange(:); %vectorize it. Who knows...
end;


if nargin<5 % if sample names were not supplied, set the list to an empty
            % cell array, which corresponds to "autodetection".
    samplenames={};
end;

if ~iscell(samplenames) % if only one was supplied, make a list of length=1
    samplenames={samplenames};
end


% Load all header files.
disp('Loading header files...');
counter=0;
for i=1:length(fsn)
    tmp=readlogfilepilatus(sprintf('intnorm%d.log',fsn(i)));
    if isstruct(tmp) % if loading was successful
% removed this check. This is now done at a different part of this script,
% see below. AW. 27.09.2009.
%        if(tmp.Dist == sddistance || sddistance<=0) % Added restriction that only one distance is loaded, UV 16.7.2009.
%                                                    % Added overriding default value sddistance<=0. Now one can omit sddistance. AW 27.9.2009.
           counter=counter+1;
           params(counter)=tmp;
%        end;
    end
end
disp('...done.');

% autodetect samplenames, if needed.
if isempty(samplenames)
    samplenames=unique({params.Title}); % find all the samplenames and treat them one-by-one
end

for si=1:length(samplenames) % treat each sample one-by-one
   disp(sprintf('Re-integrating sample %s\n',samplenames{si}))
   % select the parameters corresponding only to this sample. I prefix them
   % with 's'.
   sparams=params(strcmp({params.Title},samplenames{si}));
   if numel(sparams)<1
           disp(sprintf('No measurement exists for sample %s. Skipping this sample.',samplenames{si}))
           continue
   end
   % if needed, autodetect sample-to-detector distances. Note, that we do
   % not overwrite sddistance, because we will need its default value in
   % the next iteration of this loop.
   if isempty(sddistance) % no sample-to-detector distance was given
      sdist=unique([sparams.Dist]); % find all distances
   else
      sdist=sddistance; % fetch value to sdist from sddistance.
   end
   % now we have sdist as a vector.
   for dist=sdist %treat each distance separately
       disp(sprintf('Re-integrating measurements at %f distance for sample %s\n',dist,samplenames{si}));
       
       %select the param structures for this sample with this distance.
       sdparams=sparams([sparams.Dist]==dist);
       if numel(sdparams)<1 %skip to the next distance if no measurements exist at this distance
           disp(sprintf('No measurement exists for sample %s at distance %f. Skipping this distance.',samplenames{si},dist))
           continue
       end
       % if q-range is needed to be generated, do so.
       if isempty(qrange) % qrange is to be generated
           Nq=ceil(Nq); %who knows...
           energymin=min([sdparams.EnergyCalibrated]);
           energymax=max([sdparams.EnergyCalibrated]);
           % Create the D-matrix, which contains the distances of the pixels from
           % the beam center.
           x=sdparams(1).PixelSize*[1:size(mask,1)].'*ones(1,size(mask,2));
           y=sdparams(1).PixelSize*ones(size(mask,1),1)*[1:size(mask,2)];
           D=sqrt((x-sdparams(1).PixelSize*sdparams(1).BeamPosX).^2+(y-sdparams(1).PixelSize*sdparams(1).BeamPosY).^2);
           D=D(mask~=0); % select only the non-masked points
           rmin=min(D);
           rmax=max(D);
           qmin=4*pi*sin(0.5*atan(rmin/dist))*energymax/hc;
           qmax=4*pi*sin(0.5*atan(rmax/dist))*energymin/hc;
           sdqrange=linspace(qmin,qmax,Nq);
           disp(sprintf('Created q-range. Q_min=%f, q_max=%f, q_step=%f, Nq=%d',qmin,qmax,sdqrange(2)-sdqrange(1),Nq));
       else
           sdqrange=qrange; % take a copy of it.
       end
       %now we have the q-range in qrange.
       sdqrange=sdqrange(:); %vectorize it
       % Load all data and make median to find out cosmic rays
       disp('Loading 2d data for making a median filter for cosmic rays.');
       clear fA;
       clear fAerrs;
       fcounter = 1;
       for i = 1:numel(sdparams);
           disp(sprintf('Loading 2d data for FSN %d',sdparams(i).FSN));
           [As,Aerrs]=read2dintfilepilatus(sdparams(i).FSN);
           fA = As;
           fAerrs = Aerrs;
           fcounter = fcounter + 1;
                      mask2 = mask; % Let's not modify the original mask
%           mask2(find(abs(ratioA.*mask) > limitmask | ratioB >limitmask)) = 0;
           mask2(find(fA>masklimit)) = 0; % SPECIAL
           imagesc(fA.*mask2);colorbar;
           hold on
           % cover masked area with white (by Andras Wacha)
           white=ones(size(mask2,1),size(mask2,2),3);
           h=image(white);
           set(h,'AlphaData',(1-mask2)*0.70);
           hold off
           drawnow
           disp(sprintf('Re-integrating FSN %d (%s)',sdparams(i).FSN,sdparams(i).Title));
           [q1,I1,err1,area1]=radint(fA,...
                                     fAerrs,...
                                     sdparams(i).EnergyCalibrated,...
                                     sdparams(i).Dist,...
                                     sdparams(i).PixelSize,...
                                     sdparams(i).BeamPosX,...
                                     sdparams(i).BeamPosY,...
                                     1-mask2,sdqrange);
           name = sprintf('intbinned%d.dat',sdparams(i).FSN);
           fid = fopen(name,'w');
           if(fid > -1)
                 for(m = 2:length(q1)) % Don't save the first value because it's wrong, UV 29.10.2009
                   fprintf(fid,'%e %e %e\n',q1(m),I1(m),err1(m));
                 end;
                 fclose(fid);
                 disp(sprintf('Saved data to file %s',name));
           else
                 disp(sprintf('Unable to save data to file %s',name));
           end;
       end;
   end % for dist...
end % for samplename

