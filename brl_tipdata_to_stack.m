function out = brl_tipdata_to_stack(tipdata, startrow, startcol, startz)
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
% utility function to convert stack-coordinates of the output struct from brl_find_tip_2
%  to
% coordinates of the whole stack whose origin is iat startrow, startcol,
% startz


out = tipdata;
% keep all the other fields the same, but
% the following fields have to be adjusted
out.tipi1 = out.tipi1 +startcol-1;
out.tipi2 = out.tipi2  +startz-1 ;
out.tipi3 = out.tipi3 + startrow-1;

out.tipj1 = out.tipj1+ startz-1 ;
out.tipj2 = out.tipj2 +startrow-1;
out.tipj3 = out.tipj3+ startcol-1;

out.ind1 = out.ind1  ;
out.ind2 = out.ind2  ;
out.ind3 =out.ind3 ;


out.coordinates  = out.coordinates + [startrow startcol startz] -[1 1 1]  ; 



