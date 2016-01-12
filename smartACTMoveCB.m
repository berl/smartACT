function smartACTMoveCB(obj,event, handles)

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
%  BRL 2014.06-25   add logging to approachLogger if it's around.

% Brian Long 2014.03-04
% function to execute a series of moves without hanging up the command line
% or scanimage (... I hope )

% the data will be stored in the timer's userdata in these fields

% timer.userData.trajectory
% timer.userData.currentIndex
% timer.userData.direction      -1 for retract, 1 for forward
% timer.userData.isFinished
% timer.userData.velocity   is user-entered velocity
% timer.userData.fastVelocity is the fast velocity for the first 3 moves
hhh=0;

global axon285 spStackdata

movingcheck = 0;
timerdat = obj.userdata;
maxindex = size(timerdat.trajectory,1);
% callback  returns the current position if the stage isn't moving
try
    movingcheck=axon285.isMoving;
catch
    movingcheck=1;
end

set(handles.statusT,'String', '', 'foregroundcolor', [1 0 0])
udat = get(findobj('name', 'smartACT'), 'UserData');    
iTip = udat.Locations.pipetTip;

if ~movingcheck;%moving
    movedone=0 ;
    while ~movedone
        if (timerdat.currentIndex<=maxindex )  && (timerdat.currentIndex >= 1 ) &&  ~(timerdat.isFinished)
            
            
            % there is a slight problem with timing here. somehow the
            % 'ismoving' check doesn't deal with the serial communication delay
            % (?)  or something, resulting in a serial error and subsequently
            % getting kicked out of this callback and stopping the timer.
            
            try
                
                %tic
                lastLoc = axon285.positionRelative;
                %toc
                hhh = hhh+10;
            catch
                set(handles.statusT,'String', 'IN MOTION', 'foregroundcolor', [0 .5+.5*rand(1) .5+.5*rand(1)])
                pause(.001)
                hhh  =hhh+1
                continue
            end
            movedone=1;
            
            
            % index is OK for the actual move
            
            %  for the first 6 positions, I want to move quickly.  This should
            %  end 40um below the starting point
            if timerdat.currentIndex<=6
                axon285.velocity = timerdat.fastVelocity;
            else
                axon285.velocity = timerdat.velocity;
            end
            % also exit the brain at 1.5x velocity
            if timerdat.direction<1 & timerdat.currentIndex>5 
                axon285.velocity = 1.5*timerdat.velocity;
            end
            
            
            set(handles.statusT,'String', 'IN MOTION', 'foregroundcolor', [1 .5*rand(1) .5*rand(1)])
            
            nextmove= timerdat.currentIndex;
            
            
            %axon285.moveCompleteRelative(timerdat.trajectory(timerdat.currentIndex,:))
            udat.currentIndex = timerdat.currentIndex;
            % THIS TRY CATCH STATEMENT is to allow testing on a fake
            % axon285 
            if udat.fakeAxon285 == 0
                axon285.moveStartRelative(timerdat.trajectory(timerdat.currentIndex,:))
            else
                axon285.positionRelative = timerdat.trajectory(timerdat.currentIndex,:)+randn(1,3);
            end
            if timerdat.currentIndex+ timerdat.direction > maxindex
                timerdat.isFinished=1;
                % save the .mat file!
                
                if ~isfield(udat,'directory')
                    [dirname]= uigetdir('E:\Data\','Select save directory');
                    udat.savedir = dirname;
                else
                    udat.savedir = udat.directory;
                end
                
                if ~isfield(udat, 'saveIndex')
                    udat.saveIndex = 0;
                end
                
                
                udat.savefilename = ['spData', sprintf('%04d', udat.saveIndex), '.mat'];
                testfilename = fullfile(udat.savedir, udat.savefilename);
                while numel( dir(testfilename))>0
                    udat.saveIndex = udat.saveIndex+1;
                    udat.savefilename = ['spData', sprintf('%04d', udat.saveIndex), '.mat'];
                    testfilename = fullfile(udat.savedir, udat.savefilename);
                end
                save(testfilename, 'udat', 'timerdat','spStackdata' );
                udat.savetime = datestr(clock);
                udat.saveIndex=udat.saveIndex+1;
                udat.CurrentLocation = lastLoc;

                %
                set(handles.figure1,'UserData', udat);
                
                set(obj, 'userdata', timerdat)
                stop(obj)
            elseif timerdat.currentIndex+timerdat.direction <1
                udat.CurrentLocation = lastLoc;
                timerdat.isFinished=1;
                set(obj, 'userdata', timerdat)
                stop(obj)
            else
                timerdat.currentIndex = timerdat.currentIndex+timerdat.direction;
                % update the gui userdata  via the handles
                udat.CurrentLocation = lastLoc;
                    
                
                
                
                set(handles.figure1, 'userdata', udat);
                set(obj, 'userdata', timerdat)
            end
            
            
        else
            timerdat.isFinished=1;
            set(obj, 'userdata', timerdat)
            stop(obj)
        end
        udat.CurrentLocation = lastLoc;
        udat.currentTipMicrons = lastLoc;
        micronImageLoc = [-udat.currentTipMicrons([1 2]) udat.currentTipMicrons(3)]  +      [iTip([1 2])  iTip(3) ] ;
        udat.currentTipImage = micronImageLoc([2 1 3])./[udat.xScale udat.yScale udat.zScale];
        get(handles.figure1)
set(findobj('name', 'smartACT'), 'UserData',udat);


        
        if -udat.CurrentLocation(1)+iTip(1) > 30 % 30um from edge of the stack
            
            set(handles.statusT,'string', 'pipet in stack', 'backgroundcolor',[0 1 .8] )
        elseif udat.CalculatedPath(end,3)-udat.CurrentLocation(3) < 50  % 50um above depth of the cell
            set(handles.statusT,'string', 'reduce pressure! ', 'backgroundcolor',[0 1 .8] )
        else
            set(handles.statusT,'string', '', 'backgroundcolor',[0.5 .5 .5] )
        end
                
        if udat.CalculatedPath(end,3)-udat.CurrentLocation(3) < 25 && udat.autostopped == 0
            feval(udat.fhandles.stopStartCB, udat.goStopBh, [], guidata(udat.goStopBh));
           set(handles.statusT,'String', 'AUTO-STOPPED', 'foregroundcolor', [0 .5*rand(1) .5*rand(1)])

            udat.autostopped = 1;            
            udat.tipCellUpdateh = evalin('base', 'brl_tip_cell_update'); % call brl_tip_cell_update
            set(findobj('name', 'smartACT'), 'UserData',udat);
            % 
        end

        
        
    end
else
    'in motion'
    set(handles.statusT,'String', 'IN MOTION', 'foregroundcolor', [1 .5*rand(1) .5*rand(1)])
    
end


set(findobj('name', 'smartACT'), 'UserData',udat);

        feval(udat.fHandles.updateLoggerPlot)
        feval(udat.fHandles.oneShotLog)
        



%%  just separate out this function for readability
    function logmove(~)
       
        logdat = get(udat.approachLoggerh,'UserData');
        if logdat.isLogging==1
aLDataTable= findobj(udat.approachLoggerh,'tag','positionDataTable');
            %
            logdat = get(aLDataTable,'Data');
           currentdat = [udat.CurrentLocation, udat.MCCdata, clock];
           if size(currentdat,2)~=size(logdat,2)
               logdat=[]
           end
           
            logdat=[currentdat;logdat];
           set(udat.appLogLineh, 'xdata', [-5 5], 'ydata', currentdat(4)/200000*[1 1], 'linewidth', 4, 'color', [1 1 1])
            udat.timesthrough = udat.timesthrough+1;
            set(aLDataTable,'Data', logdat)
        end
    end






end

