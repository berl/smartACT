function varargout = spApproachLogger(varargin)
% SPAPPROACHLOGGER MATLAB code for spApproachLogger.fig
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
%      SPAPPROACHLOGGER, by itself, creates a new SPAPPROACHLOGGER or raises the existing
%      singleton*.
%
%      H = SPAPPROACHLOGGER returns the handle to a new SPAPPROACHLOGGER or the handle to
%      the existing singleton*.
%
%      SPAPPROACHLOGGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPAPPROACHLOGGER.M with the given input arguments.
%
%      SPAPPROACHLOGGER('Property','Value',...) creates a new SPAPPROACHLOGGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spApproachLogger_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spApproachLogger_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spApproachLogger

% Last Modified by GUIDE v2.5 28-Aug-2014 14:27:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @spApproachLogger_OpeningFcn, ...
    'gui_OutputFcn',  @spApproachLogger_OutputFcn, ...
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


% --- Executes just before spApproachLogger is made visible.
function spApproachLogger_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spApproachLogger (see VARARGIN)
handles;
% Choose default command line output for spApproachLogger
handles.output = hObject;
hsmartACT = findobj('name','smartACT');
udat = get(hsmartACT,'UserData');
udat.fHandles.updateLoggerPlot = @updateplot;
udat.fHandles.oneShotLog = @oneshotlog;
udat.loggerTimer = timer('TimerFcn', {@brl_manual_datalogger, handles},'Period',1,...
    'ExecutionMode','FixedSpacing' , 'name', 'loggerTimer');

axes(handles.axes1);
cla
hold on
colormap(jet(100));
udat.appLogColorBarh =  colorbar;
udat.myCMap = colormap(jet(100));
% tell the smartACT that the logger is in effect...
udat.approachLoggerh = handles.approachLogger;
udat.appLogLineh =  line('parent',udat.appLogColorBarh, 'xdata', [-5 5], 'ydata', [25 25], 'linewidth', 4, 'color', [0 0 0],'tag','myLine');
aLUD.isLogging = 0;
aLUD.saveAndReset=0;
aLUD.fHandles.startButton = @saveAndResetButton_Callback;
aLUD.sbHandle = handles.saveAndResetButton;
% load initialdata into the table
set(handles.positionDataTable, 'Data', [[ -1 -1 -1],clock])



% now do the initial plotting
% initial positions
% pipet, tip and cell

if ~isfield(udat, 'Locations') 
    iTip = [0 0 0]
    iPia = [0 0 0]
    iCell = [0 0 0 ]
    trajectory = [ 0 0 0]
    currentLoc = [0 0 0]
    targetLoc = [0 0 0]
else
    
iTip = udat.Locations.pipetTip;
iPia = udat.Locations.pia;
iCell= udat.Locations.cell;
% adjusted target location
targetLoc = [udat.Target(1:2)+iTip(1:2) udat.Target(3)+iTip(3)];
%  full planned trajectory
trajectory = [-udat.CalculatedPath(:,1), -udat.CalculatedPath(:,2), udat.CalculatedPath(:,3)]+repmat(iTip, size(udat.CalculatedPath,1),1);
% current location
currentLoc = [-udat.CurrentLocation(1:2) udat.CurrentLocation(3)]+iTip;
end
% plot these basic things
plot3(iTip(1), iTip(2), iTip(3), 'or', 'linewidth', 4)

plot3(iPia(1), iPia(2), iPia(3), 'xy', 'linewidth', 4)
plot3(targetLoc(1), targetLoc(2), targetLoc(3), 'or', 'markersize', 14)
plot3(trajectory(:,1), trajectory(:,2), trajectory(:,3), '.-g', 'linewidth', 2, 'markersize', 10)


% keep track of these handles- they'll be updated later

udat.hPlotTip= plot3(currentLoc(1), currentLoc(2), currentLoc(3), '^b', 'markersize', 14, 'linewidth', 4, 'displayname', 'currentlocation');
udat.hPlotCell = plot3(iCell(1), iCell(2), iCell(3), 'or', 'linewidth', 4);



udat.hActualTip= plot3(0, 0, 0, 'mx', 'markersize', 1,'displayname', 'currentTipMicrons');
udat.hActualCell= plot3(0, 0, 0, 'mo', 'markersize', 1,'displayname', 'currentCellMicrons');

