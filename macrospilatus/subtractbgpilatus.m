function [Asub,errAsub,header,injectionEB,orig] = subtractbgpilatus(fsn1,dclevel,sens,senserr,pri,mask,fluorcorr,origs)

% function [Asub,errAsub,header] = subtractbgpilatus(fsn1,dclevel,sens,senserr,pri,mask,fluorcorr,transm)
%
% Subtracts from the 2D SAXS measurement of the sample a dark current and
% the empty beam measurement and normalizes the measurement with
% transmission, monitor counts, with Sum/Total (the number of photons for
% which a position was determined compared to the number of photons detected on the
% anode of the detector) and by the sensitivity of the detector.
%
% IN:
% fsn1 = FSN(s) of the sample measurement(s), e.g. [256:500]
% fsndc = FSN(s) of dark current measurement(s)
% sens = sensitivity matrix of the detector (from makesensitivity.m)
% senserr = error of the sensitivity matrix (from makesensitivity.m)
% mask = only used to calculate the counts on the detector (without masking
% bad pixels would be included)
%
% OUT:
% Asub = normalised 2D data from which dark current and empty beam
%           backgrounds have been subtracted
% errAsub = error matrix of Asub
% header = headers of the sample files with dark current FSN added
%
% Created: 5.9.2007 UV
% Edited: 18.2.2009 Modified for PILATUS UV
% Edited 18.5.2009 UV, field Anode is now set to sum of image after bg correction and masking
% Edited 18.5.2009 UV, fixed origin
% Edited 28.6.2011 AW, fixed handling of default origin parameter

% Read in samples
[A1,header1] = read2dB1datapilatus('org_',fsn1,'.cbf');
sizeA1 = size(A1);
if(numel(sizeA1)<3)
    sizeA1(3) = 1; % To recover from only one FSN
end;

% Read in empty beam measurements
FSNempty = zeros(1,sizeA1(3));
for(k = 1:sizeA1(3))
   FSNempty(k) = getfield(header1(k),'FSNempty');
end;
notfound = 0;
noemptys = find(FSNempty~=0);

if(noemptys == 0)% In case background subtraction is not possible
    disp('No backround to subtract!')
    return;
end;

[Abg,headerbg,notfound] = read2dB1datapilatus('org_',FSNempty(noemptys),'.cbf');
sizebg = size(Abg);
if(numel(sizebg)<3)
    sizebg(3) = 1; % To recover from only one FSN
end;

% Checking all empty beam measurements are found
if(notfound(1)~=0) 
   disp(sprintf('Cannot find all empty beam measurements.\nWhere is the empty FSN %d belonging to FSN %d? Stopping.',notfound(1),fsn1(find(FSNEmpty==notfound(1)))))
   return
end;

% Subtracting dark current and normalising
counter = 1;
for(k = 1:sizeA1(3))
    if(nargin < 8) % 28.06.2011. AW. this was <9, but the function does not have that many arguments. 
        orig(:,k) = getorizoomed(A1(:,:,k),pri); % Determine the center of the beam
    else
        orig(:,k) = origs;
    end;
   header1(k).Anode = sum(sum(A1(:,:,k).*mask)); % Added 18.5.2009 UV

   if(FSNempty(k)~=0)
     if(counter ==1)
        [Abg(:,:,counter),Abgerr(:,:,counter)] = subdcpilatus(Abg(:,:,counter),headerbg(counter),1,sens,senserr,dclevel);
     elseif(getfield(headerbg(counter),'FSN')==getfield(headerbg(counter-1),'FSN'))
        Abg(:,:,counter) = Abg(:,:,counter-1); Abgerr(:,:,counter) = Abgerr(:,:,counter-1);
     end;
     %if(nargin < 9) % Normal case
        A1(:,:,k)=A1(:,:,k)-fluorcorr;
        [A2(:,:,counter),A2err(:,:,counter)] = subdcpilatus(A1(:,:,k),header1(k),1,sens,senserr,dclevel);
     %else % in case theoretical transmission is used, deactivated by Ulla Vainio 2.3.2011
     %   [A2(:,:,counter),A2err(:,:,counter)] = subdcpilatus(A1(:,:,k),header1(k),1,sens,senserr,dclevel,transm);
     %end;
     header2(counter) = header1(k);
     counter = counter + 1;
   end;
end;

clear A1

% Subtracting background from data
counter2 = 1;
sA2 = size(A2(:,:,1));
Asub = zeros(sA2(1),sA2(2),counter-1);
errAsub = Asub;
for(k = 1:(counter-1))
   % Checking first for an injection
    if(getfield(header2(k),'Current1')>getfield(headerbg(k),'Current2'))
      disp('Possibly an injection between sample and its background:')
      getsamplenamespilatus('org_',header2(k).FSN,'.header');
      getsamplenamespilatus('org_',header2(k).FSNempty,'.header',1);
      disp(sprintf('Current in DORIS at the end of empty beam measurement %.2f.\nCurrent in DORIS at the beginning of sample measurement %.2f',getfield(headerbg(k),'Current2'),getfield(header2(k),'Current1')))
      injectionEB(k) = 'y';
    else
        injectionEB(k) = 'n';
    end;
      Asub(:,:,counter2) = A2(:,:,k) - Abg(:,:,k);
      errAsub(:,:,counter2) = sqrt(A2err(:,:,k).^2 + Abgerr(:,:,k).^2);
      header(counter2) = header2(k);
      orig1(:,counter2) = orig(:,k); % Correct center is taken 18.5.2009 UV
      counter2 = counter2 + 1;
end;
orig = orig1;

clear Abg
clear Abgerr
clear A2
clear A2err
