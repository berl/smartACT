function out = brl_locate_cells(img, params, imageonly)
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

if nargin==2 |isempty(imageonly)
    imageonly  =0
end

if ~isfield(params,'thresh')
    params.thresh = 100;
end
% function to locate cell bodies in an image that has the pipet cloaked by
% brl_cloak_pipet


% 2014.06.04  this is pretty basic cell body segmentation based on
% bandpass filtering and thresholding


% generate a large wavelength filter.  this should be big enough to
% emphasize the residual pipet signal and mostly eliminate out the cell bodies

regionmin = 10;

[xs ys zs] = meshgrid(-15:15,-15:15,-15:15);

fbig = exp(-(xs.^2+ys.^2+zs.^2)/params.big^2);
fbig = fbig./(2*sum(fbig(:).^2));


%out.filteredBig = imfilter(img, fbig);

% generate a short wavelength filter to eliminate small features and
% pixel-scale noise


fsmall = exp(-(xs.^2+ys.^2+zs.^2)/params.small^2);
fsmall = fsmall./(2*sum(fsmall(:).^2));
filter= (fsmall-fbig);

out.filtered = imfilter(img,filter);
out.filtered(out.filtered(:)<0)=0;
if imageonly
    return
end

% this should highlight the cells

% now set a threshold...  

% this is a little tricky, but so far, it looks like thresholds around 100
% out of 255
% work well for data that has made it through the processing.  Thresholding
% right based on the noise level (e.g. 5 sigma above overall mean) isn't ideal-
% it generates false positives and is sensitive to the quantity of labeled
% cells.
thresholded = out.filtered>params.thresh;%100;

% i do need a label matrix:

out.labelmatrix = bwlabeln(thresholded);
% and extract regionprops

out.rpdata = regionprops(out.labelmatrix, 'Area', 'centroid');



%  get rid of tiny regions:
keepBool = [out.rpdata(:).Area] >regionmin;   

out.rpdata = out.rpdata(keepBool);
throwlist = find(~keepBool);
out.labelmatrix(ismember(out.labelmatrix(:), throwlist))=0;



% then set a threshold based on the average properties of the image. this
% is OK since the data have already been scaled for depth and this z range
% shouldn't cover too much residual signal variation.