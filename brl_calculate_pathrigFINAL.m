function out = brl_calculate_pathrigFINAL(startpos, targetpos, pipetAngle, stepsize, bufferRadius, retractFirst)
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
%  BRL 2014.08.13   added parameter 'retractFirst', 
%   retractFirst == 1    modifies the calculated path to move diagonally out of
%  the agarose, then make lateral adjustments, then move diagonally to the
%  starting point (still above the agarose)


% 
% brl2014.03.19 added bufferRadius, changed file and function name and GOT
% RID OF A 'rig-specific' change that required relative paths from [0 0 0]
% brl2014.03.18  added stepsize variable
% brl 2014.02.19  reduced step size to 2um

% brl 2014.01.24 swapped sign of x to match axon mp285

% BRL 2014.01.23 
%  function returns Nx3 array of positions to be done as sequential moves
%  from startpos to targetpos, where startpos is ABOVE THE TISSUE.

%  ALL POSITIONS ARE IN MICRONS, pipetAngle IN DEGREES

% NB:   'diagonal' means along the axis of the pipet, and 's' is the
%         diagonal coordinate

% the trajectory consists of 
%                      1. entrypoint a single move from the current position to the
%                           calculated entry point, constant z
%                      2. entry: a few moves diagonal from the entry point to a point 100
%                         um down. (this is still the  'fast' phase)
%                      3. approach:  series of s=10um diagonal moves until the pipet
%                           is 15 um from the selected target.
%

%

if nargin <4
    stepsize = 2; % default step size in final approach
end



radPipetAngle = pi*pipetAngle/180;  % convert to radians
reltarget = targetpos-startpos;  % relative displacement between start and target
relout = [0,0,0]; % intialize the relative path with just the current location (relative displacement = 0)

agarosedepth = 200/sin(radPipetAngle); % estimated agarose depth- 


%  now the various move phases:

% the entry point is located at x= -dz*cos(theta)/sin(theta) from the current
% location

entrypoint = [reltarget(1)-reltarget(3)*cos(radPipetAngle)/sin(radPipetAngle), reltarget(2), 0];

% retraction point for retractFirst case:  line from entry point, along
% pipet to a defined distance above the original z depth

retractionpoint = brl_pMove(entrypoint,entrypoint+[0 0 -agarosedepth], pipetAngle-180, 1, 1); %override maximum step size, but move along prescribed angle to agarosedepth above the starting point.
retractionpoint = retractionpoint(end,:);


if retractFirst==0

%  1. single lateral move to entry point:

toentrypoint = brl_pMove(relout(1,:), entrypoint, pipetAngle, 1, 3); %generate new location in full override. this is just for consistency and 
                                                     % possible future work
                                                     % where brl_pMove
                                                     % would actually
                                                     % execute the move.


elseif retractFirst ==1
    
    %  retract along opposite of pipetAngle...

retractpath0 = brl_pMove(relout(1,:), relout(1,:)+[0 0 -agarosedepth], pipetAngle-180, 1, 1); %override maximum step size, but move along prescribed angle to 100um above the starting point.  
retractpath1 = brl_pMove(retractpath0(end,:), retractionpoint, pipetAngle, 1, 3);  %full override

entrypointsegment = brl_pMove(retractpath1(end,:), entrypoint, pipetAngle, 1, 3);  % again full override

toentrypoint = [retractpath0; retractpath1; entrypointsegment]; 

end
                                                     
                                                     
                                                     
                                                     
                                                     
                                                     
                                                     
%  2. entry:   40um down corresponds to a diagonal displacement s =
%  dz/sin(pipetangle);

entrysequence = brl_pMove(toentrypoint(end,:), 40/sin(radPipetAngle), pipetAngle, 20,0);  % move in 20um steps.


%  3. approach:

approach = brl_pMove(entrysequence(end,:), reltarget, pipetAngle, stepsize,0);

% but we don't want to be closer than bufferRadius to the target:
approach = approach( sqrt((approach(:,1)-reltarget(1)).^2 +(approach(:,2)-reltarget(2)).^2 + (approach(:,3)-reltarget(3)).^2)>bufferRadius,:);

relout = [relout; toentrypoint; entrysequence; approach];




out = [relout(:,1)+startpos(1), relout(:,2)+startpos(2), relout(:,3)+startpos(3)];
