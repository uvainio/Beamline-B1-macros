function [A,header,notfound,name] = read2dB1datapilatus(filename,files,fileend)

% function [A,header,notfound] = read2dB1datapilatus(filename,files,fileend)
%
% filename  = beginning of the file, e.g. 'org_'
% files     = the files , e.g. [714:1:804] will open files from with FSN
%             from 714 to 804
% fileend   = e.g. '.dat'
%
% A = data matrix (total number of counts measured for each pixel)
% header = header data of the data in the file, see readheader.m
%           for more detail on units etc.
% notfound = FSNs that were not opened because files were not found
%
% Created: 27.4.2004 in Hamburg - U. Vainio, e-mail: ulla.vainio@gmail.com
% Edited:
% 18.7.2007 Fine adjustments, comments. -UV
% 9.8.2007 Header data is read separately into structure with macro READHEADER.m -UV
% 18.2.2009 Modified to work for pilatus.
% 30.3.2009 UV Cleaned up the reading procedure, for pilatus 300k
% 4.6.2009 AW Moved fclose(fid) to the line just before imageread(), thus
% the file is not opened twice at the same time, which caused an error in
% Matlab 7.0

% NOTE! This macro neads macros:
% READHEADER.M

n1 = 487;
m1 = 619;

nr = size(files);
A = zeros(m1,n1,max(nr)); % Initialised to speed up reading.

counter = 1; counternf = 1; notfound = 0;
for(l = 1:max(nr))
    name = sprintf('%s%05d%s',filename,files(l),fileend);
    fid = fopen(name,'r');
    nameheader = sprintf('%s%05d.header',filename,files(l));
     if(fid ~= -1)
         fclose(fid) %AW 4.6.2009
         A(:,:,counter) = imageread(name,'tif',[n1, m1]);  % Reading the matrix.
         if(nargout>=2) % Read header only if it is requested.
           header(counter) = readheader(nameheader); % Read header data
         end;
         counter = counter + 1;
         %fclose(fid); %AW 4.6.2009
     end;

     if(fid == -1) % File could not be opened:
         notfound(counternf) = files(l);
         counternf = counternf + 1;
         disp(sprintf('Skipping FSN %d. Check filename and path.\n',files(l)))
     end;
end;

if((counter-1) < max(nr)) % Removing the zero matrices left out from initialization
    B = A(:,:,1:(counter-1));
    clear A;
    A = B;
end;