function moveresults(to_dir,fsns,overwrite,what)
%function moveresults(to_dir,fsns,overwrite,what)
%
% Move data reduction result files from the current directory to elsewhere.
%
% Inputs:
%     to_dir: where to move them (relative or absolute path). The directory
%        should exist.
%     fsns: The file sequence numbers. If omitted, this is autodetermined.
%        An empty list also signifies the wish for autodetection.
%     overwrite: 'none', 'older', 'all'. Defaults to 'none'.
%     what: cell array of file formats (C-style, with %d in place of the
%        FSN), e.g. {'int2dnorm%d.mat', 'intnorm%d.dat', 'intnorm%d.log'}.
%        If omitted, int2dnorm*.mat, intnorm*.dat and .log, intbinned*.dat
%        and waxs*.cor files are moved, but this can be adjusted at the
%        beginning of the moveresults.m file.
% Created 27.3.2012 AW.

if nargin<4
    %Put here the default value for 'what'.
    what={'int2dnorm%d.mat','intnorm%d.dat','intnorm%d.log','intbinned%d.dat','waxs%d.cor'};
end

if nargin<3
    overwrite='older';
end

files_to_move={};

for i = 1:numel(what)  % for each filetype
    if nargin<2 || isempty(fsns)   % FSNs should be auto-determined.
        %Auto-determining all files to be copied. For this we convert the
        %C-style file format to Windows-style, by replacing %d to *. All
        %matching files will be moved.
        dirlist=dir(regexprep(what{i},'%d','*'));
        ftm={dirlist.name};
    else
        ftm=cell(numel(fsns),1);
        for j=1:numel(fsns)
            ftm{j}=sprintf(what{i},fsns(j));
        end
    end
    files_to_move=[files_to_move,ftm];
end

% throw out names in file_to_move which do not exist in the current folder.
dirlist_from=dir();
files_to_move=intersect(files_to_move,{dirlist_from.name});

N_present=numel(files_to_move);

% test overwriting...
dirlist_to=dir(to_dir);
if strcmp(overwrite,'none')  % remove files from the list which do exist in to_dir
    files_to_move=setdiff(files_to_move,{dirlist_to.name});
elseif strcmp(overwrite,'older') % 
    for i = numel(files_to_move):-1:1;
        file_in_fromdir=dir(files_to_move{i});
        file_in_todir=dir(fullfile(to_dir,files_to_move{i}));
        if isempty(file_in_fromdir) || isempty(file_in_todir)
            continue
        end
        if file_in_todir.datenum>=file_in_fromdir.datenum % if the to-file is newer than the from-file
            files_to_move{i}=[];
        end
    end
end
N_to_move=numel(files_to_move);

fprintf(1,'Not moving %d files (avoiding overwriting)...\n',N_present-N_to_move);
fprintf(1,'Moving %d files...\n',numel(files_to_move));
tic;
for j = 1:numel(files_to_move)
    movefile(files_to_move{j},to_dir);
end
a=toc;
fprintf(1,'Moving took %.1f seconds\n',a);
