function [im3, im2, im1] = brl_MIP_segmentation(imagestack, threshold) 
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
imagestack = smooth3(double(imagestack),'box', [3 3 1]);

t3 = squeeze(max(imagestack ,[],3));
t2 = squeeze(max(imagestack ,[],2));
t1 = squeeze(max(imagestack ,[],1));

% now segment using the threshold

athresh = threshold*max(imagestack(:));

im3 = bwlabel(t3>athresh);
im2 = bwlabel(t2>athresh);
im1 = bwlabel(t1>athresh);


