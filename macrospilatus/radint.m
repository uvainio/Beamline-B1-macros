function [q,Intensity,Error,Area]=radint(data,dataerr,energy,distance,res,bcx,bcy,mask,q);
% [q,Intensity,Error,Area]=radint(data,dataerr,energy,distance,res,bcx,bcy,mask,q);
%
% Calculates the radial average of the scattering image.
%
%
% INPUT:
%    data      : the scattering data, as an N-by-M matrix.
%    dataerr   : the error of the scattering matrix.
%    energy    : the beam energy, in eV-s.
%    distance  : the distance of the sample and the detector, in mm-s
%    res       : the size of one pixel in mm-s. If it is a scalar, it is
%		 taken for both xres and yres. But one is able to supply
%		 [xres,yres].
%    bcx,bcy   : the coordinates of the beam-center, in pixels, starting
%                from 1. bcx is the x coordinate (VERTICAL, in terms of the
%		 Octave/Matlab representation of the data), and bcy is the y
%		 coordinate (HORIZONTAL)
%    mask      : mask matrix, of the same size as data. All elements
%                of data, for which the corresponding element of mask
%                is nonzero, will be excluded.
%    q         : [OPTIONAL] if supplied, do averaging on this q-range.
%                If not given, the default q-scale will be used. 
%
% OUTPUT:
%    q       : q values
%    I       : intensity values
%    e       : errors of the intensity values
%    A	     : the area of the q-bins, in pixels.
%
% NOTE:
%    X direction corresponds to the rows of the matrix, Y to the columns.
%    Pixels are counted from (1,1):
%
%              Y
%    ----------------------->
%    1,1  1,2  1,3  ...  1,N  |
%    2,1  2,2  2,3  ...  2,N  |
%     .    .    .   .     .   | 
%     .    .    .    .    .   | X
%     .    .    .     .   .   |
%    M,1  M,2  M,3  ...  M,N  v
%
% Created: 6.2.2009 Andras Wacha (awacha at gmail dot com)
% Edited: 10.2.2009 AW (Now RES can be a vector of two)
% Edited: 5.6.2009 AW The script version is done.
% Edited: 6.7.2009 AW The script version is now working. If the mex file 
% has not been compiled to binary, a warning is issued (not an error)
% and the script is run with nsubdivx=nsubdivy=1.

HC=12398.419; % eV*A NIST 2006
warning(sprintf('Executing the script-version of radint! This can be MUCH slower\nthan the mex version. Please consider building radint2.c by:\n"mex -v -DRADINT radint2.c -output radint"\nif you want to use the mex version'));
if size(data)~=size(dataerr) || size(data)~=size(mask)
    error('Sizes of data, dataerr and mask should be equal.')
end
if length(res)==1
    res=[res, res];
end
if length(res)>2
    disp('res should be of length not larger than 2.')
end
M=size(data,1); % number of rows
N=size(data,2); % number of columns
% Creating D matrix which is the distance of the sub-pixels from the origin.
[Y,X]=meshgrid(1:size(data,2),1:size(data,1));
D=sqrt((res(1)*(X-bcx)).^2+(res(2)*(Y-bcy)).^2);
% Q-matrix is calculated from the D matrix
q1=4*pi*sin(0.5*atan(D/distance))*energy/HC;
imagesc(q1)
% Now vectorize everything. This allows us to do the masking by eliminating
% masked pixels.
datalin=data(:);
dataerrlin=dataerr(:);
masklin=mask(:);
qlin=q1(:);
% eliminating masked pixels
data=datalin(masklin==0);
dataerr=dataerrlin(masklin==0);
q1=qlin(masklin==0);
% if the q-scale was not supplied, create one.
if nargin<9
    disp('Creating q-scale...')
    qmin=min(q1); % the lowest non-masked q-value
    qmax=max(q1); % the highest non-masked q-value
    q=linspace(qmin,qmax,3*sqrt(M*M+N*N));
    disp('done')
end
% initialize the output vectors
Intensity=zeros(size(q));
Error=zeros(size(q));
Area=zeros(size(q));
%square the error
dataerr=dataerr.^2;
% set the bounds of the q-bins in qmin and qmax
qmin=[q(1),(q(1:end-1)+q(2:end))/2];
qmax=[(q(1:end-1)+q(2:end))/2,q(end)];
% go through every q-bin
for l =1:length(q)
    disp(sprintf('q: %f, qmin: %f, qmax: %f',q(l),qmin(l),qmax(l)))
    indices_1=(q1<=qmax(l));
    indices_2=(q1>qmin(l));
    indices=((q1<=qmax(l)) & (q1>qmin(l))); % the indices of the pixels which belong to this q-bin
    Intensity(l)=sum(data(indices)); % sum the intensities
    Error(l)=sum(dataerr(indices)); % sum the errors
    Area(l)=sum(indices); % collect the area
end
Intensity=Intensity./Area; % normalization by the area
Error=Error./Area ;
Error=sqrt(Error); % square root of the error
