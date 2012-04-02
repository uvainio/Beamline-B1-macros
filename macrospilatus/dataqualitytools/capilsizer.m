function varargout = capilsizer(varargin)
% CAPILSIZER M-file for capilsizer.fig
%      CAPILSIZER, by itself, creates a new CAPILSIZER or raises the existing
%      singleton*.
%
%      H = CAPILSIZER returns the handle to a new CAPILSIZER or the handle to
%      the existing singleton*.
%
%      CAPILSIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAPILSIZER.M with the given input arguments.
%
%      CAPILSIZER('Property','Value',...) creates a new CAPILSIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before capilsizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to capilsizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help capilsizer

% Last Modified by GUIDE v2.5 24-Mar-2012 19:22:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @capilsizer_OpeningFcn, ...
                   'gui_OutputFcn',  @capilsizer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before capilsizer is made visible.
function capilsizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to capilsizer (see VARARGIN)

% Choose default command line output for capilsizer
handles.output = hObject;
%Convenience: update the main directory according to the current date
dv=datevec(now);
year=dv(1);
set(handles.direntry,'String',['D:\Projekte\',num2str(year)]);
%Convenience 2: set the project name
if exist(get(handles.direntry,'String'),'dir')
    %find everything inside the "this year's projects root dir"
    dirlisting=dir(get(handles.direntry,'String'));
    %select just the folders
    dirs=dirlisting([dirlisting.isdir]);
    lasttime=max([dirs.datenum]);
    lastproject=dirs([dirs.datenum]==lasttime).name;
    set(handles.projectnameentry,'string',lastproject);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes capilsizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = capilsizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function projectnameentry_Callback(hObject, eventdata, handles)
% hObject    handle to projectnameentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectnameentry as text
%        str2double(get(hObject,'String')) returns contents of projectnameentry as a double


% --- Executes during object creation, after setting all properties.
function projectnameentry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectnameentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function direntry_Callback(hObject, eventdata, handles)
% hObject    handle to direntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of direntry as text
%        str2double(get(hObject,'String')) returns contents of direntry as a double


% --- Executes during object creation, after setting all properties.
function direntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to direntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function subdirentry_Callback(hObject, eventdata, handles)
% hObject    handle to subdirentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subdirentry as text
%        str2double(get(hObject,'String')) returns contents of subdirentry as a double


% --- Executes during object creation, after setting all properties.
function subdirentry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subdirentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function formatentry_Callback(hObject, eventdata, handles)
% hObject    handle to formatentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of formatentry as text
%        str2double(get(hObject,'String')) returns contents of formatentry as a double


% --- Executes during object creation, after setting all properties.
function formatentry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to formatentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fsndecrementbutton.
function fsndecrementbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fsndecrementbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fsn=str2double(get(handles.fsnentry,'string'));
set(handles.fsnentry,'string',num2str(fsn-1));
reloadbutton_Callback(hObject, eventdata, handles);



function fsnentry_Callback(hObject, eventdata, handles)
% hObject    handle to fsnentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fsnentry as text
%        str2double(get(hObject,'String')) returns contents of fsnentry as a double


% --- Executes during object creation, after setting all properties.
function fsnentry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fsnentry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fsnincrementbutton.
function fsnincrementbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fsnincrementbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fsn=str2double(get(handles.fsnentry,'string'));
set(handles.fsnentry,'string',num2str(fsn+1));
reloadbutton_Callback(hObject, eventdata, handles);

% --- Executes on selection change in logbox.
function logbox_Callback(hObject, eventdata, handles)
% hObject    handle to logbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns logbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from logbox


% --- Executes during object creation, after setting all properties.
function logbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reloadbutton.
function reloadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to reloadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
projectname=get(handles.projectnameentry,'string');
directory=get(handles.direntry,'string');
subdir=get(handles.subdirentry,'string');
fnformat=get(handles.formatentry,'string');
fsn=str2double(get(handles.fsnentry,'string'));
filename=[directory,filesep,projectname,filesep,subdir,filesep,sprintf(fnformat,fsn)];
xname=get(handles.column_x,'string');
yname=get(handles.column_y,'string');
ysname=get(handles.column_yscale,'string');
abt=readabt(filename);
if isempty(fieldnames(abt));
    do_log(['Could not load file ',filename,'!']);
    return;
end
xindex=[]; yindex=[]; ysindex=[];
for i = 1:numel(abt.Columns)
    if strcmpi(abt.Columns{i},xname)
        xindex=i;
    end;
    if strcmpi(abt.Columns{i},yname)
        yindex=i;
    end;
    if strcmpi(abt.Columns{i},ysname)
        ysindex=i;
    end;
end;
if isempty(xindex)
    handles=do_log(sprintf('No column %s in file! Maybe it is an energy scan?',xname));
    return
end
if isempty(yindex)
    handles=do_log(sprintf('No column %s in file! Maybe it is an energy scan?',yname));
    return
end
if isempty(ysindex)
    handles=do_log(sprintf('No column %s in file! Maybe it is an energy scan?',yname));
    return
end
handles=do_log(['File ',filename,' loaded successfully.']);
handles.xdata=abt.Data(:,xindex);
handles.ydata=abt.Data(:,yindex);
handles.ysdata=abt.Data(:,ysindex);
guidata(gcbo,handles);
hold off;
plot(handles.xdata,handles.ydata./handles.ysdata,'.-');


function h=do_log(text)
h=guidata(gcbo);
log=get(h.logbox,'string');
if iscell(log)
    log{end+1}=text;
else
    log={log,text};
end
set(h.logbox,'string',log);
set(h.logbox,'value',numel(log));
guidata(gcbo,h);




function column_x_Callback(hObject, eventdata, handles)
% hObject    handle to column_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of column_x as text
%        str2double(get(hObject,'String')) returns contents of column_x as a double


% --- Executes during object creation, after setting all properties.
function column_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function column_y_Callback(hObject, eventdata, handles)
% hObject    handle to column_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of column_y as text
%        str2double(get(hObject,'String')) returns contents of column_y as a double


% --- Executes during object creation, after setting all properties.
function column_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function column_yscale_Callback(hObject, eventdata, handles)
% hObject    handle to column_yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of column_yscale as text
%        str2double(get(hObject,'String')) returns contents of column_yscale as a double


% --- Executes during object creation, after setting all properties.
function column_yscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_yscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cleargraphbutton.
function cleargraphbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cleargraphbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1);

% --- Executes on button press in findcapillarybutton.
function findcapillarybutton_Callback(hObject, eventdata, handles)
% hObject    handle to findcapillarybutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'xdata') || ~isfield(handles,'ydata') || ~isfield(handles,'ysdata')
    do_log('Please load a scan first!!!');
    return
