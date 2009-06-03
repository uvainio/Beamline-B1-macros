function [ints,errs,header,orig,injectionEB] = B1integratepilatus(fsn1,dclevel,sens,errorsens,mask,pri,orig,transm)

% [ints,errs,header,injectionEB] = B1integratepilatus(fsn1,dclevel,sens,errorsens,mask,pri)
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
% Edited 18.5.2009 UV, field Anode is now set to sum of image after bg correction and masking

maxpix = 750; % Vectors will be of this length to be sure that they fit
pixelsize = 0.172;
distancetoreference = 219;

if(nargin < 7)
  [Asub,errAsub,header,injectionEB,orig] = subtractbgpilatus(fsn1,dclevel,sens,errorsens,pri,mask);
else % Special case if theoretical transmission is used
  [Asub,errAsub,header,injectionEB,orig] = subtractbgpilatus(fsn1,dclevel,sens,errorsens,pri,mask,transm);
end;

sizeA = size(Asub);
if(numel(sizeA)==2) % If only one matrix
   sizeA(3) = 1;
end;

disp('Integrating data. Press Return after inspecting the image.')
ints = zeros(maxpix,sizeA(3));
errs = zeros(maxpix,sizeA(3));

for(l = 1:sizeA(3))
      % Polarization factor
%    if(strcmp(getfield(header(l),'Title'),'Reference_on_GC_holder_before_sample_sequence')|strcmp(getfield(header(l),'Title'),'Reference on GC holder after sample sequence'))
%      Apolcor = polarizationcorrectionpilatus(getfield(header(l),'Dist')-distancetoreference,pixelsize,orig(1,l));
%    else
%      Apolcor = polarizationcorrectionpilatus(getfield(header(l),'Dist'),pixelsize,orig(1,l));
%    end;
%    imagesc(Apolcor); colorbar; pause
%    temp = imageint(Asub(:,:,l).*Apolcor,orig(1,l),mask);
    temp = imageint(Asub(:,:,l),orig(:,l),1-mask);
    ints(1:length(temp),l) = temp;
    title(sprintf('FSN %d',getfield(header(l),'FSN')))
    %pause
    %[temp, NI] = imageint((errAsub(:,:,l).*Apolcor).^2,orig(:,l), mask); 
    [temp, NI] = imageint((errAsub(:,:,l)).^2,orig(:,l), 1-mask); 
    title(sprintf('Error matrix of FSN %d',getfield(header(l),'FSN')))
    errs(1:length(temp),l) = temp;
    % Error propagation
    j = find(NI>0); % Don't divide by zero
    % The next statement is actually
    % the same as sqrt(errorinpixel1^2 + errorinpixel2^2 + ...)/(number of pixels summed)
    % because in imageint the vector given out is always divided by NI once
    errs(j,l) = sqrt(errs(j,l)./NI(j));
end;
%for(k = 1:sizeA(3))
%    loglog([1:length(ints)],ints(:,k),'-','LineWidth',k*0.5); hold on;
%    errorbar([1:length(ints)],ints(:,k),errs(:,k),'.');
%end;
%hold off;
