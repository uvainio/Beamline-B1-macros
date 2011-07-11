function [A,header] = GetPilatus(projectname,syntaxbegin,fsqn,maxval)
%GETPILATUS plot the images from the pilatus. If the 
%           images is not on this PC it tries to copy them from the pilatus
%           PC to this on. The programm uses pscp (it is the windows clone
%           of the scp unix command.) 
% [A,header] = GetPilatus(projectname,syntaxbegin,fsqn,maxval)
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
% Edited $2010-7-15$ by Ulla Vainio, edited to download only cbf data,
% project name added as default. Data is saved directly in Pilatus computer
% into the right directory.

%syntax = 'org_%05d';
%syntax = 'image_%05d';

CopyToDir = sprintf('%s\\data1\\',pwd());
nowdate = date();
CopyFromDir = sprintf('/home/b1user/data/%s/%s/',nowdate(8:end),projectname);

fid = fopen(sprintf('%s\\processing\\settings.txt',pwd()));
line1 = fgetl(fid);
fclose(fid);
if(strcmp('300k',line1))
    detectortype = 300;
elseif(strcmp('1M',line1) || strcmp('1m',line1))
    detectortype = 1000;
end;

jet2 = jet(256);
jet2(1,:)=0;

flagfirsttime = 0;
for i=1:length(fsqn)
  if(detectortype == 300)

   fid = fopen(fullfile(CopyToDir,sprintf('%s.cbf',sprintf('%s%05d',syntaxbegin,fsqn(i)))),'r'); 
   if fid==-1
      if(flagfirsttime == 0)
          fid2 = fopen('d:\dontremovethisfile.mat','r');
          if(fid2==-1)
            disp('Cannot download data to any other computer than the analysis computer at B1!');
            return;
         end;
         fclose(fid2);
         load d:\dontremovethisfile.mat
         WinScp = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',pilatus);
         WinScp2 = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',online);
         flagfirsttime = 1;
      end;
          cmd = sprintf('%s det@haspilatus300k:/home/det/p2_det/images/%s/%s.cbf %s%s.cbf',WinScp, ...
               projectname,sprintf('%s%05d',syntaxbegin,fsqn(i)),CopyToDir,sprintf('%s%05d',syntaxbegin,fsqn(i)));
           dos(cmd);
   else
          fclose(fid);
   end
  end;
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
   if(detectortype==1000)
       A = cbfread(sprintf('Z:\\%s\\%s%05d.cbf',projectname,syntaxbegin,fsqn(i)));
   elseif(detectortype == 300)
       A = cbfread(fullfile(CopyToDir,sprintf('%s.cbf',sprintf('%s%05d',syntaxbegin,fsqn(i)))));       
   end;
   A = A.data';
   imagesc(log(min(A,maxval)+1));
   title(regexprep(sprintf('%s%05d',syntaxbegin,fsqn(i)),'[_]','\\_'));
   axis equal
   axis image
   colormap(jet2);
   colorbar;
   drawnow
end