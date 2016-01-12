
function varargout = smartACT(varargin)
% SMARTACT MATLAB code for smartACT.fig
 Please read the documentation before use and then comment out this line.
% © 2015 Allen Institute.
% This file is part of smartACT.
% smartACT is free software: you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free 
% Software Foundation, either version 3 of the License, or (at your option)
% any later version. smartACT is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
% General Public License for more details.

% You should have received a copy of the GNU General Public License along with smartACT.
% If not, see <http://www.gnu.org/licenses/>.
% 
% This package is currently not maintained and no support is implied. 
% Questions may be directed to Brian Long
% <brianl@alleninstitute.org> with 'smartACT' in the subject line. 
% 

% Last Modified by GUIDE v2.5 29-Jul-2015 13:28:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @smartACT_OpeningFcn, ...
    'gui_OutputFcn',  @smartACT_OutputFcn, ...
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


% --- Executes just before smartACT is made visible.
function smartACT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to smartACT (see VARARGIN)

licenseInfo


% Choose default command line output for smartACT
handles.output = hObject

%% add rectangles to separate functional interfaces
%initialization
annotation('rectangle', [.1/12, 10.5/18, 5/12, 6.5/18])

% parameters
annotation('rectangle', [0.1/12, 5.2/18, 5/12, 5/18])

% other  (left bottom)?
annotation('rectangle', [0.1/12, .1/18, 5/12, 5/18])

% direct pipet control
annotation('rectangle', [6/12, .1/18, 5.9/12, 5.5/18])
% adaptive approach
annotation('rectangle', [6/12, .1/18, 5.9/12, 5.5/18])

%  approach control
annotation('rectangle', [6/12, 10/18, 5.9/12, 7.5/18])


% the struct 'udat' is stored in the smartACT userdata and
% MUST BE UPDATED
% by every callback or external function that uses it

udat.gotAxon285=0;
udat.fakeAxon285=0;
udat.usingFakeData = 0;
% keep track of some function handles in one place for convenience
udat.fhandles.stopStartCB = @goStopB_Callback;
udat.fhandles.updateSP =@updateCoordinatesB_Callback;
udat.updateCoordinatesBh = handles.updateCoordinatesB;
udat.autostopped = 0;
%  and same with some important GUI objects
udat.goStopBh = handles.goStopB;
udat.statusTexth = handles.statusT;
udat.smartACTh = hObject;   % have to add this because apparently the GUI figure
% is not currently tagged in the handles struct as udat.smartACTh

udat.tipChannelh = handles.tipChannelPM;
udat.cellChannelh = handles.cellChannelPM;

udat.fhandles.normalizeLatest = @normalizeLatestTifB_Callback;
udat.normalizeTifh = handles.normalizeLatestTifB;



    udat.tcDataUsed= [];
    udat.alltcData= [];

set(handles.adaptApproachB,'enable', 'off')
set(handles.figure1,'UserData', udat);



%% Update handles structure
guidata(hObject, handles);

%% UIWAIT makes smartACT wait for user response (see UIRESUME)
%% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = smartACT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in initializeB.
function initializeB_Callback(hObject, eventdata, handles)
% hObject    handle to initializeB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% the struct 'udat' is stored in the smartACT userdata and
% MUST BE UPDATED
% by every callback or external function that uses it

udat = get(handles.figure1, 'UserData');

% default values not set by default strings in the GUI .fig or established in the opening func:
udat.COMport=4;
udat.fastVelocity = 50;
udat.timerPeriod = .25;  % move every 0.5s
udat.timerModeStrings ={'fixedSpacing', 'singleShot'}
udat.timerExecutionMode =udat.timerModeStrings{get(handles.continuousSingleStepPM,'value')};




% make the timer object here
% first, delete any other timer called 'approachTimer' :
delete(timerfind('name', 'approachTimer'))
%

% then make a timer and
% pass the GUI handles to the timer callback
udat.myTimer = timer('TimerFcn', {@smartACTMoveCB, handles}, 'StopFcn', {@spStopCallback, handles}, ...
    'ErrorFcn', {@spErrorCallback, handles}, 'Period',udat.timerPeriod,...
    'ExecutionMode', udat.timerExecutionMode, 'name', 'approachTimer');


