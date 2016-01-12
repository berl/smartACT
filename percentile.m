function out = percentile(input, prcnt)
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
sorted = sort(input(:));
index = floor((prcnt)*numel(input));
if index==0
    out = [];
else
    
out = sorted(index);
end
end