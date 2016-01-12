function pipobjectStack = brl_identify_tip(binaryImage, parameters)
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

% 2014.09.01  if there are no input parameters or the pipet COM doesn't reside in the object,
%  just pick the largest object in the binary image
 
 s3d = bwlabeln(binaryImage);  % this assumes the pipet is a convex shape...
 

 pipobj = s3d(parameters.coordinates3D(1), parameters.coordinates3D(2), parameters.coordinates3D(3));
 
 if pipobj==0  %     in suboptimal cases, (pipet is not convex)
     %   the centroid can lie outside of the binary object.
     % if that's the case, pick the biggest object as the pipet
     mass=[]
     uregions = unique(s3d(s3d(:)>0))
     for i = 1:numel(uregions)
         mass=[mass; sum(s3d(:)==uregions(i))];
     end
     pipobj = uregions(mass==max(mass(:)))
     
 end
 
 pipobjectStack = s3d==pipobj;