%  check on scanImage.

a = whos('state', 'global')

if ~isempty(a)
    udat.siStateOK = 1;
else
    udat.siStateOK = 0;
end


%  and check on the MultiClamp Commander python server


% make a system call to run the python server
try
s = system(['cd C:\Users\2prig\Documents\BRL_git\cna\Projects\TPTE\src\mcc_stuff\',...
    ' & dir & C:\WinPython-32bit-2.7.6.3\python-2.7.6\python.exe ',...
    'C:/Users/2prig/Documents/BRL_git/cna/Projects/TPTE/src/mcc_stuff/multiclamp_server.py  &'])
catch
'MCC dataLogging not enabled!'
end
udat.MCCdatalogging = 0
try
    udat.MCCdata =brl_get_MCC_values;
    if udat.MCCdata ~= [ 0 0 0 0]
        
        udat.MCCdatalogging = 1;
    end
catch
    udat.MCCdatalogging = 0
end


% this may be replaced with access to Ulf's daq-based interface



% now initialize the manipulator
if ~(udat.gotAxon285==1);
    % create global axon285 object
    udat.gotAxon285 = brl_get_AxonMP285(udat.COMport);
    
    % if this worked, enable the next step
    if  udat.gotAxon285 >0
        
        global axon285
        if isstruct(axon285)|isempty(axon285)
            set(udat.statusTexth, 'string', {'manipulator intialization failed...', 'using fake manipulator'})
            udat.fakeAxon285 = 1;
        else
            set(udat.statusTexth, 'string', 'initialized')
            set(handles.confirmParametersB, 'enable', 'on');
            set(handles.goStopB,  'string', 'confirm parameters')
        end
    else
        set(udat.statusTexth, 'string', '<html>manipulator intialization failed<br>')
    end
    
end



% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



function depthCompString_Callback(hObject, eventdata, handles)
% hObject    handle to depthCompString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depthCompString as text
%        str2double(get(hObject,'String')) returns contents of depthCompString as a double



% --- Executes on button press in confirmParametersB.
function confirmParametersB_Callback(hObject, eventdata, handles)
% hObject    handle to confirmParametersB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

udat = get(handles.figure1, 'UserData')



% collect the current numbers from string fields
potentialVelocity = str2num(get(handles.pipetSpeedS, 'String'));
potentialBuffer = str2num(get(handles.targetBufferRadiusS, 'String'));
potentialxScale = str2num(get(handles.xScaleS, 'String'));
potentialyScale = str2num(get(handles.yScaleS, 'String'));
potentialzScale = str2num(get(handles.zScaleS, 'String'));
potentialAngle = str2num(get(handles.pipetAngleS, 'String'));
potentialStepSize = str2num(get(handles.approachStepSizeS, 'String'));
potentialDepthComp = str2num(get(handles.depthCompString, 'String'));
%  now check each of these parameters
if potentialVelocity > 10 | potentialVelocity < .5 | isempty(potentialVelocity)
    set(handles.pipetSpeedS, 'String','invalid. valid range: 0.5 - 10 um/s');
    udat.speedStringOK = 0;
else
    udat.stageVelocity = potentialVelocity;
    udat.speedStringOK = 1;
end

if potentialBuffer >20 | potentialBuffer <0 | isempty(potentialBuffer)
    set(handles.targetBufferRadiusS, 'string', 'invalid. valid range 0 - 20 um');
    udat.bufferTextOK = 0;
else
    udat.bufferRadius = potentialBuffer;
    udat.bufferTextOK = 1;
end

if potentialxScale >5 | potentialxScale  <-5 | isempty(potentialxScale)
    set(handles.xScaleS, 'string', 'invalid');
    udat.xScaleOK = 0;
else
    udat.xScale = potentialxScale;
    udat.xScaleOK = 1;
end

if potentialyScale >5 | potentialyScale  <-5 | isempty(potentialyScale)
    set(handles.yScaleS , 'string',  'invalid');
    udat.yScaleOK = 0;
else
    udat.yScale = potentialyScale;
    udat.yScaleOK = 1;
