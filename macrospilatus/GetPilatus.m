function [A,header] = GetPilatus(mask,syntaxbegin,fsqn,maxval)
%GETPILATUS plot the images from the pilatus. If the 
%           images is not on this PC it tries to copy them from the pilatus
%           PC to this on. The programm uses pscp (it is the windows clone
%           of the scp unix command.) 
%
% parameters:
%   syntaxbegin = 'org_' for example
%   fsqn = list of file numbers
%
% returns: 
%      A = the image matrix into the directory WHERE YOU ARE (pwd)
%
% reversion: 0.1.0  $2008-12-19$ by Sylvio Haas
% Edited: $2009-3-11$ by Ulla Vainio, changed to download Pilatus 300k data
%                      and added header download

%syntax = 'org_%05d';
%syntax = 'image_%05d';

CopyToDir = sprintf('%s\\data1\\',pwd());
CopyFromDir = sprintf('%s\\data1\\',pwd());

fid = fopen('d:\dontremovethisfile.mat','r');
if(fid==-1)
    disp('Cannot download data to any other computer than the analysis computer at B1!');
    return;
end;
fclose(fid);
load d:\dontremovethisfile.mat

WinScp = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',pilatus);
WinScp2 = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',online);

jet2 = jet(256);
jet2(1,:)=0;

for i=1:length(fsqn)
   fid = fopen(fullfile(CopyToDir,sprintf('%s.tif',sprintf('%s%05d',syntaxbegin,fsqn(i)))),'r'); 
   if fid==-1
      cmd = sprintf('%s det@haspp03pilatus:/home/det/p2_det/images/%s.tif %s%s.tif',WinScp, ...
               sprintf('%s%05d',syntaxbegin,fsqn(i)),CopyToDir,sprintf('%s%05d',syntaxbegin,fsqn(i)));
      dos(cmd);
   else
      fclose(fid);
   end

   if(nargout == 2)
      fid = fopen(fullfile(CopyToDir,sprintf('%s.header',sprintf('%s%05d',syntaxbegin,fsqn(i)))),'r'); 
      if fid==-1
         cmd = sprintf('%s b1user@hasb1:%s%s.header %s%s.header',WinScp2, ...
                 CopyFromDir,sprintf('%s%05d',syntaxbegin,fsqn(i)),CopyToDir,sprintf('%s%05d',syntaxbegin,fsqn(i)));
         dos(cmd);
      else
       fclose(fid);
      end
      header = readheader(sprintf('%s%.header',sprintf('%s%05d',syntaxbegin,fsqn(i))));
   end;
   A = imageread(fullfile(CopyToDir,sprintf('%s%05d',syntaxbegin,fsqn(i))),'tif',[487, 619]);
   %disp(sprintf('Total %d, maximum %d counts',sum(sum(A.*mask)),max(max(A.*mask))));
   imagesc(log(min(A,maxval)+1));
   title(regexprep(sprintf('%s%05d',syntaxbegin,fsqn(i)),'[_]','\\_'));
   axis equal
   axis image
   colormap(jet2);
   colorbar;
   drawnow
end