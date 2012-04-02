function abt=readabt(fsn,fnformat)
%function abt=readabt(fsn,[fnformat])
%
% Read a scan data (abt_?????.fio)
%
% Inputs:
%    fsn: the file sequence number (or a file name, or a cell array of file
%    names)
%    fnformat (optional): the filename format. Defaults to abt_%05d.fio
%
% Outputs:
%    a structure (array), with the fields Data, Columns, Params, Comments and FSN
%
% Created 20.12.2011 Andras Wacha (awacha at gmail dot com)


if nargin<2
    fnformat='abt_%05d.fio';
end
abt=struct();
if ischar(fsn);
    fsn={fsn};
end

for i = 1:numel(fsn)
    if iscell(fsn(i))
        fid=fopen(fsn{i});
        if fid<0
            disp(['File ',fsn{i},' was not found. Skipping.']);
            continue;
        end
    else
        fid=fopen(sprintf(fnformat,fsn(i)));
        if fid<0
            disp(['File ',sprintf(fnformat,fsn(i)),' was not found. Skipping.']);
            continue;
        end
    end
    abt(i).FSN=fsn(i);
    inputmode='';
    while 1;
        l=fgetl(fid);
        if ~ischar(l); break; end;
        l=strtrim(l);
        if isempty(l)
            continue; %empty lines are disregarded
        elseif ~isempty(regexp(l,'^!', 'once' ));
            continue; %lines starting with '!' are comments.
        elseif ~isempty(regexp(l,'^%d', 'once' ));
            inputmode='Data_columninput'; continue;
        elseif ~isempty(regexp(l,'^%c', 'once' ));
            inputmode='Comment'; continue;
        elseif ~isempty(regexp(l,'^%p', 'once' ));
            inputmode='Params'; continue;
        end
        if strcmp(inputmode,'Comment')
            if ~isfield(abt(i),'Comments')
                abt(i).Comments={l};
            else
                abt(i).Comments{end+1}=l;
            end
            continue;
        elseif strcmp(inputmode,'Params')
            if ~isfield(abt(i),'Params')
                abt(i).Params=struct();
            end
            n=regexp(l,'(?<lhs>[0-9a-zA-Z._+-]+)\s*=\s*(?<rhs>[0-9.+-]+)','names');
            abt(i).Params.(n.lhs)=str2double(n.rhs);
            continue;
        elseif strcmp(inputmode,'Data_columninput')
            rematch=regexp(l,'^Col\s*(?<num>\d+)\s*(?<name>\w+)\s*(?<type>\w+)','names');
            if isempty(rematch)
                inputmode='Data_datainput'; %do not continue, we still have to do something with this line.
            else
                if ~isfield(abt(i),'Columns')
                    abt(i).Columns={};
                end
                abt(i).Columns{end+1}=rematch.name;
            end
        elseif strcmp(inputmode,'Data_datainput')
            lis=sscanf(l,'%f');  %Note, this is vectorized!!!
            if ~isfield(abt(i),'Data')
                abt(i).Data=zeros(1,numel(lis));  %Note, this is vectorized!!!
                abt(i).Data(1,:)=lis;
            else
                if (numel(lis)==size(abt(i).Data,2))
                    abt(i).Data(end+1,:)=lis;
                else
                    numel(lis)
                    size(abt(i).Data)
                    disp('length is not correct');
                    continue
                end
            end
        end
    end
    %remove common prefix from column names
    lencommonprefix=0;
    breakwhile=0;
    while ~breakwhile;
        lencommonprefix=lencommonprefix+1;
        for j =2:numel(abt(i).Columns)
            if ~strncmp(abt(i).Columns{j},abt(i).Columns{1},lencommonprefix)
                breakwhile=1;
                break
            end
            if lencommonprefix>numel(abt(i).Columns{j})
                breakwhile=1;
                break
            end
        end
    end
    for j = 1:numel(abt(i).Columns)
        abt(i).Columns{j}=abt(i).Columns{j}(lencommonprefix:end);
    end
    fclose(fid);
end