end

if potentialzScale >5  | isempty(potentialzScale)
    set(handles.zScaleS, 'string',   'invalid');
    udat.zScaleOK = 0;
else
    udat.zScale = potentialzScale;
    udat.zScaleOK = 1;
end


if potentialAngle >50 | potentialAngle <10  | isempty(potentialAngle)  %not likely to be outside 10-50 degree range
    set(handles.pipetAngleS, 'string', 'invalid');
    udat.pipetAngleOK = 0;
else
    udat.pipetAngle = potentialAngle;
    udat.pipetAngleOK = 1;
end

if potentialStepSize >10 | potentialStepSize < 0.5  | isempty(potentialStepSize >10 )
    set(handles.approachStepSizeS, 'string',  'invalid');
    udat.stepSizeOK = 0;
else
    udat.approachStepSize = potentialStepSize;
    udat.stepSizeOK = 1;
end

if potentialDepthComp >1.2  || potentialDepthComp < 0.8
    set(handles.depthCompString, 'string',   'invalid');
    udat.depthCompOK = 0;
    udat.depthComp(1)= 1.0;
else
    udat.depthComp(1) = potentialDepthComp;
    udat.depthCompOK = 1;
end

udat.depthComp(2) = 0;

% update udat
set(udat.statusTexth, 'string', 'load coordinates')

set(handles.loadTargetDataB, 'enable', 'on')
set(handles.goStopB,  'string', 'load coordinates')

