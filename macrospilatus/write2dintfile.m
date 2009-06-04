function write2dintfile(A,Aerr,header,savemode)

% function write2dintfile(A,Aerr,header,savemode)
%
% Save A and Aerr (2D scattering data and its error) to file(s) on disk.
%
% Inputs:
%       A : the 2D scattering data
%       Aerr : the error of the 2D scattering data
%       header : the parameters
%       savemode : how to save the data. Possible values:
%           'mat' or nothing: save the file as int2dnormFSN.mat (a Matlab
%           Mat file)
%           'ascii': save A to int2dnormFSN.dat and Aerr to err2dnormFSN.dat
%           'ascii.zip': like 'ascii' but zip afterwards
%           'ascii.gz': like 'ascii' but gzip afterwards
% Outputs:
%       files int2dnormFSN.* and err2dnormFSN.*, see the description of
%       input argument <savemode>
%
% based on writeintfile by Ulla Vainio
%
% Created: 26.4.2009 Andras Wacha (awacha at gmail dot com)
% Edited: 26.5.2009 AW added zip functionality.
% Edited: 2.6.2009 AW from now on, this script saves by default both A and 
% Aerr to int2dnorm%d.mat, unless savemode is defined.

if nargin<4
    savemode='mat';
end
savemode=upper(savemode);

if strcmp(savemode,'MAT')
    name=sprintf('int2dnorm%d.mat',header.FSN);
    Intensity=A;
    Error=Aerr;
    save(name,'-MAT','Intensity','Error');
elseif strncmp(savemode,'ASCII',5)
    name = sprintf('int2dnorm%d.dat',getfield(header,'FSN'));
    save(name,'-ascii','-double','-tabs','A');
    nameerr = sprintf('err2dnorm%d.dat',getfield(header,'FSN'));
    save(nameerr,'-ascii','-double','-tabs','Aerr');
end
if strcmp(savemode,'ASCII.ZIP')
    zip(sprintf('%s.zip',name),name,nameerr);
    delete(name)
    delete(nameerr)
    disp(sprintf('Saved both intensity and error matrices to %s.zip',name));
elseif strcmp(savemode,'ASCII.GZ')
    if exist('gzip')==2
        gzip(name)
        gzip(nameerr)
        delete(name)
        delete(nameerr)
        disp(sprintf('Saved %s.gz and %s.gz',name,nameerr));
    else
        disp(sprintf('Gzip does not exist, leaving files %s and %s uncompressed.',name,nameerr));
    end
elseif strcmp(savemode,'ASCII')
    disp(sprintf('Saved %s and %s (uncompressed)',name,nameerr))
end
