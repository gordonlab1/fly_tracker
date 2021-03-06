function varargout = flytracker(varargin)
% Fly Tracker, created by Jeff Stafford. Run this script or open flytracker.fig to start! 

% FLYTRACKER MATLAB code for flytracker.fig
%      FLYTRACKER, by itself, creates a new FLYTRACKER or raises the existing
%      singleton*.
%
%      H = FLYTRACKER returns the handle to a new FLYTRACKER or the handle to
%      the existing singleton*.
%
%      FLYTRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLYTRACKER.M with the given input arguments.
%
%      FLYTRACKER('Property','Value',...) creates a new FLYTRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flytracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to flytracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help flytracker

% Last Modified by GUIDE v2.5 01-Jan-2015 15:26:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @flytracker_OpeningFcn, ...
                   'gui_OutputFcn',  @flytracker_OutputFcn, ...
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

% --- Executes just before flytracker is made visible.
function flytracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flytracker (see VARARGIN)

% Choose default command line output for flytracker
handles.output = hObject;

% INITIALIZE VARIABLES HERE
% global variables
handles.topHalfHeight = 3;
handles.bottomHalfHeight = 8;
handles.innerDiameter = 1.5;
% video analysis variables
handles.thresholdVal = 1.5;
handles.filterStatus = true;
handles.filterDist = 0.25;
handles.interpolStatus = true;
handles.interpolDist = 0.1;
% stats variables
handles.totalTime = 120;
handles.framerate = 30;
handles.noFlyOn = 0;
handles.flyPos = 'Bottom';
% comparison variables
handles.compareDistThresh = 0.5;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes flytracker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = flytracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in loadVideo.
function loadVideo_Callback(hObject, eventdata, handles)
% hObject    handle to loadVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[video_name, pathname] = uigetfile({'*.avi;*.mj2;*.mpg;*.mp4;*.m4v;*.mov', ...
    'Video Files (*.avi;*.mj2;*.mpg;*.mp4;*.m4v;*.mov)'}, ...
    'Select a video to analyze...', 'MultiSelect','off');
if (pathname ~= 0)
    video_name = strcat(pathname,video_name);
    flytrack_video_fn(video_name, handles.thresholdVal, handles.filterStatus, ...
         handles.filterDist, handles.interpolStatus, handles.interpolDist, ...
         handles.topHalfHeight, handles.bottomHalfHeight, handles.innerDiameter);
end


% --- Executes on button press in stats.
function stats_Callback(hObject, eventdata, handles)
% hObject    handle to stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[files, pathname] = uigetfile({'*.csv;*', ...
    'Comma-separated values (*.csv)'}, ...
    'Select a set of flypath files (created by "Analyze Video")...', 'MultiSelect','on');

if (pathname ~= 0)
    files = strcat(pathname,files);
    flytrack_stats_fn(files, handles.totalTime, handles.framerate, handles.noFlyOn, handles.flyPos, ...
        handles.topHalfHeight, handles.bottomHalfHeight, handles.innerDiameter);
end



% --- Executes on button press in compare.
function compare_Callback(hObject, eventdata, handles)
% hObject    handle to compare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[files, pathname] = uigetfile({'*.csv;*', ...
    'Comma-separated values (*.csv)'}, ...
    'Select a set of interfly distance files (created by "Statistics")...', 'MultiSelect','on');
if (pathname ~= 0)
    files = strcat(pathname,files);
    boxPlotter_fn(files, handles.compareDistThresh);
end



function thresholdVal = thresholdSet_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdSet as text
%        str2double(get(hObject,'String')) returns contents of thresholdSet as a double
handles.thresholdVal = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function thresholdSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function interpolDistSet_Callback(hObject, eventdata, handles)
% hObject    handle to interpolDistSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interpolDistSet as text
%        str2double(get(hObject,'String')) returns contents of interpolDistSet as a double
handles.interpolDist = str2double(get(hObject,'String'));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function interpolDistSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interpolDistSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in interpolOn.
function interpolOn_Callback(hObject, eventdata, handles)
% hObject    handle to interpolOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of interpolOn
handles.interpolStatus = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in filterOn.
function filterOn_Callback(hObject, eventdata, handles)
% hObject    handle to filterOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filterOn
handles.filterStatus = get(hObject,'Value');
guidata(hObject, handles);


function filterDistSet_Callback(hObject, eventdata, handles)
% hObject    handle to filterDistSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterDistSet as text
%        str2double(get(hObject,'String')) returns contents of filterDistSet as a double
handles.filterDist = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function filterDist = filterDistSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterDistSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalTimeSet_Callback(hObject, eventdata, handles)
% hObject    handle to totalTimeSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalTimeSet as text
%        str2double(get(hObject,'String')) returns contents of totalTimeSet as a double
handles.totalTime = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function totalTimeSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalTimeSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function framerateSet_Callback(hObject, eventdata, handles)
% hObject    handle to framerateSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framerateSet as text
%        str2double(get(hObject,'String')) returns contents of framerateSet as a double
handles.framerate = str2double(get(hObject,'String'));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function framerateSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framerateSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in noFlyOnOff.
function noFlyOnOff_Callback(hObject, eventdata, handles)
% hObject    handle to noFlyOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noFlyOnOff
handles.noFlyOn = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on selection change in flyPosSet.
function flyPosSet_Callback(hObject, eventdata, handles)
% hObject    handle to flyPosSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns flyPosSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from flyPosSet
contents = cellstr(get(hObject,'String'));
handles.flyPos = contents{get(hObject,'Value')};
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function flyPosSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flyPosSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DistThreshSet_Callback(hObject, eventdata, handles)
% hObject    handle to DistThreshSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DistThreshSet as text
%        str2double(get(hObject,'String')) returns contents of DistThreshSet as a double
handles.compareDistThresh = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DistThreshSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DistThreshSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function topHalfSet_Callback(hObject, eventdata, handles)
% hObject    handle to topHalfSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of topHalfSet as text
%        str2double(get(hObject,'String')) returns contents of topHalfSet as a double
handles.topHalfHeight = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function topHalfSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to topHalfSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bottomHalfSet_Callback(hObject, eventdata, handles)
% hObject    handle to bottomHalfSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bottomHalfSet as text
%        str2double(get(hObject,'String')) returns contents of bottomHalfSet as a double
handles.bottomHalfHeight = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function bottomHalfSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bottomHalfSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diameterSet_Callback(hObject, eventdata, handles)
% hObject    handle to diameterSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diameterSet as text
%        str2double(get(hObject,'String')) returns contents of diameterSet as a double
handles.innerDiameter = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function diameterSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diameterSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