set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in normalizeLatestTifB.
function normalizeLatestTifB_Callback(hObject, eventdata, handles)
% hObject    handle to normalizeLatestTifB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');
if udat.siStateOK ==1
    global state
    udat.normalizationVal = str2num(get(handles.normalizationT,'String'));
    tonormalize =brl_get_latest_file([state.files.savePath,'\'],'*.tif', 'Norm');
    a = brl_norm_TPTEstack(tonormalize, udat.normalizationVal,1, 1 ,-2,1 ,[]);
else
    set(udat.statusTexth, 'string', 'start scanimage, try again')
end
% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)


% --- Executes on button press in loadTargetDataB.
function loadTargetDataB_Callback(hObject, eventdata, handles)
% hObject    handle to loadTargetDataB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');

if udat.gotAxon285
    global axon285 spStackdata state
    axon285.resolutionMode = 'fine';
    axon285.velocity = udat.stageVelocity;
    try
        mh = state.motor.hMotor;
    catch
        set(udat.statusTexth, 'string', 'start scanimage, try again')
        return
    end
else
    set(udat.statusTexth, 'string', 'manipulator loading problem, try again')
    guidata(hObject,handles)
    return
end



% this button should be a bit of a reset for the system, so I'm getting rid
% of several fields:

toremove = { 'targetIndex', 'candidateTraj',...
    'retractTraj', 'tipUpdateWorked', 'cellUpdateWorked', 'currentIndex',...
    'imagefile', 'cellposition',  ...
    'tipTraj', 'cellTraj','noMCC', ...
    'newTraj', 'potentialCoordinates',...
    'autostopped', 'firstclick','fullstack', 'currentTipMicrons', ...
    'currentTipImage', 'currentCellMicrons', 'currentCellImage', ...
    'tcDataUsed', 'alltcData'};
for j =1:numel(toremove)
    if isfield(udat,toremove{j})
        udat = rmfield(udat,toremove{j});
    end
end
udat.autostopped = 0;

udat.trajUpdates = [];
    udat.tcDataUsed= [];
    udat.alltcData= [];
% now initialize spStackdata values. THIS ASSUMES that the most recent
% stack collected was the full stack used for initial tip and cell
% localization.

% the current position should be the top of the current stack.


[filename dirname] = uigetfile(fullfile(state.files.savePath,'*.swc'),'Select a valid .swc file with cell and pipet tip locations')
udat.directory = dirname;
udat.swcfile = fullfile(dirname, filename);
% also read out image size for future reference:
udat.swcImageFile = [udat.swcfile(1:end-4)];% .swc file
a =imfinfo(udat.swcImageFile);
udat.imagesize =[a(1).Height a(1).Width numel(a)];
%udat.sliceWithTip = imread(udat.swcImageFile, round(udat.Locations.pipetTip(3)/udat.zScale));

% slightly different:  the code below looks for the last stack, which
% should be a full stack of the whole region

spStackdata.origPos = mh.positionRelative;  %RELATIVE COORDINATES
% and the original stack start z
spStackdata.origStartAbs = state.motor.stackStart;  %THIS IS IN ABSOLUTE COORDINATES
spStackdata.origStopAbs = state.motor.stackStop; %THIS IS IN ABSOLUTE COORDINATES
spStackdata.origMaxPower = state.init.eom.maxPower;

% get the relative z coordinates of the stack by checking the current
% position in relative and absolute coordinates

spStackdata.origStartRelZ = state.motor.stackStart(3)+state.motor.relZPosition - state.motor.absZPosition;

spStackdata.origStopRelZ = state.motor.stackStop(3)+state.motor.relZPosition - state.motor.absZPosition;



spStackdata.lastSIAcquisitionNumber = state.files.fileCounter-1;
spStackdata.lastFullStackRaw = brl_get_latest_file([udat.directory], '*.tif', 'Norm');
spStackdata.lastFullStack =  brl_get_latest_file([udat.directory], '*.tif');
% double check the stack parameters...
laststackdata = scim_openTif(spStackdata.lastFullStackRaw);
spStackdata.pixelsPerLine = laststackdata.acq.pixelsPerLine;
spStackdata.linesPerFrame = laststackdata.acq.linesPerFrame;
spStackdata.zStepSize = laststackdata.acq.zStepSize;
spStackdata.zoomFactor = laststackdata.acq.zoomFactor;
spStackdata.substackGrab = 0;
if spStackdata.pixelsPerLine < 255 || spStackdata.pixelsPerLine > 256 ||...
        spStackdata.linesPerFrame < 255 || spStackdata.linesPerFrame > 256 ||...
        spStackdata.zoomFactor ~=1
    
    
    set(udat.statusTexth, 'string', 'warning: last image is not 256x256 , zoom 1 ')
    
%     set(handles.figure1,'UserData', udat);
%     guidata(hObject,handles)
%     return
end




%%    SWC IMPORT
TipAndCell = brl_tip_and_cellrig(udat.swcfile, [udat.xScale udat.yScale udat.zScale])
udat.Locations = TipAndCell;
if ~isfield(udat.Locations, 'pia')
    udat.Locations.pia = udat.Locations.pipetTip;
end

%%  COORDINATES AND TRAJECTORY CALCULATION
udat.StartingPoint = udat.Locations.pipetTip-udat.Locations.pipetTip;
udat.rawTarget = udat.Locations.cell-udat.Locations.pipetTip;
udat.pialDepthRel = udat.Locations.pia-udat.Locations.pipetTip;
udat.Target = udat.rawTarget;
% extract coordinates, set relative zero and calculate path!  also do any % sign flipping if needed.
%udat.depthComp(1) = 1;
%udat.depthComp(2) = 0;  % 
%  these values have been revived!   


% modifying target for depth compensation! INCLUDING PIA DEPTH
udat.Target(3) = udat.pialDepthRel(3)+ (udat.rawTarget(3)-udat.pialDepthRel(3))*udat.depthComp(1) + udat.depthComp(2);

initialPath = brl_calculate_pathrigFINAL(udat.StartingPoint, udat.Target, udat.pipetAngle,udat.approachStepSize, udat.bufferRadius, 1);   % PIPET ANGLE HERE

% switch sign of x and y in relative path!
relpath = [-initialPath(:,1)+initialPath(1,1), -initialPath(:,2)+initialPath(1,2), initialPath(:,3)-initialPath(1,3)]; %  JUST MAKING SURE IT'S RELATIVE
udat.CalculatedPath = relpath;



udat.currentTipMicrons = [0 0 0 ];
udat.currentTipImage = udat.Locations.pipetTip.*([1/udat.xScale 1/udat.yScale 1/udat.zScale]);
udat.currentCellMicrons = udat.CalculatedPath(end,:);  % NOTE this isn't really the target location, but it 
            % also won't be actually used.
udat.currentCellImage =  udat.Locations.cell.*([1/udat.xScale 1/udat.yScale 1/udat.zScale]);

% ZEROING stage- and fixing starting point as origin
axon285.zeroSoft;
udat.CurrentLocation = axon285.positionRelative;



%%  ESTABLISHING TIMER USERDATA HERE


fortimer.trajectory = udat.CalculatedPath;
fortimer.currentIndex = 1;

set(handles.forwardBackwardPM, 'value', 1);%
predir = get(handles.forwardBackwardPM, 'value');
switch predir
    case 1
        fortimer.direction =  1;
    case 2
        fortimer.direction = -1;
end
fortimer.isFinished = 0;
fortimer.fastVelocity = udat.fastVelocity;
fortimer.velocity = udat.stageVelocity;

set(udat.myTimer, 'UserData', fortimer);



set(handles.goStopB, 'backgroundcolor',[0 1 0], 'string', 'START', 'enable', 'on')
set(udat.statusTexth, 'string', 'Ready to Approach')

% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)

