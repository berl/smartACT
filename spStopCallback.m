function spStopCallback(obj,event, handles)

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

% cleanup function that is mostly to handle when the timer quits due to  errors from the moveCallback,
% like timeouts, etc

% just change the button! 
set(handles.goStopB, 'backgroundcolor',[0 1 0], 'string', 'GO')
    
    set(handles.statusT,'String', '', 'foregroundcolor', [1 0 0])
timerdat = obj.userdata;
 timerdat.isFinished=0;
                 set(obj, 'userdata', timerdat)
