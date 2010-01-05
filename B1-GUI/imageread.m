% IMAGEREAD - Reads an image (img, tif or tiff, ff, edf)
%
%   [Im, <header>] = imageread(filename, format, dim, <colorDepth>)
%
%   Im         : Image matrix of dimension dim as read from file.
%   header     : Header data for edf and tif formats, returned as a string
%                array.
%   filename   : Filename (+ path (absolute or relative)) of the file to
%                to be read as string
%   format     : 'img'  - binaries of the .img format
%                'tif'  - tif format with extension .tif
%                'tiff' - tif format with extension .tiff
%                'ff'   - tvx flatfield tif format (= float tif)
%                         with extension .tif
%                'edf'  - edf: ESRF data format as .edf 
%   dim        : Matrix dimension as vector, e.g. dim = [xdim, ydim]
%   colorDepth : Color-depth of the .img file in number of bits
%                (default is 32 bit for PILATUS 2 images)
%                Values can be 8, 16, 32, or 64 for integer arrays
%                (e.g. 16 for a 16 bit PILATUS 1 image),
%                or use -1 if you want to load floating points of format
%                'double', e.g. if you want to load an image that is
%                already flatfield corrected.
%
%  <argument> depicts an optional argument.

%==========================================================================
%
% FUNCTION: imageread.m
%           ===========
%
% $Date: 2006/12/11 12:46:46 $
% $Author: herger $
% $Revision: 1.10 $
% $Source: /import/cvs/X/PILATUS/App/lib/X_PILATUS_Matlab/imageread.m,v $
% $Tag: $
%
%
% <IMAGEREAD> - Reads an image (img, tif or tiff, ff)
%
% Author(s):            R. Herger (RH)
% Co-author(s):         C.M. Schlepuetz (CS)
%                       S.A. Pauli (SP)
% Address:              Surface Diffraction Station
%                       Materials Science Beamline X04SA
%                       Swiss Light Source (SLS)
%                       Paul Scherrer Institut
%                       CH - 5232 Villigen PSI
% Created:              2005/06/23
%
% Change Log:
% -----------
%
% 2005/07/05 (RH):
% - output argument no longer optional
%
% 2005/11/07 (CS):
% - set default color depth for .img files to 32 bit, added optional
%   argument 'colorDepth' to read also images with different color depths.
%
% 2006/02/17 (SP):
% - 32bit tif files are readable as well now.
%
% 2006/02/20 (RH):
% - changed the colorDepth to unsigned integers.
% - imageread can also handle data of type double.
%
% 2006/10/17 (RH):
% - edf format can now also be read.
% - header for tif and edf are now returned as string array.
% - compatible for extensions .tif or .tiff
%
% 2006/11/30 (CS):
% - included error check whether the number of elements read from file are
%   equal to the number of elements requested (=prod(dim)).
%
% 2006/12/11 (RH)
% - added cvs tag information for first release

%==========================================================================
%  Main function - <imageread>
%                  ===========

function [Im, header] = imageread(filename, format, dim, colorDepth)

%----------------------
% check input arguments

% are there 3 input arguments?
error(nargchk(3, 4, nargin))

% is filename of type string?
if(~ischar(filename))
    error(strcat('Invalid input for ''filename'' in function imageread.\n', ...
        'Use ''help imageread'' for further information.'), ...
        '');
end

% is format img, tif, tiff, ff or edf?

if ((strcmpi(format,'img') | strcmpi(format,'tif') | ...
        strcmpi(format,'tiff') | strcmpi(format,'ff') | ...
        strcmpi(format,'edf')) ~= 1)
    error(strcat('Invalid input for ''format'' in function imageread.\n', ...
        'Use ''help imageread'' for further information.'), ...
        '');
end

% is dim a vector of size [1 2]?
if (~isequal(size(dim), [1 2]))
    error(strcat('Invalid input for ''dim'' in function imageread.\n', ...
        'Use ''help imageread'' for further information.'), ...
        '');
end

% is colorDepth equal to 8, 16, 32, or 64?
if (nargin < 4)
    colorDepth = 32;
end;
if (colorDepth ~= 8 && colorDepth ~= 16 && ...
        colorDepth ~= 32 && colorDepth ~= 64 && ...
        colorDepth ~= -1)
    error(strcat('Invalid input for ''colorDepth'' in function imageread.', ...
        '\nUse ''help imageread'' for further information.'), ...
        '');
end;

if (colorDepth == -1)
    colorDepthFormat = 'double';
else
    switch colorDepth
        case 8
            colorDepthFormat = 'uint8';
        case 16
            colorDepthFormat = 'uint16';
        case 32
            colorDepthFormat = 'uint32';
        case 64
            colorDepthFormat = 'uint64';
    end
end

%----------------------
% check output argument

% is 1 output argument specified?
error(nargoutchk(1, 2, nargout))

%-----------
% read image