%  after updating all the handles and userdata, start the approachLogger GUI
evalin('base', 'spApproachLogger')
% and start the logging.
aLUD = get(findobj('name', 'spApproachLogger'),'UserData');
feval(aLUD.fHandles.startButton, aLUD.sbHandle, [], guidata(aLUD.sbHandle));


%update handles
guidata(hObject,handles)


% --- Executes on button press in goStopB.
function goStopB_Callback(hObject, eventdata, handles)
% hObject    handle to goStopB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');



if strcmp(get(udat.myTimer,'running'),'off')==1
    udat.tipUpdateWorked=0;
    udat.cellUpdateWorked=0;
    start(udat.myTimer), set(handles.goStopB, 'backgroundcolor',[1 0 0], 'string', 'STOP')
    set(handles.abortExperimentB,'enable', 'inactive')
    set(handles.adaptApproachB,'enable', 'inactive')
    
else
    
    stop(udat.myTimer),  set(handles.goStopB, 'backgroundcolor',[0 1 0], 'string', 'START')
    set(handles.abortExperimentB,'enable', 'on')
    set(handles.adaptApproachB,'enable', 'on')
    
end
% update coordinates in spApproachLogger
% 
% feval(udat.fHandles.updateLoggerPlot)
% feval(udat.fHandles.oneShotLog)
% 
% update udat
% set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)


% --- Executes on selection change in forwardBackwardPM.
function forwardBackwardPM_Callback(hObject, eventdata, handles)
% hObject    handle to forwardBackwardPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns forwardBackwardPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from forwardBackwardPM
udat = get(handles.figure1, 'UserData');

timerdata = get(udat.myTimer, 'UserData');

predir = get(handles.forwardBackwardPM, 'value');%
switch predir
    case 1
        timerdata.direction =  1;
    case 2
        timerdata.direction = -1;
end
set(udat.myTimer, 'UserData', timerdata)

% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)


% --- Executes on selection change in continuousSingleStepPM.
function continuousSingleStepPM_Callback(hObject, eventdata, handles)
% hObject    handle to continuousSingleStepPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns continuousSingleStepPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from continuousSingleStepPM
udat = get(handles.figure1, 'UserData');

udat.timerExecutionMode =udat.timerModeStrings{get(handles.continuousSingleStepPM,'value')};

set(udat.myTimer, 'executionmode', udat.timerExecutionMode);



% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)

% --- Executes on button press in abortExperimentB.
function abortExperimentB_Callback(hObject, eventdata, handles)
% hObject    handle to abortExperimentB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');
fortimer =get(udat.myTimer, 'UserData');
global axon285


% make sure the manipulator is stopped, then update the coordinates

try
    moving = axon285.isMoving;
catch
    moving = true;
end
if ~moving
    
    pause(.1)
feval(udat.fhandles.updateSP, udat.updateCoordinatesBh, [], guidata(udat.updateCoordinatesBh))
else
    return
end

% now modify the trajectory


if ~isfield(udat,'newTraj')
    udat.newTraj = udat.CalculatedPath;
end

