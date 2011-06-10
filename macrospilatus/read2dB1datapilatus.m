function [A,header,notfound,name] = read2dB1datapilatus(filename,files,fileend)

% function [A,header,notfound] = read2dB1datapilatus(filename,files,fileend)
%
% filename  = beginning of the file, e.g. 'org_'
% files     = the files , e.g. [714:1:804] will open files with FSN
%             from 714 to 804
% fileend   = e.g. '.cbf'
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
% 13.7.2010 UV Added reading of cbf files

% NOTE! This macro neads macros:
% READHEADER.M

n1 = 487;
m1 = 619;

fid = fopen(sprintf('%s\\processing\\settings.txt',pwd()));
line1 = fgetl(fid);
fclose(fid);
if(strcmp('300k',line1))
    detectortype = 300;
elseif(strcmp('1M',line1) || strcmp('1m',string(line1)))
    detectortype = 1000;
end;
CopyToDir = sprintf('%s\\data1\\',pwd());
projectname = CopyToDir(18:(end-7));

nr = size(files);
% A = zeros(m1,n1,max(nr)); % Initialised to speed up reading.

counter = 1; counternf = 1; notfound = 0;
for(l = 1:max(nr))
   if(detectortype==1000)
       name = sprintf('Z:\\%s\\%s%05d%s',projectname,filename,files(l),fileend);
   elseif(detectortype == 300)
       name = fullfile(CopyToDir,sprintf('%s.%s',sprintf('%s%05d',filename,files(l),fileend)));       
   end;
    fid = fopen(name,'r');
    nameheader = sprintf('%s%05d.header',filename,files(l));
     if(fid ~= -1)
         fclose(fid); %AW 4.6.2009
         if(counter == 1) % Initialize matrix for speed up based on first image 13.7.2010 UV
            if(strcmp(fileend,'.tif'))
               A1 = imageread(name,'tif',[n1, m1]);  % Reading the matrix.
            else
               A1temp = cbfread(sprintf('%s',name));
               A1 = A1temp.data';
            end;
            sA1 = size(A1);
            A = zeros(sA1(1),sA1(2),max(nr));
            A(:,:,1) = A1;
            if(nargout>=2) % Read header only if it is requested.
              header(counter) = readheader(nameheader); % Read header data
            end;
         end;
         if(counter ~= 1)
            if(strcmp(fileend,'.tif'))            
               A(:,:,counter) = imageread(name,'tif',[n1, m1]);  % Reading the matrix.
            elseif(strcmp(fileend,'.cbf'))
               Atemp1 = cbfread(sprintf('%s',name));
               A(:,:,counter) = Atemp1.data';
            end;
            if(nargout>=2) % Read header only if it is requested.
              header(counter) = readheader(nameheader); % Read header data
            end;
         end;
         counter = counter + 1;
     else % File could not be opened:
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