function downloaddata(projectname,fsqn)

% function downloaddata(projectname,fsqn)
%
% e.g. downloaddata('0522Mattern',[200:300]);
%
% Created 27.5.2009 Ulla Vainio (adapted from code by Sylvio Haas)

CopyToDir = sprintf('D:\\Projekte\\2010\\%s\\data1\\',projectname);
CopyFromDir = sprintf('/home/b1user/data/2010/%s/',projectname);

fid = fopen('d:\dontremovethisfile.mat','r');
if(fid==-1)
    disp('Cannot download data to any other computer than the analysis computer at B1!');
    return;
end;
fclose(fid);
load d:\dontremovethisfile.mat

WinScp = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',pilatus);
WinScp2 = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',online);

disp('det@haspp03pilatus')

for i=1:length(fsqn)
   fid = fopen(fullfile(CopyToDir,sprintf('%s.tif',sprintf('%s%05d','org_',fsqn(i)))),'r'); 
   if fid==-1
      cmd = sprintf('%s det@haspp03pilatus:/home/det/p2_det/images/%s.tif %s%s.tif',WinScp, ...
               sprintf('%s%05d','org_',fsqn(i)),CopyToDir,sprintf('%s%05d','org_',fsqn(i)));
      dos(cmd);
   else
      fclose(fid);
   end

   fid = fopen(fullfile(CopyToDir,sprintf('%s.header',sprintf('%s%05d','org_',fsqn(i)))),'r'); 
    if fid==-1
       cmd = sprintf('%s b1user@hasb1:%s%s.header %s%s.header',WinScp2, ...
               CopyFromDir,sprintf('%s%05d','org_',fsqn(i)),CopyToDir,sprintf('%s%05d','org_',fsqn(i)));
       dos(cmd);
    else
     fclose(fid);
    end

% WAXS data
    fid = fopen(fullfile(CopyToDir,sprintf('%s.dat',sprintf('%s%05d','waxs_',fsqn(i)))),'r');
    if fid==-1
       cmd = sprintf('%s b1user@hasb1:%s%s.dat %s%s.dat',WinScp2, ...
               CopyFromDir,sprintf('%s%05d','waxs_',fsqn(i)),CopyToDir,sprintf('%s%05d','waxs_',fsqn(i)));
       dos(cmd);
    else
     fclose(fid);
    end

end;
end