retractTraj = udat.newTraj;
retractTraj(2:end,:)  = retractTraj(2:end,:)-repmat(retractTraj(udat.currentIndex,:),size(retractTraj,1)-1,1)+ repmat(udat.CurrentLocation,size(retractTraj,1)-1,1)
udat.retractTraj = retractTraj;
set(handles.forwardBackwardPM, 'value', 2);%
%switch directions
fortimer.direction = -1;
fortimer.trajectory = udat.retractTraj;
    
    
  % and load it in timer  
    set(udat.myTimer, 'UserData',fortimer);



if strcmp(get(udat.myTimer,'running'),'off')==1
    
    start(udat.myTimer), set(handles.goStopB, 'backgroundcolor',[1 0 0], 'string', 'RETRACTING')
    
else
    stop(udat.myTimer),  set(handles.goStopB, 'backgroundcolor',[1 0 1], 'string', 'click Abort again')
 
end


% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)


% --- Executes on button press in findTipAndCellB.
function findTipAndCellB_Callback(hObject, eventdata, handles)
% hObject    handle to findTipAndCellB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');


% this calls the separate GUI to handle locating the tip and cell 
udat.tipCellUpdateh = evalin('base', 'brl_tip_cell_update');
handletest = get(udat.tipCellUpdateh,'UserData')
if numel(handletest.smartACTh)==0
% update udat
set(handles.figure1,'UserData', udat);
% %update handles
guidata(hObject,handles)
return    
end
% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)
% now call the relevant subfunction to activate the tip-cell stack
% collection

%feval(handletest.runfunctionh, handletest.runBh, [], guidata(handletest.runBh));


% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)


% --- Executes on button press in adaptApproachB.
function adaptApproachB_Callback(hObject, eventdata, handles)
% hObject    handle to adaptApproachB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData')
  fortimer =   get(udat.myTimer, 'UserData');

%  check if we have updated tip and cell data:


if ~(udat.tipUpdateWorked==1 && udat.cellUpdateWorked)
    guidata(hObject,handles)
return
end

    
    %  to revise the timer trajectory data
    % first, modify the trajectory:
    if ~isfield(udat,'newTraj')
        candidateTraj = udat.CalculatedPath;
    else
      candidateTraj = udat.newTraj;  % if there isn't a 'newTraj', there will be soon.
    end
    
     figure, plot3(candidateTraj(:,1), candidateTraj(:,2), candidateTraj(:,3)) , set(gca,'zdir', 'reverse'), axis equal
    
    % we have the tip position, now see how it compares to the path we're on
    tipLocationInMP285 = udat.tipTraj(end,16:18)  %latest tip location from stack, in MP285 coordinates!
   
    
    % first, we want to make an adjustment that puts the pipet back on
    % track:
    
      % the solution is to NOT MODIFY THE AXIAL POSITION, only the radial
    % location. 
    deltastruct = brl_radial_adjust(candidateTraj, fortimer.currentIndex, tipLocationInMP285)
 
    % the manipulator thinks its in the right place, but it's not.  so
    % move the tip to the planned trajectory by shifting the whole trajectory 
    candidateTraj(2:end,:)  = candidateTraj(2:end,:)+repmat(-deltastruct.deltaRad,size(candidateTraj,1)-1,1);
    hold all, plot3(candidateTraj(:,1), candidateTraj(:,2), candidateTraj(:,3))   
    
    % now adjust the whole trajectory to compensate for the shift in the
    % target position.   This is potentially a little more drastic...
    
% %    FIX ME!   deltacell =   udat.cellTraj(end,16:18)-udat.cellTraj(end,  7:9)            % current cell position - last measured cell position (or original cell position)
% % this needs to be 
% %  based on the difference between the real trajectory and the current updated location (adapted is OK IF IT WAS ACTUALLY USED)
% % 
[udat.cellTraj(end,1:3)
udat.cellTraj(end,4:6)]
 deltacell =   udat.cellTraj(end,4:6)-udat.cellTraj(end,  1:3)            % current cell position - last measured cell position (or original cell position)

deltacell = deltacell([1 2 3]).*[udat.xScale udat.yScale -udat.zScale]  % CRITICAL CORRECTION OF Z DIRECTION

