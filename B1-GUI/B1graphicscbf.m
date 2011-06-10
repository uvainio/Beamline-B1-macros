function B1graphicscbf(varargin)
% B1GRAPHICSCBF M-file for B1graphicscbf.fig
%      B1GRAPHICSCBF, by itself, creates a new B1GRAPHICSCBF or raises the existing
%      singleton*.
%
%      H = B1GRAPHICSCBF returns the handle to a new B1GRAPHICSCBF or the handle to
%      the existing singleton*.
%
%      B1GRAPHICSCBF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in B1GRAPHICSCBF.M with the given input arguments.
%
%      B1GRAPHICSCBF('Property','Value',...) creates a new B1GRAPHICSCBF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before B1graphicscbf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to B1graphicscbf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created: 24.11.2009 Ulla Vainio (ulla.vainio@desy.de)

% Edit the above text to modify the response to help B1graphicscbf

% Last Modified by GUIDE v2.5 30-May-2011 14:34:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @B1graphicscbf_OpeningFcn, ...
                   'gui_OutputFcn',  @B1graphicscbf_OutputFcn, ...
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

% --- Executes just before B1graphicscbf is made visible.
function B1graphicscbf_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to B1graphicscbf (see VARARGIN)

% Choose default command line output for B1graphicscbf
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using B1graphicscbf.
if strcmp(get(hObject,'Visible'),'off')
    imagesc(ones([619,487]));
    axis equal
    axis image
    colorbar
end

% Set the year to be current year automatically when opening the window
nowdate = date();
set(handles.edit6, 'String',sprintf('D:\\Projekte\\%s\\',nowdate(8:end)));


% UIWAIT makes B1graphicscbf wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = B1graphicscbf_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateall(handles)

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%d',1));


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','test_');

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%d',1000));



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','MMDDName');


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1




% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val1 = str2double(get(handles.edit1,'String'));
set(handles.edit1,'String',val1+1);
updateall(handles)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val1 = str2double(get(handles.edit1,'String'));
set(handles.edit1,'String',val1-1);
updateall(handles)

function updateall(handles)

% Go to specified directory
projectname = get(handles.edit4, 'String');
dirname = get(handles.edit6, 'String');
subdir = get(handles.edit7, 'String');
fulldirectory = sprintf('%s%s\\%s\\',dirname,projectname,subdir);
fulldirectorymask = sprintf('%s%s\\processing\\mask.mat',dirname,projectname);
addpath(fulldirectory);
%cd(sprintf('%s%s\\',dirname,projectname))

maxval = str2double(get(handles.edit3, 'String'));
syntaxbegin = get(handles.edit2, 'String');
fsqn = str2double(get(handles.edit1, 'String'));

axes(handles.axes1);
cla;
% Download the data
if(strcmp(syntaxbegin,'org_'))
   downloaddatacbf(dirname,subdir,projectname,fsqn);
else
   fid = fopen('d:\dontremovethisfile.mat','r');
   if(fid==-1)
       disp('Cannot download data to any other computer than the analysis computer at B1!');
       return;
   end;
   fclose(fid);
   load d:\dontremovethisfile.mat
   WinScp = sprintf('D:\\Projekte\\Putty\\PSCP.EXE -scp -pw %s',pilatus);
   fid = fopen(fullfile(fulldirectory,sprintf('%s.cbf',sprintf('%s%05d',syntaxbegin,fsqn))),'r'); 
   if fid==-1
      cmd = sprintf('%s det@haspilatus300k:/home/det/p2_det/images/%s/%s.cbf %s%s.cbf',WinScp, ...
               projectname,sprintf('%s%05d',syntaxbegin,fsqn),fulldirectory,sprintf('%s%05d',syntaxbegin,fsqn));
      dos(cmd);
   else
      fclose(fid);
   end   
end;

A = cbfread(fullfile(fulldirectory,sprintf('%s%05d.cbf',syntaxbegin,fsqn)));
A = A.data';

% If linear scale
if(~get(handles.checkbox1,'Value'))
    imagesc(min(A,maxval));
else
    imagesc(log(min(A,maxval)+1));
end;
title(regexprep(sprintf('%s%05d',syntaxbegin,fsqn),'[_]','\\_'));

% If mask is ticked, show it
if(get(handles.checkbox2,'Value'))
   % Load the mask
   load(fulldirectorymask);
   hold on
   % cover masked area with white (by Andras Wacha)
   white=ones(size(mask,1),size(mask,2),3);
   h=image(white);
   set(h,'AlphaData',(1-mask)*0.70);
   hold off
end;

axis equal
axis image
colorbar;
drawnow
set(gca,'FontSize',12);
% If mask is ticked, show counts
if(get(handles.checkbox2,'Value'))
   % Total and maximum counts after masking
   set(handles.edit8,'String',sum(sum(A.*mask)));
   set(handles.edit9,'String',max(max(A.*mask)));
else
   set(handles.edit8,'String','no mask');
   set(handles.edit9,'String','no mask');
end;

% Set info to text box
if(strcmp(syntaxbegin,'org_'))
   header = readheader(syntaxbegin,fsqn,'.header');
   infoparam = sprintf('%d          %d             %.1f            %d            %.2f            %.4f              %.f              %s   %s\n',header.FSN,round(header.MeasTime),header.Energy,...
      header.Dist,header.PosSample,header.Transm,...
      header.Temperature,header.Title,sprintf('%d.%d.%d %d:%02d',header.Day,...
      header.Month,header.Year,header.Hour,header.Minutes));
   infoold = get(handles.listbox1,'String');
   si = size(infoold);
   if(si(1)<30)
      set(handles.listbox1,'String',{infoparam;char(infoold)});
   else
       set(handles.listbox1,'String',{infoparam;char(infoold(1:29))});
   end;
end;



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --------------------------------------------------------------------
function uitoggletool5_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on


% --------------------------------------------------------------------
function uitoggletool5_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off

