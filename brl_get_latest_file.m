function out = brl_get_latest_file(directory, filestring, ignorestring)

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

% modification to handle ignoring files with a certain string

% BRL 2014.02.04  
% utility function to get the latest file matching 
% 
%  filestring         in the directory 
%  directory                       
%                       if filestring is nonexistant, just search the
%                       directory for anything


% out is the full path to the single newest file matching the input string
% out will be empty  []  if there are no files in the dir matching the
% input string.


if nargin == 1
    filestring=[];
end
if nargin <=2 | isempty(ignorestring)
ignoreAstring=0;
else
    ignoreAstring=1;
end



files = dir(fullfile(directory,filestring));
candidatefiles = files(~[files(:).isdir]);

if  numel(candidatefiles)==0
  fprintf(  'no matching files!  returning empty list\n')
    out = [];
    return
end

if ignoreAstring
ignorecheck=strfind({candidatefiles(:).name},ignorestring);
for i = 1:numel(ignorecheck)
    keepers(i) = sum(ignorecheck{i})==0;
end
candidatefiles = candidatefiles(keepers);
end

datenumbers = datenum({candidatefiles(:).date});
maxdatenum = find(datenumbers==max(datenumbers(:)));
if numel(maxdatenum)>1 
    fprintf( 'more than one latest file!  returning empty list\n')
    out = [];
    return
else
out = fullfile(directory, candidatefiles(maxdatenum).name);
end