% % >  related:  the cellTraj stuff has to have an official version (ONLY what was actually used)
% % and a scratch version to monitor putative locations (is this needed?)
% %    >  further adjustments would include making a NEW DIagonal path to the target (with a new buffer)
% %    make the radial move, then advance along pipet axis.  
% %    > this whole thing does become quite sensitive to exact tip location, i.e. clicking vs auto localization
% % 
   % now move the trajectory by this same vector
    candidateTraj(2:end,:) = candidateTraj(2:end,:) + repmat(-deltacell, size(candidateTraj,1)-1,1);
        hold all, plot3(candidateTraj(:,1), candidateTraj(:,2), candidateTraj(:,3))   

    udat.candidateTraj = candidateTraj;
    udat.candidateUpdates = [-deltastruct.deltaRad, -deltacell];
    
% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)


% --- Executes on button press in confirmApproachB.
function confirmApproachB_Callback(hObject, eventdata, handles)
% hObject    handle to confirmApproachB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% user must press this button to confirm adaptive approach.  good place to
% add checks on automatic adjustments
udat = get(handles.figure1, 'UserData');
   fortimer =  get(udat.myTimer, 'UserData');

    udat.currentTipImage = udat.potentialCoordinates.actualTipPixels;
    udat.currentTipMicrons = udat.potentialCoordinates.actualTipMicrons;
    udat.currentTipMP285 = udat.potentialCoordinates.actualTipMP285;
    udat.tcDataUsed= [udat.tcDataUsed; udat.potentialCoordinates];
    udat.alltcData = [udat.alltcData; get(findobj('name', 'brl_tip_cell_update'), 'userdata')];
    udat.currentCellImage = udat.potentialCoordinates.currentCellImage;



        udat.trajUpdates = [udat.trajUpdates; udat.candidateUpdates]; 

    % and load it in timer
    fortimer.trajectory = udat.candidateTraj;
    set(udat.myTimer, 'UserData',fortimer);
    udat.newTraj = udat.candidateTraj;
 % update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in updateCoordinatesB.
function updateCoordinatesB_Callback(hObject, eventdata, handles)
% hObject    handle to updateCoordinatesB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');

% this function will be called by some external functions, so it will
% actually ask the manipulator where it's at
global axon285

try
    moving = axon285.isMoving;
catch
    moving = false;
end
if ~moving
    pause(.1) %verify that this delay actually helps...?
    udat.CurrentLocation = axon285.positionRelative;
    set(handles.abortExperimentB,'enable', 'on')
    set(handles.figure1,'UserData', udat);
end
% set(handles.retractButton,'enable', 'on')
% set(handles.updateTarget,'enable', 'on')
set(handles.figure1,'UserData', udat);

feval(udat.fHandles.updateLoggerPlot)
feval(udat.fHandles.oneShotLog)
guidata(hObject,handles)



% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




% --- Executes on button press in directControlEnabledC.
function directControlEnabledC_Callback(hObject, eventdata, handles)
% hObject    handle to directControlEnabledC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of directControlEnabledC
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on selection change in manipulatorCoordinatesPM.
function manipulatorCoordinatesPM_Callback(hObject, eventdata, handles)
% hObject    handle to manipulatorCoordinatesPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns manipulatorCoordinatesPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from manipulatorCoordinatesPM
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




% --- Executes on button press in anteriorForwardB.
function anteriorForwardB_Callback(hObject, eventdata, handles)
% hObject    handle to anteriorForwardB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in posteriorReverseB.
function posteriorReverseB_Callback(hObject, eventdata, handles)
% hObject    handle to posteriorReverseB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in dorsalUpB.
function dorsalUpB_Callback(hObject, eventdata, handles)
% hObject    handle to dorsalUpB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in ventralDownB.
function ventralDownB_Callback(hObject, eventdata, handles)
% hObject    handle to ventralDownB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in lateralRightB.
function lateralRightB_Callback(hObject, eventdata, handles)
% hObject    handle to lateralRightB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in medialLeftB.
function medialLeftB_Callback(hObject, eventdata, handles)
% hObject    handle to medialLeftB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




