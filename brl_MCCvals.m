function out = brl_MCCvals(inputstring)
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
% calls to the server to return current multiclamp commander meter values
% return a character array...  the values we want are space-delimited
% values in the last line:
out = [];
recording=0;
[zzz r] =strtok(inputstring,' ');
while ~isempty(r)
[zzz r] =strtok(r,' ');
if strcmp(zzz , 'values:')
recording = 1;
end
if recording
out = [out, str2num(zzz)];
end
end

% CRITICAL:

% the first value is sometimes resistance and sometimes voltage.  since the
% voltages and currents are small (always less than 10 V) and the
% resistances are large (always greater than 100Ohms), we can adaptively
% correct when the user has clicked or unclicked the 'Resistance' mode 


if out(1)<100
    out(1) = out(1)/out(2);
end