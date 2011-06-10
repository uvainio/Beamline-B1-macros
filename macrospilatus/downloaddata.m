function downloaddata(projectname,fsqn)

% function downloaddata(projectname,fsqn)
%
% downloaddata('0522Mattern',[200:300]);
%
% Created 27.5.2009 Ulla Vainio (adapted from code by Sylvio Haas)
% Edited: 13.7.2010 Ulla Vainio -- added Pilatus 1M
% Edited: 31.5.2011 Ulla Vainio -- combined to work with 300k and 1M

CopyToDir = sprintf('%s\\data1\\',pwd());
nowdate = date();
CopyFromDir = sprintf('/home/b1user/data/%s/%s/',nowdate(8:end),projectname);

% This settings file is required in every project in the subdirectory 'processing'
fid = fopen(sprintf('%s\\processing\\settings.txt',pwd()));
if(fid==-1)
    disp('File settings.txt does not exist! It contains information on which detector is used. Stopping.');
    return;
end;
line1 = fgetl(fid);
fclose(fid);
if(strcmp('300k',line1))
    detectortype = 300;
elseif(strcmp('1M',line1) || strcmp('1m',string(line1)))
    detectortype = 1000;
end;

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
    % Download only 300k files, not 1M (they are too big)
    if(detectortype == 300)
        fid = fopen(fullfile(CopyToDir,sprintf('%s.cbf',sprintf('%s%05d','org_',fsqn(i)))),'r');
        if fid==-1
            cmd = sprintf('%s det@haspilatus300k:/home/det/p2_det/images/%s/%s.cbf %s%s.cbf',WinScp, ...
                projectname,sprintf('%s%05d','org_',fsqn(i)),CopyToDir,sprintf('%s%05d','org_',fsqn(i)));
            dos(cmd);
        else
            fclose(fid);
        end
    end;
% TIF, obsolete
%    fid = fopen(fullfile(CopyToDir,sprintf('%s.tif',sprintf('%s%05d','org_',fsqn(i)))),'r'); 
%       if fid==-1
%            cmd = sprintf('%s det@haspilatus300k:/home/det/p2_det/images/%s.tif %s%s.tif',WinScp, ...
%               sprintf('%s%05d','org_',fsqn(i)),CopyToDir,sprintf('%s%05d','org_',fsqn(i)));
%            dos(cmd);
%       else
%         fclose(fid);
%       end;
%    end;
   
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