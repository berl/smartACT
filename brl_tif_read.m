function out = brl_tif_read(filename, channelnumber, totalchannels, rows, columns, zslices)
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
% rough tif read function
% BRL 2014.08.29

% rows, columns, zslices are optional entries that specify the stuff to
% save.  note that z slices saved will ONLY be in the channel specified.

if nargin==3
    dosubstack=0;
else
    dosubstack =1
end






a = imfinfo(filename);



if dosubstack
rs = [max(rows(1),1): min(rows(2),a(1).Height)];
cs = [max(columns(1),1): min(columns(2),a(1).Width)];
    r = numel(rs);
    c = numel(cs);
    minIm = ((zslices(1)-1)*totalchannels+channelnumber);
    intIm = totalchannels ;
    maxIm = ((zslices(2)-1)*totalchannels+channelnumber);
 imrange = minIm:intIm :maxIm ;

else
    r = a(1).Height;
    c = a(1).Width;

imrange = channelnumber:totalchannels:numel(a);
rs = 1:r;
cs = 1:c;
end

imrange = imrange(imrange(:)<=numel(a));

index = 1;
out = zeros(r,c,numel(imrange));
TifLink = Tiff(filename, 'r');
for i=imrange

            TifLink.setDirectory(i);
            tempimage = double(TifLink.read());
           size(tempimage)
            out(:,:,index)=tempimage(rs,cs);
            index=index+1;        
end
TifLink.close();