%put little dots at the image image boundaries

xvals= udat.xScale*[0 udat.imagesize(1)];
yvals= udat.yScale*[0 udat.imagesize(2)];
zvals=  udat.zScale*[0 udat.imagesize(3)];
plot3(xvals,[yvals(1) yvals(1)], [zvals(1) zvals(1)], 'o-y')
plot3(xvals,[yvals(2) yvals(2)], [zvals(1) zvals(1)], 'o-y')
plot3(xvals,[yvals(2) yvals(2)], [zvals(2) zvals(2)], 'o-y')
plot3(xvals,[yvals(1) yvals(1)], [zvals(2) zvals(2)], 'o-y')

plot3([xvals(1) xvals(1)],yvals , [zvals(1) zvals(1)], 'o-y')
plot3([xvals(2) xvals(2)],yvals ,[zvals(1) zvals(1)], 'o-y')
plot3([xvals(2) xvals(2)],yvals , [zvals(2) zvals(2)], 'o-y')
plot3([xvals(1) xvals(1)],yvals , [zvals(2) zvals(2)], 'o-y')

plot3([xvals(1) xvals(1)],[yvals(1) yvals(1)] ,zvals, 'o-y')
plot3([xvals(1) xvals(1)],[yvals(2) yvals(2)] ,zvals, 'o-y')
plot3([xvals(2) xvals(2)],[yvals(2) yvals(2)] ,zvals, 'o-y')
plot3([xvals(2) xvals(2)],[yvals(1) yvals(1)] ,zvals, 'o-y')



%            set(gca,'xlim',  udat.xScale*[0 udat.imagesize(1)])
%            set(gca,'ylim',  udat.yScale*[0 udat.imagesize(2)])
%            set(gca,'zlim',  udat.zScale*[0 udat.imagesize(3)])
set(gca,'color', [.3 .3 .3])
hold off
% z direction
set(gca,'zdir', 'reverse')
set(gca,'ydir', 'reverse')
xlim([min(trajectory(:,1)), xvals(2)+10])
ylim([-50 yvals(2)+10])
zlim([-10 zvals(2)+10])
axis equal





udat.hspPipetteOriginS = handles.pipetteOriginS;
udat.hspCurrentPositionS = handles.currentPositionS;
udat.hspTargetLocationS=handles.targetLocationS;
udat.hspTrajectoryIndexS = handles.trajectoryIndexS;
udat.hspOriginalCellCenterS = handles.originalCellCenterS;
udat.hResistanceAxes = handles.axes2;
axes(handles.axes2)
udat.hResistancePlot =plot([ 0 1], [0 1],'o-r');





set(hObject, 'UserData', aLUD);
set(hsmartACT,'UserData',udat);

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes spApproachLogger wait for user response (see UIRESUME)
% uiwait(handles.spApproachLogger);


% --- Outputs from this function are returned to the command line.
function varargout = spApproachLogger_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in saveAndResetButton.
function saveAndResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAndResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hsmartACT = findobj('name','smartACT');
 udat = get(hsmartACT,'UserData');

% this button switches between 'start Logging' and 'Stop Logging /rt save
% and Reset'
aLUD=get(handles.approachLogger,'UserData');


if ~isfield(aLUD,'isLogging')
    aLUD.isLogging = 0;   % fudat.islogging will switch between 0 (not logging)  1  (logging) and  -1 (save and reset)
    aLUD.saveAndReset=0;
end



switch aLUD.isLogging
    case 0
        
        aLUD.isLogging=1;
        set(hObject,'String', '<html>Stop Logging','BackgroundColor',[1 0 0])
        
        
    case 1
        set(hObject,'String', 'Save and Reset','BackgroundColor', [0 1 1])
        aLUD.isLogging=-1;
    case -1
        aLUD.saveAndReset=1;
        aLUD.isLogging=0;
        set(hObject,'String', 'Start Logging','BackgroundColor', [0 1 0])
end





% this GUI doesn't actually do any active logging- accessing the MP-285 is
% enough of a headache as it is
% and doing logging here would require another timer and asynchronous
% polling of a field populated by whoever is actually running the MP-285

%  so other objects populate the log data in this GUI