end
do_log(sprintf('---------------------------'));
ax=axis();
x=handles.xdata;
y=handles.ydata./handles.ysdata;
idx=(x>=ax(1))&(x<=ax(2))&(y>=ax(3))&(y<=ax(4));
x=x(idx);
y=y(idx);
toplevel=0.5*(y(1)+y(end));
minlevel=min(y);
minpoint=x(y==minlevel);
minpoint=minpoint(1); %in case more would exist
do_log(sprintf('Minimum point: %.3f (y = %f)',minpoint,minlevel));
midlevel=0.5*(minlevel+toplevel);
leftmidpoint=my_interpolate(-y(x<minpoint),x(x<minpoint),-midlevel);
rightmidpoint=my_interpolate(y(x>minpoint),x(x>minpoint),midlevel);
thickness=rightmidpoint-leftmidpoint;
center=(leftmidpoint+rightmidpoint)*0.5;
do_log(sprintf('Thickness: %.3f',thickness));
do_log(sprintf('Center: %.3f',center));
do_log(sprintf('Mismatch between minimum and center: %.3f',minpoint-center));
handles=guidata(gcbo);
hold on; plot(center,minlevel,'rx','markersize',12);
plot([leftmidpoint,rightmidpoint],[midlevel,midlevel],'r-x');
text(center,minlevel,sprintf('%.3f',center),'horizontalalignment','center','verticalalignment','top');
text(center,midlevel,sprintf('%.3f',thickness),'horizontalalignment','center','verticalalignment','bottom');

% --- Executes on button press in quitbutton.
function quitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to quitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

function yi=my_interpolate(x,y,xi)

idx=(diff(sign(x-xi))~=0);
i=find(idx,1);
%xi is between the i-th and i+1-th.
a=(y(i+1)-y(i))/(x(i+1)-x(i));
b=y(i)-a*x(i);
yi=xi*a+b;


% --- Executes on button press in helpbutton.
function helpbutton_Callback(hObject, eventdata, handles)
% hObject    handle to helpbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Load a file, then zoom to a capillary as tightly as possible (the top is determined by the leftmost and the rightmost points). Then click the "Find position and size" button.');
