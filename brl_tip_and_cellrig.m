function out = brl_tip_and_cellrig(markerswcfilename, image2microns)

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

% 2014.06.16  eliminate former swapxy argument.
% 2014.04.30 BRL modify to include pia marker.

%  BRL  2014.01.24    function to load coordinates and assign the 'upper'
%                       location  (lower z) to the tip of the pipet and the
%                      other location (lower in the stack, higher z) to the
%                      cell body.


%    input:   markerswcfilename     is the full path to a swc file that
%                                       should have 2 locations.
%             image2microns         is a 3 vector with conversion factors
%                                   from image coordinates to microns
%                                   [xpixelsize, ypixelsize, z step]


%  the reported x,y locations in swc file from vaa3d are reversed even to the 3d axes
% in the 3D view.  ?!?




try
    a = load_v3d_swc_file(markerswcfilename);
catch
    a = autogen_import_SWC(markerswcfilename, 4,5);
end
% does this have more than 2 rows?

if size(a,1)>2
    out = [];
    'including pia coordinate'
    pialoc = 1
else
    pialoc = 0
    
end



coords = sortrows(a(:,3:5), 3);

%

%  CRITICAL:  conversion to microns!
coords(:,1) = coords(:,1)*image2microns(1);
coords(:,2) = coords(:,2)*image2microns(2);
coords(:,3) = coords(:,3)*image2microns(3);


if ~pialoc
out.pipetTip = coords(1,:);
out.pia = coords(1,:);
    out.cell = coords(2,:);
else
    out.pipetTip = coords(1,:);
    out.pia = coords(2,:);
    out.cell = coords(3,:);
end