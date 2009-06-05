function [qs,ints,errs,areas,params]=reintegrateB1pilatus(fsn,mask,qrange)
% function [qs,ints,errs,areas,params]=reintegrateB1pilatus(fsn,mask,qrange)
%
% Re-integrate 2d scattering patterns
%
% Inputs:
%        fsn: file sequence numbers (a matrix can be also supplied).
%           The files int2dnorm*.dat and err2dnorm*.dat, as well as
%           intnorm*.log should exist and be accessible.
%        mask: mask to be used for the integration
%        qrange: a range of q values, onto which the integrated data should
%           fall. If omitted, a common q-range is created by taking the mask
%           into account. If a scalar is supplied, it is regarded as the
%           desired number of q-bins.
%
% Outputs:
%        qs: the q vectors in a matrix
%        ints: the intensities
%        errs: the errors
%        areas: the effective areas of q-bins in pixels.
%        params: the parameters from the logfile.
% 
% This script also writes qs, ints, errs to intbinned*.dat files.
%
% Created: 27.4.2009 Andras Wacha
% Edited: 20.5.2009 AW. save data to intbinned*.dat, do not overwrite intnorm*.dat
% Edited: 27.5.2009 AW modified for pilatus300k
% Edited: 27.5.2009 AW the 2d data are read one-by-one, when they are
% needed, not all together at the beginning.
% Edited: 27.5.2009 AW the q-range is generated from the mask. Also the
% meaning of qrange has changed.
% Edited: 5.6.2009 AW now radint is called with 1-MASK and NOT with MASK

hc = 2*pi*1973.269601; % from qfrompixelsizeB1

fsn=fsn(:);
disp('Loading header files...');
counter=0;
for i=1:length(fsn)
    tmp=readlogfilepilatus(sprintf('intnorm%d.log',fsn(i)));
    if isstruct(tmp)
        counter=counter+1;
        params(counter)=tmp;
    end
end
disp('...done.');

if nargin<3 %qrange was not supplied.
    disp('Determining common q-range for given FSN range.');
    Nq=sqrt(size(mask,2)^2+size(mask,1)^2); % default number of auto-generated q-bins
    qrange=[]; %empty to signal that this should be generated.
elseif numel(qrange)==1 % if qrange was supplied and is a scalar
    qrange=[]; % empty to signal that this should be generated.
end;

if isempty(qrange) % qrange is to be generated
    Nq=ceil(Nq); %who knows...
    refbefore=strcmp({params.Title},'Reference_on_GC_holder_before_sample_sequence');
    refafter=strcmp({params.Title},'Reference_on_GC_holder_after_sample_sequence');
    notreference=~refbefore & ~refafter; % this logical matrix can be used to index
                                         % params. Thus:
                                         % params(notreference) will be the
                                         % non-reference subset of params() 
    dists=[params(notreference).Dist]; % decide if we have measurements from multiple geometries
    dist=unique(dists);
    if length(dist)>1
        disp('STOPPING. Measurements with more distances are to be re-integrated.\nPlease give only one.');
        return;
    end;
    energymin=min([params.EnergyCalibrated]);
    energymax=max([params.EnergyCalibrated]);
    % Create the D-matrix, which contains the distances of the pixels from
    % the beam center.
    x=params(1).PixelSize*[1:size(mask,1)].'*ones(1,size(mask,2));
    y=params(1).PixelSize*ones(size(mask,1),1)*[1:size(mask,2)];
    D=sqrt((x-params(1).PixelSize*params(1).BeamPosX).^2+(y-params(1).PixelSize*params(1).BeamPosY).^2);
    D=D(:); % vectorize it so we can use one min() and one max() function
    rmin=min(D);
    rmax=max(D);
    qmin=4*pi*sin(0.5*atan(rmin/dist))*energymax/hc;
    qmax=4*pi*sin(0.5*atan(rmax/dist))*energymin/hc;
    qrange=linspace(qmin,qmax,Nq);
    disp(sprintf('Created q-range. Q_min=%f, q_max=%f, q_step=%f, Nq=%d',qmin,qmax,qrange(2)-qrange(1),Nq));
end
%now we have the q-range in qrange.
qrange=qrange(:); %vectorize it
qs=zeros(length(qrange),counter); %we create the empty matrices
ints=qs;
errs=qs;
areas=qs;
for i = 1:counter;
    disp(sprintf('Loading 2d data for FSN %d',params(i).FSN));
    [As,Aerrs]=read2dintfilepilatus(params(i).FSN);
    disp(sprintf('Re-integrating FSN %d (%s)',params(i).FSN,params(i).Title));
   [q1,I1,err1,area1]=radint(As,...
                             Aerrs,...
                             params(i).EnergyCalibrated,...
                             params(i).Dist,...
                             params(i).PixelSize,...
                             params(i).BeamPosX,...
                             params(i).BeamPosY,...
                             1-mask,qrange);
   qs(:,i)=q1(:);
   ints(:,i)=I1(:);
   errs(:,i)=err1(:);
   areas(:,i)=area1(:);
   name = sprintf('intbinned%d.dat',params(i).FSN);
   fid = fopen(name,'w');
   if(fid > -1)
         for(m = 1:size(qs,1))
           fprintf(fid,'%e %e %e\n',qs(m,i),ints(m,i),errs(m,i));
         end;
         fclose(fid);
         disp(sprintf('Saved data to file %s',name));
      else
         disp(sprintf('Unable to save data to file %s',name));
   end;

end
