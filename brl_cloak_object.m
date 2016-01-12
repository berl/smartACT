function out = brl_cloak_object( imagedata, binarydata)
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
% 2014.09.01  simple function to remove segmented objects from an image stack,
% replacing their image contents with noise values from the perimeter
% region of the object.



%   extract that binary object, dilate
% it  and replace that volume with non-signal data
binarydata = binarydata>0;
strel11 = strel(ones(11,11,11));
strel13= strel(ones(13,13,11));
pipdi = imdilate(binarydata,strel11);

bkgnd = mean(imagedata(~pipdi(:)));
noise = std(imagedata(~pipdi(:)));

out= imagedata;
out((pipdi(:))) = bkgnd+noise*randn(1,sum(pipdi(:)));
