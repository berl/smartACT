function out = brl_manual_datalogger(obj, eventdata, handles)


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
% 2014.08.20
% independent function to access axon285 coordinates and MCC data
happroachGUI = findobj('name','approachGUI');
udat = get(happroachGUI,'UserData');
global axon285



movingcheck = 0;
try
    movingcheck=axon285.isMoving;
catch
    movingcheck=1;
end

if ~movingcheck
    
out.currentposition = axon285.positionRelative;



                udat.CurrentLocation = out.currentposition;  
                set(happroachGUI, 'UserData',udat);
        feval(udat.fHandles.updateLoggerPlot)
        feval(udat.fHandles.oneShotLog)
        

end