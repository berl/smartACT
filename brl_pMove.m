function out = brl_pMove(startpos, endpos, pipetteangle, maxS, override)
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
% BRL 2014.01.21  function to check moves from start pos to endpos

% 					out is an Nx3 array which is the sequence of POSITIONS along pipetteangle 
% 					that will get from startpos to endpos without exceeding the max
%                   displacement maxS in any one step.  
%                   
%   				The input delta  (endpos-startpos) is projected along
%   				the positive pipette direction and only the delta along
%   				the pipette is kept.  This distance is then broken up
%   				into segments of length maxS if needed.

%  if endpos is a scalar instead of a 3D location, it is treated as a
%  distance ALONG THE DIAGONAL

%                   override == 1 IGNORES ONLY          maxS
%                   override == 2 IGNORES ONLY          pipetteangle
%                   override == 3 IGNORES BOTH  maxS and pipetteangle,
%                   which will just return the endpos input, but it may be
%                   convenient sometimes.

%            		NOTES:
%                  * ALL length INPUTS MUST BE IN MICRONS, pipetteangle
%                  in degrees.
out =[];



if nargin<5
override = 0;
end

if nargin <4
return
end


if override==3
    out = endpos;
    return
end

if numel(endpos)==1
    scalaradvancemode= 1;
else
    scalaradvancemode=0;
end



% angle in radians
radAngle = pi*pipetteangle/180;

% delta
delta = endpos-startpos;

% unit vector for the pipet:

ePip = [cos(radAngle), 0, sin(radAngle)];
ePip  = ePip/sum(ePip.*ePip);



if scalaradvancemode
    dotProduct = endpos;
    projDel = dotProduct*ePip;
    projDelLength = endpos;
    
else
  
% now the projection along ePip:
dotProduct = sum(delta.*ePip);
projDel = dotProduct*(ePip);
projDelLength = sqrt(sum(projDel.*projDel));
end



if override==1
    out = projDel+startpos;
return
end


if projDelLength > maxS
    
    sPoints = 0:(maxS*sign(dotProduct)):(projDelLength*sign(dotProduct));
    % skip 2nd to last point so that the last step is long, not short.
    sPoints=sPoints(1:end-1);
    sPoints(end+1) = (projDelLength*sign(dotProduct));
    out = sPoints(2:end)'*ePip;
    out(:,1) = out(:,1)+startpos(1);
    out(:,2) = out(:,2)+startpos(2);
    out(:,3) = out(:,3)+startpos(3);
else
    out = projDel;
end

    
    

