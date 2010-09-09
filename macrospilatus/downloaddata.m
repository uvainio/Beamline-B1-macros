function downloaddata(projectname,fsqn,detector)

% function downloaddata(projectname,fsqn,detector)
%
% With Pilatus 1M:
% e.g. downloaddata('0522Mattern',[200:300],'1M');
% Or with Pilatus 300k:
% e.g. downloaddata('0522Mattern',[200:300]);
%
% Created 27.5.2009 Ulla Vainio (adapted from code by Sylvio Haas)
% Edited: 13.7.2010 Ulla Vainio -- added Pilatus 1M

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

for i=1:length(fsqn)
    if(nargin<3) % Only for 300k, for 1M we don't need to download the data because it is on a network directory
       fid = fopen(fullfile(CopyToDir,sprintf('%s.tif',sprintf('%s%05d','org_',fsqn(i)))),'r'); 
       if fid==-1
            cmd = sprintf('%s det@haspilatus300k:/home/det/p2_det/images/%s.tif %s%s.tif',WinScp, ...
               sprintf('%s%05d','org_',fsqn(i)),CopyToDir,sprintf('%s%05d','org_',fsqn(i)));
            dos(cmd);
       else
         fclose(fid);
       end;
    end;
    %if(nargin==3)
    %   fid = fopen(fullfile(CopyToDir,sprintf('%s.cbf',sprintf('%s%05d','org_',fsqn(i)))),'r'); 
    %   if(fid==-1 && strcmp(detector,'1M'))
    %     cmd = sprintf('%s det@haspilatus1m:/home/det/p2_det/images/0714Jiang/%s.cbf %s%s.cbf',WinScp, ...
    %           sprintf('%s%05d','org_',fsqn(i)),CopyToDir,sprintf('%s%05d','org_',fsqn(i)));
    %     dos(cmd);           
    %   else
    %     fclose(fid);
    %   end;
    %end;
   
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