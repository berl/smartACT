function out =brl_find_tip_2(a3, a2, a1)

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
% 2014.09.01  new version that takes the segmented MIP images as input and doesn't
% plot any of the intermediate steps

% 2014.06.02

% function to return coordinates of the tip of the pipet from a small* 2p
% stack that includes the pipet.

% input     img     is the image 
%           tflag   is a flag indicating if the image is normalized for depth.  
%           tflag==0 means the stack HAS BEEN NORMALIZED and will be thresholded at threshold*max(img(:))
%                        
%           tflag==1 means the stack has NOT BEEN NORMALIZED and will be thresholded at .1*max(img(:)),
%            

%  * 'small' here is a working definition based on ...  what works and what
%  doesn't. currently it's a good idea to include all of the pipet and
%  limit the depth below the tip of the pipet and everything else.  it's
%  unclear how bad things get based on other stuff in the image... full
%  stacks seem to work too ... (?)




% returns  out  which is a struct
%                       out.coordinates     is the coordinate estimate
%                       out.badness         see below for definition
%                       out.badflag                    0 is OK, 1 is bad



%  run regionprops on each of these, just looking for area and perimeter
out.rp1 = regionprops(a1,'area', 'perimeter','centroid');
out.rp2 = regionprops(a2,'area', 'perimeter','centroid');
out.rp3 = regionprops(a3,'area', 'perimeter','centroid');

% now extract the largest area region
if numel(out.rp1)==0 || numel(out.rp2)==0 || numel(out.rp3)==0
out.badflag = 1;

return
end

if max([out.rp1(:).Area])<10 || max([out.rp2(:).Area])<10 ||max([out.rp3(:).Area])<10
  out.badflag = 1;
out.badness= [0 0 0];
out.coordinates=[ 0 0 0];
return  
else
    ind1 = find([out.rp1(:).Area]'==max([out.rp1(:).Area]));
    ind2 = find([out.rp2(:).Area]==max([out.rp2(:).Area]));
    ind3 = find([out.rp3(:).Area]==max([out.rp3(:).Area]));
ar1 = a1==ind1;
ar2 = a2==ind2;
ar3 = a3==ind3;
end

% and find the corresponding tip coordinates
[i1 j1] = find(ar1,10,'last');  %t
[i2 j2] = find(ar2,10,'last');
[i3 j3] = find(ar3,10,'last');  %

out.tipi1 = i1;
out.tipi2 = i2;
out.tipi3 = i3;

out.tipj1 = j1;
out.tipj2 = j2;
out.tipj3 = j3;

out.ind1 = ind1;
out.ind2 = ind2;
out.ind3 = ind3;



% I need to extract some measure of the quality of this estimate, at least
% to the level of flagging cases where the coordinates aren't at all consistent

% mean(j3) should be equal to mean(i1)

s1=abs(mean(j3)-mean(i1));
% max(j1) should be equal to max(j2)
s2 = abs(max(j1)-max(j2));

% mean(i2) should equal mean(i3)
s3 = abs(mean(i2)-mean(i3));

% we want a measure that captures any badness:

totalBadness = s1+s2+s3;

% BADNESS MODIFICATION>.
if s1>20 || s2>20 || s3>20 || totalBadness>25
out.badflag = 1;
else
    out.badflag = 0;
end


if out.badflag
    return
else
    
 out.coordinates = [  mean(i3), mean([i1(:); max(j3(:))]),  max(j1)];
end