function directControlStepSizeS_Callback(hObject, eventdata, handles)
% hObject    handle to directControlStepSizeS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of directControlStepSizeS as text
%        str2double(get(hObject,'String')) returns contents of directControlStepSizeS as a double
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in findTipB.
function findTipB_Callback(hObject, eventdata, handles)
% hObject    handle to findTipB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in findCellB.
function findCellB_Callback(hObject, eventdata, handles)
% hObject    handle to findCellB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




function pipetSpeedS_Callback(hObject, eventdata, handles)
% hObject    handle to pipetSpeedS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pipetSpeedS as text
%        str2double(get(hObject,'String')) returns contents of pipetSpeedS as a double
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



% --- Executes on button press in useFakeDataCB.
function useFakeDataCB_Callback(hObject, eventdata, handles)
% hObject    handle to useFakeDataCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(handles.figure1, 'UserData');

udat.usingFakeData = get(hObject,'Value') ;

set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




function targetBufferRadiusS_Callback(hObject, eventdata, handles)
% hObject    handle to targetBufferRadiusS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetBufferRadiusS as text
%        str2double(get(hObject,'String')) returns contents of targetBufferRadiusS as a double
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)






function approachStepSizeS_Callback(hObject, eventdata, handles)
% hObject    handle to approachStepSizeS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of approachStepSizeS as text
%        str2double(get(hObject,'String')) returns contents of approachStepSizeS as a double
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




function pipetAngleS_Callback(hObject, eventdata, handles)
% hObject    handle to pipetAngleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pipetAngleS as text
%        str2double(get(hObject,'String')) returns contents of pipetAngleS as a double

udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




function xScaleS_Callback(hObject, eventdata, handles)
% hObject    handle to xScaleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xScaleS as text
%        str2double(get(hObject,'String')) returns contents of xScaleS as a double
udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)



function yScaleS_Callback(hObject, eventdata, handles)
% hObject    handle to yScaleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yScaleS as text
%        str2double(get(hObject,'String')) returns contents of yScaleS as a double

udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)




function zScaleS_Callback(hObject, eventdata, handles)
% hObject    handle to zScaleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zScaleS as text
%        str2double(get(hObject,'String')) returns contents of zScaleS as a double

udat = get(handles.figure1, 'UserData');





% update udat
set(handles.figure1,'UserData', udat);
%update handles
guidata(hObject,handles)


%

%% ~~~~~~~~~~~~~~  ONLY CREATION FUNCTIONS BELOW ~~~~~~~~~~~~~~~~~
%
%
%% --- Executes during object creation, after setting all properties.
function approachStepSizeS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to approachStepSizeS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pipetSpeedS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pipetSpeedS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function directControlStepSizeS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directControlStepSizeS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function manipulatorCoordinatesPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to manipulatorCoordinatesPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function continuousSingleStepPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to continuousSingleStepPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function forwardBackwardPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forwardBackwardPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function targetBufferRadiusS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetBufferRadiusS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pipetAngleS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pipetAngleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function xScaleS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xScaleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function yScaleS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yScaleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function zScaleS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zScaleS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function normalizationT_Callback(hObject, eventdata, handles)
% hObject    handle to normalizationT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of normalizationT as text
%        str2double(get(hObject,'String')) returns contents of normalizationT as a double


% --- Executes during object creation, after setting all properties.
function normalizationT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to normalizationT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tipChannelPM.
function tipChannelPM_Callback(hObject, eventdata, handles)
% hObject    handle to tipChannelPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tipChannelPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tipChannelPM


% --- Executes during object creation, after setting all properties.
function tipChannelPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipChannelPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cellChannelPM.
function cellChannelPM_Callback(hObject, eventdata, handles)
% hObject    handle to cellChannelPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cellChannelPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cellChannelPM


% --- Executes during object creation, after setting all properties.
function cellChannelPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellChannelPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function autoStopT_Callback(hObject, eventdata, handles)
% hObject    handle to autoStopT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autoStopT as text
%        str2double(get(hObject,'String')) returns contents of autoStopT as a double


% --- Executes during object creation, after setting all properties.
function autoStopT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoStopT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function depthCompString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depthCompString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
