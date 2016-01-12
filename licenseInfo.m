function varargout = licenseInfo(varargin)
% LICENSEINFO MATLAB code for licenseInfo.fig
%      LICENSEINFO, by itself, creates a new LICENSEINFO or raises the existing
%      singleton*.
%
%      H = LICENSEINFO returns the handle to a new LICENSEINFO or the handle to
%      the existing singleton*.
%
%      LICENSEINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LICENSEINFO.M with the given input arguments.
%
%      LICENSEINFO('Property','Value',...) creates a new LICENSEINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before licenseInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to licenseInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help licenseInfo

% Last Modified by GUIDE v2.5 28-Oct-2015 13:57:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @licenseInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @licenseInfo_OutputFcn, ...
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


% --- Executes just before licenseInfo is made visible.
function licenseInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to licenseInfo (see VARARGIN)

% Choose default command line output for licenseInfo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes licenseInfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = licenseInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
