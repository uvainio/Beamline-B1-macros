function [A,Aerr,param]=read2dintfilepilatus(fsn)
% function [A,Aerr,param]=read2dintfilepilatus(fsn)
%
% Read 2d scattering data and its error from file int2dnormFSN.mat. If it 
% is not possible, tries int2dnormFSN.dat and err2dnormFSN.dat. If those
% files also not exist, its gzipped and zipped versions are tried (if gzip
% and zip functionality is present in the current Matlab setup)
%
% Depends on macro readlogfilepilatus.m
% 
% Created: 26.4.2009 Andras Wacha (awacha at gmail dot com)
% Edited: 26.5.2009 AW added zip functionality
% Edited: 27.5.2009 AW modified for pilatus300k
% Edited: 28.5.2009 AW deletes unzipped files afterwards
% Edited: 2.6.2009 AW reads MAT files, if possible. If not, falls back to
% the original operation (tries uncompressed .dat file, .dat.gz, .dat.zip)
counter=1;
for i = 1:length(fsn);
   status=0; % status==1 means files are successfully loaded
   % first try to load a MAT file
   name = sprintf('int2dnorm%d.mat',fsn(i));
   if exist(name,'file')
       tmp=load(name);
       A(:,:,counter)=tmp.Intensity;
       Aerr(:,:,counter)=tmp.Error;
       status=1;
   else % if mat file does not exist, try ascii
       name = sprintf('int2dnorm%d.dat',fsn(i));
       nameerr = sprintf('err2dnorm%d.dat',fsn(i));
       tmp=loadascii_optionallyzipped(name);
       tmperr=loadascii_optionallyzipped(nameerr);
       if (~isempty(tmp) && ~isempty(tmperr)) % if both the intensity and the error matrix exists
           A(:,:,counter)=tmp;
           Aerr(:,:,counter)=tmperr;
           status=1;
       end
   end
   if nargout>2 && status==1 % if header was requested and files have been successfully loaded
       logfilename = sprintf('intnorm%d.log',fsn(i));
       param(counter)=readlogfilepilatus(logfilename);
   end
   if status==1
       counter=counter+1;
   end
end

function A=loadascii_optionallyzipped(name)
% load an ascii file, which is optionally zipped or gzipped.

A=[]; % if this remains empty, it means that the file was not loaded
if exist(name,'file') % if the file exists, load it
    A=load(name);
else % if the file does not exist, try gunzipping it.
    disp(sprintf('Could not read 2d data file %s.',name))
    if exist('gunzip')==2 % if gunzip functionality is available...
        if exist(sprintf('%s.gz',name),'file') %...and the file exists
            gunzip(sprintf('%s.gz',name))
            A=load(name);
            delete(name); 
            gunzipstatus='FOUNDFILE';
            disp(sprintf('But %s.gz was found and read.',name))
        else % if the .gz file does not exist
            disp(sprintf('Neither %s.gz.',name))
            gunzipstatus='NOFILE';
        end
    else % gunzip functionality is not available
        gunzipstatus='NOTAVAIL';
    end
    if isempty(A) % if the matrix is still not loaded, try zip.
        if exist('unzip')==2 % if zip functionality is available
            if exist(sprintf('%s.zip',name)) %...and the zip file exists
                unzip(sprintf('%s.zip',name))
                A=load(name);
                delete(name);
                zipstatus='FOUNDFILE';
                disp(sprintf('But %s.zip was found and read.',name))
            else % if the zip file does not exist
                disp(sprintf('Neither %s.zip.',name))
                zipstatus='NOFILE';
            end
        else % if zip functionality is unavailable
            zipstatus='NOTAVAIL';
        end
    end
end
