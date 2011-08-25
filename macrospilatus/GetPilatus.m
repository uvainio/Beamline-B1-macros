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
% Edited $2011-7-5$ by Andras Wacha, added getB1setting.m, beautified code,
% made the script to be usable off-line.

%syntax = 'org_%05d';
%syntax = 'image_%05d';

CopyToDir = fullfile(pwd(),'data1',''); % no (back)slash at the end!
nowyear=datestr(now,10);
CopyFromDir = sprintf('/home/b1user/data/%d/%s',nowyear,projectname); % no slash at the end!

pilatus1Mdir=sprintf('Z:\\%s',projectname);

% settings.txt is now handled by getB1setting.m, at the appropriate place.
%fid = fopen(sprintf('%s\\processing\\settings.txt',pwd()));
%line1 = fgetl(fid);
%fclose(fid);
%if (strcmp('300k',line1))
%    detectortype = 300;
%elseif(strcmp('1M',line1) || strcmp('1m',line1))
%    detectortype = 1000;
%end;

jet2 = jet(256);
jet2(1,:)=0;

flagfirsttime = 0;
for i=1:length(fsqn)
    cbfname=sprintf('%s%05d.cbf',syntaxbegin,fsqn(i));
    if getB1setting('300k')
        if ~exist(cbfname,'file'); % if does not exist, try to download it.
            % initialize downloading
            if(flagfirsttime == 0)
                try
                    load d:\dontremovethisfile.mat
                catch
                    disp('Cannot download data to any other computer than the analysis computer at B1!');
                    return;
                end;
                WinScp = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',pilatus);
                WinScp2 = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',online);
                flagfirsttime = 1;
            end;
            cmd = sprintf('%s det@haspilatus300k:/home/det/p2_det/images/%s/%s %s',WinScp, ...
                          projectname,cbfname,CopyToDir);
            dos(cmd);
            % file should now be in place. Check if it really is.
            if (~exist(cbfname,'file')) && (~exist(fullfile(CopyToDir,cbfname),'file'))
                disp('File %s has not been found on the standard path and could not be downloaded, SKIPPING.',cbfname);
                continue % continue with the next FSN.
            end
        end
    elseif getB1setting('1m')
        if ~exist(cbfname,'file') && (~exist(fullfile(pilatus1Mdir,cbfname),'file'))
            disp('File %s has not been found on the standard path or the Pilatus 1M path (%s). SKIPPING.',cbfname,pilatus1Mdir);
            continue
        end
    end;
    % file should now exist in CopyToDir or pilatus1Mdir or on the path.
    if(nargout == 2) % header is also expected. Try to find it on the path or download it.
        headername=sprintf('%s%05d.header',syntaxbegin,fsqn(i));
        if ~exist(headername,'file'); % try to download it from the hasb1 computer
            cmd = sprintf('%s b1user@hasb1:%s/%s %s/%s',WinScp2, ...
                           CopyFromDir,headername,CopyToDir,headername);
            dos(cmd);
        end
        header = readheader(headername);
        if ~isstruct(header) % header not found
            disp('Header file %s has not been found. SKIPPING.',headername)
            continue
        end
    end;
    if exist(cbfname,'file') % if cbf file is on the standard path...
        A = cbfread(which(cbfname));
    elseif getB1setting('1m')
        A = cbfread(fullfile(pilatus1Mdir,cbfname));
    elseif getB1setting('300k')
        A = cbfread(fullfile(CopyToDir,cbfname));
    end;
    A = A.data';
    imagesc(log(min(A,maxval)+1));
    title(cbfname(1:end-4),'Interpreter','none');
    axis equal
    axis image
    colormap(jet2);
    colorbar;
    drawnow
end