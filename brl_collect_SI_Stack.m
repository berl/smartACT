function out = brl_collect_SI_Stack(startz, stopz)
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
% 2014.09.10  update for spStackdatastruct

% 2014.08.27  BRL mod to deal with improved stack data global variable
% called spStackdata

% 2014.08.17  function to collect scanimage stack using all of the current
% parameters but with the user-supplied start and stop positions.

%  startz and stopz should be motor RELATIVE coordinates in microns, just
%  like the fields shown on the SI MOTOR CONTROLS GUI


% 1. get the necessary handles.   scanimage stores most of the data as
% globals, so it's not too hard

global state gh spStackdata
%  handle to MOM motor:
mh = state.motor.hMotor;


% handle to current start and stop positions




%  handle to 'set' button for start  position
setStarth = gh.motorControls.pbSetStart
% and associated callback function
setStartCB = get(setStarth,'Callback')




% handle to 'set' button for end position
setEndh = gh.motorControls.pbSetEnd
% and associated callback function
setEndCB = get(setEndh,'Callback')



% handle to 'GRAB' button
grabStackh=gh.motorControls.pbGrabOneStack
% and associated callback
grabStackCB= get(grabStackh, 'Callback')

% 
% % Construct a questdlg with two options
% choice = questdlg(['Planned coordinates : [', num2str(spStackdata.origPos(1:2)), '     < ', num2str(startz), ' - ', num2str(stopz),'  > microns'], ...
% 	'SI substack warning', ...
% 	'OK','abort!','abort!');
% % Handle response
% switch choice
%     case 'OK'
%         
%     case 'abort!'
% out = 0;
% return
% end
% 


% now drive the motor to the first position
mh.moveCompleteRelative([spStackdata.origPos(1:2), startz]) ;  % keep same x and y, use new z
% set this as the stack start
feval(setStartCB, setStarth, []) 


%  drive motor to second position  
mh.moveCompleteRelative([spStackdata.origPos(1:2), stopz]) ;  % keep same x and y, use new z
% set this as the stack end
feval(setEndCB, setEndh, []) 

% set the power

state.init.eom.maxPower =spStackdata.origMaxPower;


% grab the stack
feval(grabStackCB, grabStackh, [])
out  = 1;

