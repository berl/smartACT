function  out = brl_radial_adjust(trajectory, currentIndex, tipEstimate)
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
%  this function generates a radial tip correction based on 
%               the planned trajectory, 
%               the current index corresponding to a point along the
%               planned trajectory
%           and
%               the estimated tip location (should be from current image data)


%  First, estimate the trajectory unit vector at the points near the
%  presumed tip location.

if currentIndex==1
    out = []
    'approach angle invalid at starting point'
    return
end

pipDiff = trajectory(currentIndex+1,:)-trajectory(currentIndex-1,:);
pipHat = pipDiff./sqrt(sum(pipDiff.^2,2));


%  Then measure the delta between the presumed tip
%  location and the tipEstimate.

toEstimate = tipEstimate-trajectory(currentIndex,:);

% now resolve the delta into radial and axial components.

%axial:
deltaAxial = pipHat.*sum(pipHat.*toEstimate);
% and radial
deltaRad = toEstimate-deltaAxial;


%  instead of just returning the radial component, return

out.delta = toEstimate;%   the full delta vector
out.deltaRad = deltaRad;%   the radial component  as a 3 vector
out.deltaAxial = deltaAxial;%   the axial component as a 3 vector
out.distRad = sqrt(sum(deltaRad.^2,2));% . the radial and axial (signed) distances.
out.distAxial = sqrt(sum(deltaAxial.^2,2))*sign(sum(pipHat.*toEstimate));


%  How does this compare to the closest point between tipEstimate and the
%  whole trajectory?  

alldistances = sqrt(sum(repmat(tipEstimate,size(trajectory,1)-1,1)-trajectory(2:end,:),2));  % ignore the first point- may somehow be closer under
                                                                % weird/bad
                                                                % circumstances
out.closestIndex = find(alldistances == min(alldistances))+1 ;  %add 1 because I've omitted the first point of the full trajectory
otherDistance = tipEstimate-trajectory(out.closestIndex(1),:);

out.delta2 = otherDistance;
% radial
out.delta2Axial = pipHat.*sum(pipHat.*out.delta2);
out.delta2Rad = out.delta2-out.delta2Axial;
out.dist2Rad = sqrt(sum(out.delta2Rad.^2,2));
out.dist2Axial = sqrt(sum(out.delta2Axial.^2,2))*sign(sum(pipHat.*out.delta2));
 