if aLUD.saveAndReset
    %  check the main approach GUI for a directory, etc...
    if ~isempty(hsmartACT)
        

        
        %%%  this saving code here is basically identical to that in the main
        %%%  smartACT, but uses Log.mat as the postfix. there is an independent
        %%%  check to avoid overwriting files, so there shouldn't be any problem,
        %%%  but THE INDEX IS LOCKED TO THAT IN THE MAIN GUI so there is some
        %%%  coarse correspondence between the automatically saved state
        %%%  information and this log
        %%%
        if ~isfield(udat,'savedir')
            [dirname]= uigetdir('E:\Data\','Select save directory');
            udat.savedir = dirname;
            udat.saveIndex = 0;
        end
        savefilenamehandle = findobj('tag', 'saveFilename');
        udat.savefilename = [get(savefilenamehandle, 'String'), sprintf('%04d', udat.saveIndex), 'Log.mat'];
        testfilename = fullfile(udat.savedir, udat.savefilename);
        while numel( dir(testfilename))>0
            udat.saveIndex = udat.saveIndex+1;
            udat.savefilename = [get(savefilenamehandle, 'String'), sprintf('%04d', udat.saveIndex), 'Log.mat'];
            testfilename = fullfile(udat.savedir, udat.savefilename);
        end
        tosavetable = get(handles.positionDataTable,'Data');
        save(testfilename,'tosavetable')
        udat.saveIndex=udat.saveIndex+1;
        
        % now clear out the table
        set(handles.positionDataTable,'Data', [ [-1 -1 -1], clock])
        
        % now turn this off because we've saved the data- next buttonclick should
        % just start the logging.
        aLUD.saveAndReset=0;   %
    end
    
    
%    clear the resistance plot too
axes(udat.hResistanceAxes)
udat.hResistancePlot=plot([0 1], [0 1]);
    
    % update the user data in the main smartACT
    set(hsmartACT, 'UserData', udat)
    
end


set(hsmartACT, 'UserData', udat)
set(handles.approachLogger,'UserData' ,aLUD)
guidata(hObject, handles);


% --- Executes on button press in oneShotLogButton.
function oneShotLogButton_Callback(hObject, eventdata, handles)
% hObject    handle to oneShotLogButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateplot()
oneshotlog()

% --- Executes on button press in updatePlotButton.
function updatePlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to updatePlotButton (see GCBO
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateplot()




function updateplot(~)
hsmartACT = findobj('name','smartACT');
hspApproachLogger = findobj('name', 'spApproachLogger');
udat = get(hsmartACT,'UserData');
iTip = udat.Locations.pipetTip;
iPia = udat.Locations.pia;
iCell= udat.Locations.cell;

global axon285


%     try
%         moving = axon285.isMoving;
%     catch
%         'moving'
%         moving = true;
%     end
%     if ~moving
%         pause(.1)
%         udat.CurrentLocation = axon285.positionRelative
%     else
%         return
%     end
%     


if ~isfield(udat, 'noMCC')
    udat.noMCC=0;
end

if ~udat.noMCC 
try
udat.MCCdata =brl_get_MCC_values;
catch
    udat.noMCC = 1;
    'no MCC data available...'
    udat.MCCdata = [ 0 0 0 0];
end
else
    
    udat.MCCdata = [0 0 0 0];
end
cmapmult = 10^6;
    
cmapindex = max(min(floor(udat.MCCdata(1)/cmapmult), size(udat.myCMap,1)),1);
set(udat.hPlotTip,'xdata', -udat.CurrentLocation(1)+iTip(1), 'ydata', -udat.CurrentLocation(2)+iTip(2), 'zdata', udat.CurrentLocation(3)+iTip(3), 'color', udat.myCMap(cmapindex,:) )
set(udat.hPlotCell,'color', rand(1,3)), % 'xdata', -udat.CurrentLocation(1)+iTip(1), 'ydata', -udat.CurrentLocation(2)+iTip(2), 'zdata', udat.CurrentLocation(3)+iTip(3))
set(udat.appLogLineh, 'xdata', [-5 5], 'ydata', udat.MCCdata(1)/cmapmult*[1 1], 'linewidth', 4, 'color', [1 1 1])

% and the updated tip location

if isfield(udat, 'currentTipMicrons')
     set(udat.hActualTip, 'xdata', udat.currentTipMicrons(1), 'ydata', udat.currentTipMicrons(2), 'zdata',  udat.currentTipMicrons(3), 'color', [rand(1), 0, rand(1)], 'markersize', 20,'displayname', 'currentTipMicrons')
 end
if isfield(udat,'currentCellMicrons')
     set(udat.hActualCell,'xdata', udat.currentCellMicrons(1), 'ydata', udat.currentCellMicrons(2),'zdata', udat.currentCellMicrons(3),  'color', [.8 0 .5], 'markersize', 20,'displayname', 'currentCellMicrons')
end

% now update the text fields showing current and target locations:

% polulate text fields with data.
set(udat.hspPipetteOriginS, 'string', [ num2str(udat.StartingPoint,'%.2f   ')]);
set(udat.hspCurrentPositionS,  'string',[num2str(udat.CurrentLocation,'%.2f   ')]);
set(udat.hspTargetLocationS , 'string', [num2str(udat.CalculatedPath(end,:),'%.2f   ')]);
set(udat.hspTrajectoryIndexS, 'string', [' [',num2str(udat.currentIndex), '] out of [',num2str(size(udat.CalculatedPath,1)) ,'] positions'])
set(udat.hspOriginalCellCenterS,  'string',[ num2str([-udat.rawTarget(1), -udat.rawTarget(2), udat.rawTarget(3)],'%.2f   ')]);
%set(hspApproachLogger.piaDepthString, 'string', ['  ', num2str(udat.pialDepthRel(3)), ' um'])

udat.currentTipMicrons = udat.CurrentLocation;
        micronImageLoc = [-udat.currentTipMicrons([1 2]) udat.currentTipMicrons(3)]  +      [iTip([1 2])  iTip(3) ] ;
        udat.currentTipImage = micronImageLoc([2 1 3])./[udat.xScale udat.yScale udat.zScale];




set(hsmartACT, 'UserData', udat)

function oneshotlog(~)
hsmartACT = findobj('name','smartACT');
udat = get(hsmartACT,'UserData'); 
logdat = get(udat.approachLoggerh,'UserData');
cmapmult = 10^7;
udat;




if logdat.isLogging==1

if ~isfield(udat, 'noMCC')
    udat.noMCC=0;
end

if ~udat.noMCC 
try
udat.MCCdata =brl_get_MCC_values;
catch
    udat.noMCC = 1;
    'no MCC data available...'
    udat.MCCdata = [ 0 0 0 0];
end
else
    
    udat.MCCdata = [0 0 0 0];
end

    aLDataTable= findobj(udat.approachLoggerh,'tag','positionDataTable');
    %
    logdat = get(aLDataTable,'Data');
    currentdat = [udat.CurrentLocation, udat.MCCdata, clock];
    if size(currentdat,2)~=size(logdat,2)
        logdat=[]
    end
    
    logdat=[currentdat;logdat];
    set(udat.appLogLineh, 'xdata', [-5 5], 'ydata', currentdat(4)/cmapmult*[1 1], 'linewidth', 4, 'color', [1 1 1])
    set(aLDataTable,'Data', logdat)
    reltime = logdat(:,end-2:end) - repmat(logdat(end,end-2:end), size(logdat,1),1);
    set(udat.hResistancePlot,'xdata',reltime(:,3)/60+reltime(:,2)+(reltime(:,1))*60 ,'ydata', logdat(:,4))
end
set(hsmartACT, 'UserData', udat)


% --- Executes on button press in logManualData.
function logManualData_Callback(hObject, eventdata, handles)
% hObject    handle to logManualData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% start an independent timer that should ONLY be running when the
% manipulator is being manually controlled...
hsmartACT = findobj('name','smartACT');
udat = get(hsmartACT,'UserData');

if strcmp(get(udat.loggerTimer,'running'),'off')==1

    start(udat.loggerTimer), set(handles.logManualData, 'backgroundcolor',[1 0 0], 'string', 'STOP manual data logging')
    
else
    
    stop(udat.loggerTimer),  set(handles.logManualData, 'backgroundcolor',[0 1 0], 'string', 'START manual data logging')
    
end