% initialize length of headers
% Note that the ESRF data format (EDF) header has been arbitrarily
% set to 1024 bytes since this is the most common implementation
% at the ESRF. Nevertheless, the EDF data format can store more than
% one header (and therefore more than one image) of n*512 bytes in
% one file.
% The description of the EDF can be found at:
% http://www.esrf.fr/computing/expg/subgroups/general/format/Format.html
edfheaderlength = 1024;
tifheaderlength = 4096;

% prepare filename without extension
[pathstr, fname] = fileparts(filename);

switch lower(format)

    % read img
    case 'img'
        filename = fullfile(pathstr, strcat(fname, '.img'));
        % check if file exists
        if(exist(filename, 'file') == 0);
            eid = sprintf('File:%s:DoesNotExist',  filename);
            error(eid, 'File %s does not exist!', filename);
        end;
        % open and read the file
        [ifImg] = fopen (filename);
        % there is no header in the case of img
        header = [];
        % read the data
        [data, ncount] = fread (ifImg, inf, colorDepthFormat);
        fclose (ifImg);

    % read tif or tiff
    case {'tif', 'tiff'}
        filenames = fullfile(pathstr, strcat(fname, '.tif'));
        filenamel = fullfile(pathstr, strcat(fname, '.tiff'));
        % check if file exists
        if ((exist(filenames, 'file') == 0) && ...
            (exist(filenamel, 'file') == 0));
                eid = sprintf('File:%s:DoesNotExist',  filename);
                error(eid, 'File %s does not exist!', filename);
        elseif (exist(filenames, 'file') == 2)
            filename = filenames;
        else
            filename = filenamel;
        end
        % open and read the file, convert to double
        [ifTif]=fopen(filename);
        % read the header and convert to a string
        [header]=char(fread(ifTif, tifheaderlength)');
        % read the data
        [data, ncount] = fread (ifTif, inf, colorDepthFormat);
        fclose(ifTif);

    % read ff tif
    case 'ff'
        filename = fullfile(pathstr, strcat(fname, '.tif'));
        % check if file exists
        if(exist(filename, 'file') == 0);
            eid = sprintf('File:%s:DoesNotExist',  filename);
            error(eid, 'File %s does not exist!', filename);
        end;
        [ifFf]=fopen(filename);
        % read the header and convert to a string
        [header]=char(fread(ifFf, tifheaderlength)');
        % read the data
        [data,ncount]=fread(ifFf, inf, 'float32');
        fclose(ifFf);

    % read edf
    case 'edf'
        filename = fullfile(pathstr, strcat(fname, '.edf'));
        % check if file exists
        if(exist(filename, 'file') == 0);
            eid = sprintf('File:%s:DoesNotExist',  filename);
            error(eid, 'File %s does not exist!', filename);
        end;
        % open and read the file, convert to double
        [ifEdf]=fopen(filename);
        % read the header and convert to a string
        [header]=char(fread(ifEdf, edfheaderlength)');
        % read the data
        [data,ncount]=fread(ifEdf, inf, colorDepthFormat);
        fclose(ifEdf);
end

% check if number of retrieved elements agrees with requested image
% dimensions:
if (prod(dim) ~= ncount)
    eid = sprintf('ImageRead:%s:WrongNumberOfElementsInFile',mfilename);
    error(eid,'%s\n%s',...
        'The number of elements found in the data file does not agree ',...
        'with the number of requested elements given by dim');
else
   Im = reshape(data,dim(1),dim(2));
   Im = Im';
end


%==========================================================================
%
%---------------------------------------------------%
% emacs setup:  force text mode to get no help with %
%               indentation and force use of spaces %
%               when tabbing.                       %
% Local Variables:                                  %
% mode:text                                         %
% indent-tabs-mode:nil                              %
% End:                                              %
%---------------------------------------------------%
%
% $Log: imageread.m,v $
% Revision 1.10  2006/12/11 12:46:46  herger
% cvs tag information added
%
% Revision 1.9  2006/11/30 13:57:57  pauli_s
% Remove unneeded files
%
% Revision 1.8  2006/10/17 12:56:29  herger
% reads also edf and returns the header for edf and tif
%
% Revision 1.7  2006/02/20 16:45:51  herger
% now also double data can be read
%
% Revision 1.6  2006/02/20 14:05:38  herger
% changed colorDepth to unsigned integers
%
% Revision 1.5  2006/02/17 13:28:13  pauli_s
% 32bit .tif files are also readable
%
% Revision 1.4  2005/11/08 17:12:46  herger
% output of tif file as double (no longer int)
%
% Revision 1.3  2005/11/07 16:00:02  schlepuetz
% set default color depth for .img files to 32 bit, added optional argument 'colorDepth' to read also images with different color depths.
%
% Revision 1.2  2005/09/29 12:02:23  herger
% new directory
%
% Revision 1.1  2005/06/29 14:49:08  herger
% matlab function to read an image (img, tif or tiff, ff)
%
%
%================================= End of $RCSfile: imageread.m,v $ ====