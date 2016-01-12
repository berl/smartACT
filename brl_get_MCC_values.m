function out = brl_get_MCC_values(~)
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
% default url

mccURL = 'http://127.0.0.1:8889/multiclamp/0?cmd=position';

out = brl_MCCvals( urlread2(mccURL));