function value=getB1setting(key,settingsfile)
% function value=getB1setting(key,[settingsfile])
%
% Flexible utility macro to load 'key=value' or 'key:value'-type files
% 
% Inputs:
%     key: arbitrary string
%     settingsfile (optional): file to find the settings file. The default
%         can be set in getB1setting.m.
% 
% Output:
%     the value. If a key = value or key : value line is found in the file
%     (whitespaces are optional), the second part of the line (after the
%     delimiter) is returned, either as a string, or a number if it can be
%     converted (syntax is checked). If no corresponding line is found,
%     there is a list of default values inside the macro file. If no
%     default value has been found either, an error is raised.
%
% Notes: the file format is:
%     % or # designate the rest of the line as comment
%     empty lines are ignored
%     valid lines can have three formats: either 'key = value' or 'key :
%     value', or 'key'. Whitespaces around delimiters are ignored. In the
%     first two cases, value is returned after an attempt to convert it to
%     double. In the third case, 1 is returned (a bool key).
%
% Created: 29.6.2011 by AW.

default_settingsfile='processing/settings.txt';
% this list holds default values for keys. Keys not defined in the
% settings file will inherit the corresponding default value. If no default
% is found for a key and it is not defined in the file, an error will be
% raised. It would be easier to implement this as a struct, but structs
% cannot have keys containing numbers. 
default_values={{'1m',0},{'300k',0},{'nowaxs',0}};

if nargin<2
    settingsfile=default_settingsfile;
end

% try to find default arguments
value=':'; %default erroneous value
for i = 1:numel(default_values)
    if strcmpi(default_values{i}{1},key)
        value=default_values{i}{2};
    end
end

% current working directory should be the project root (e.g.
% D:\Projects\2011\0426Bota)
fid=fopen(sprintf(settingsfile));
if (fid==-1)
    error('Cannot open settings file. The current working directory should be your project directory\n(should contain %s',settingsfile);
end

line1=fgetl(fid);
lineindex=1;
while ischar(line1) %while not EOF
    % find comments (starting with # or %)...
    idx=[strfind(line1,'#') strfind(line1,'%')];
    % ...and strip them
    if numel(idx)>0
        line1=line1(1:idx(1));
    end
    % remove trailing whitespace
    line1=strtrim(line1);
    % skip empty lines and comments
    if isempty(line1)
        %do nothing, but do not break, line1=fgetl(fid) has to be loaded.
    else %string is neither empty, nor a comment
        %try to find ':' or '=' character
        idxcolon=strfind(line1,':');
        idxeqsign=strfind(line1,'=');
        if (numel(idxcolon)==1) && (numel(idxeqsign)==0)
            % if the line contains exactly one colon
            left=line1(1:idxcolon-1);
            right=line1(idxcolon+1:end);
        elseif (numel(idxcolon)==0) && (numel(idxeqsign)==1)
            % if the line contains exactly one equality sign
            left=line1(1:idxeqsign-1);
            right=line1(idxeqsign+1:end);
        elseif (numel(idxcolon)==0) && (numel(idxeqsign)==0)
            % if the line does not contain any of the two separators,
            % treat that line a bool value
            left=line1;
            right='1';
        else
            % other lines are regarded erroneous, warn the user and skip
            % them.
            warning('Line %d in settings file %s is invalid: contains more than one colons (:) or equal signs (=).',lineindex,settingsfile)
            left='';
            right='';
        end
        % trim left and right
        left=strtrim(left);
        right=strtrim(right);
        if ~isempty(left) % left is empty only if the line was erroneous.
            if strcmpi(left,key) %try if this is the "key"
                % try to convert 'right' to double
                value=str2double(right);
                if isnan(value)
                    value=right;
                end
                break %key found!
            end
        end
    end
    line1=fgetl(fid);
    lineindex=lineindex+1;
end
fclose(fid);

% check if we found a value (either from the file or a default)
if strcmp(value,':') % the erroneous default remained in 'value':
    error('Key %s not present in the settings file and no defaults were assigned in getB1setting.m!',key);
end

