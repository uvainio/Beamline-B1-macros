function plot2dmatrix(A,maxval,mask,header,qs,showqscale)
% function plot2dmatrix(A,maxval,mask,header,qs,showqscale)
%
% Plot a scattering matrix with optional features.
%
% Inputs:
%     A: the scattering matrix
%     maxval (optional): the maximum value to plot. Give nonfinite (Inf,
%        -Inf or NaN) to skip using this functionality.
%     mask (optional): mask matrix. Pixels where this is zero will be faded.
%     header (optional): header or param structure. Only the fields Title,
%        BeamPosX, BeamPosY, PixelSize, Dist, EnergyCalibrated and FSN are
%        used.
%     qs (optional): q values to draw white rings at. Give [] for no rings.
%     showqscale (optional): if 1, the q-scale is shown on the axes.
%
% Outputs:
%     none, just a plot.
%
% Created 24.09.2009 Andras Wacha (awacha at gmail dot com), ported from
%     Python ;-)

HC=12398.419; % eV*AAngstroem, NIST 2006

if nargin>1 && isfinite(maxval)
    disp(sprintf('Using maxval = %f\n',maxval));
    A(A>=maxval)=maxval;
end
z=A<=0; % logical matrix for nonpositive elements of A.
A(z)=min(min(A(A>0))); % just not to get errors when taking the logarithm
A=log(A);

% create safe default values
if nargin<3
    mask=ones(size(A));
end;
if nargin<4
    header=struct();
end;
if nargin<5
    qs=[];
end
if nargin<6
    showqscale=0;
end
% now we have safe default values for each input argument.

%if not enough information is given for q-calibrating the image...
if showqscale && ~(isfield(header,'BeamPosX') && isfield(header,'BeamPosY')...
                   && isfield(header,'PixelSize') && isfield(header,'Dist')...
                   && isfield(header,'EnergyCalibrated'))
    showqscale=0;
    warning('plot2dmatrix:showqscale','showqscale was true but some fields are missing from param structure');
end

% calculate the q-values for the corners of the detector
if showqscale
    xmin=(1-header.BeamPosX)*header.PixelSize;
    ymin=(1-header.BeamPosY)*header.PixelSize;
    xmax=(size(A,1)-header.BeamPosX)*header.PixelSize;
    ymax=(size(A,2)-header.BeamPosY)*header.PixelSize;
    qxmin=4*pi*sin(0.5*atan(xmin/header.Dist))*header.EnergyCalibrated/HC;
    qxmax=4*pi*sin(0.5*atan(xmax/header.Dist))*header.EnergyCalibrated/HC;
    qymin=4*pi*sin(0.5*atan(ymin/header.Dist))*header.EnergyCalibrated/HC;
    qymax=4*pi*sin(0.5*atan(ymax/header.Dist))*header.EnergyCalibrated/HC;
    Y=[qxmin,qxmax]; % X is horizontal for imagesc but denotes the row coordinate for us.
    X=[qymin,qymax];
    header.BeamPosX=0; % now these are in "q". Matlab passes parameters BY VALUE so this 
    header.BeamPosY=0; % won't change the original version of header. This is not the case in Python, by the way.
else % the default values for the corners, in pixels
    Y=[1,size(A,1)];
    X=[1,size(A,2)];
end
imagesc(X,Y,A);

hold on;
% plot black where the scattered intensity is nonpositive
black=zeros(size(A,1),size(A,2),3);
h=image(X,Y,black);
set(h,'AlphaData',z);
% cover masked area with white
white=ones(size(mask,1),size(mask,2),3);
h=image(X,Y,white);
set(h,'AlphaData',(1-mask)*0.70);
colorbar;

% if possible, display a title.
if isfield(header,'FSN') && isfield(header,'Title')
   title({sprintf('FSN %d (%s) Corrected, log scale',header.FSN,header.Title),...
           'Black: non-masked nonpositives; Faded: masked pixels'});
end

% if possible, draw a cross-hair at the beam center
if isfield(header,'BeamPosX') && isfield(header,'BeamPosY')
   plot(X,[header.BeamPosX header.BeamPosX],'w-');
   plot([header.BeamPosY header.BeamPosY],Y,'w-');
end

%axis labels if q-scaling
if showqscale
    xlabel(sprintf('q (1/%c)',197));
    ylabel(sprintf('q (1/%c)',197));
end

% if possible and wanted, draw q-rings
if isfield(header,'EnergyCalibrated') && isfield(header,'Dist') && isfield(header,'PixelSize')...
    && isfield(header,'BeamPosX') && isfield(header,'BeamPosY')
   for q=qs
       if ~showqscale
           r=tan(2*asin(q*HC/(4*pi*header.EnergyCalibrated)))*header.Dist/header.PixelSize;
       else
           r=q;
       end
       plot(header.BeamPosY+r*cos(linspace(0,2*pi,2000)),header.BeamPosX+r*sin(linspace(0,2*pi,2000)),'Color','white','Linewidth',1.5);
   end
end
%we are finished.
hold off;
