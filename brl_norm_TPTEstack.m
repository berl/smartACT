function out = brl_norm_TPTEstack(fullfilestring,  prcntile, twochannel, overwrite, keepstack , outputformat, combostruct)
%
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

%  2014.08.17

%  add optional combostruct argument that will allow reading from 2
%  separate scanimage .tif files to replace a substack of fullfilestring
%  with the data in combostruct.otherfilestring

% combostruct must have fields
%               combostruct.otherfilestring (the full file string to
%                       the second scanimage .tif file)
%               combostruct.startslice
%               combostruct.endslice
%                   combostruct.slicemicrons
%


% 2014.08.12
% improved normalization spread


%   add flag outputformat to allow two new output formats:
%      outputformat == 0  only output the red channel (Channel 1),
%      retaining previous functionality when combined with keepstack == 1,0
%      outputformat == 1 a combined stack from both channels of the input image (useful for point-and-click
%           targeting of pipet tip, pia and target)
% and  outputformat == 2 a two-channel output in xycz format (same as input from scanimage)

% the 'keepstack' input parameter is still in use, but now has more possible
% values:

%  keepstack ==  0   means don't keep the stack in memory
%  keepstack ==  1,2,3 ...  means keep that specific channel
%  keepstack ==  -1 means keep all channels in memory as separate channels
%  in separate fields of the output struct
% keepstack == -2  means keep the combined stack in memory (channels added
%                   together after normalization)

if nargin==2 | isempty(twochannel)
    twochannel=0;
end
if nargin <=3 | isempty(overwrite)
    overwrite = 0;
end
if nargin <=4 | isempty(keepstack)
    keepstack=0;
end
if nargin <=5 | isempty(outputformat)
    outputformat = 0;
end



combo = 0;
if nargin == 7 && ~isempty(combostruct)
    if sum(isfield(combostruct, {'otherfilestring', 'startslice', 'endslice', 'slicemicrons'}))==4
        combostruct.endslice = combostruct.endslice-1;

        combo = 1;
    end
end



% CRITICAL NOTE:
%  this function flips each image updown before writing the stack.  this is
%  needed for continuity with vaa3d's rendering of .tif files saved by
%  scanimage and vaa3d's rendering of .tif files saved with this function.

%  FURTHERMORE, if the function returns a stack, it is NOT flipped in y, so
%  that the vaa3d rendered stack of the output, associated
%  imagesc(stack(:,:,20)) images and .swc from vaa3d are all aligned


% new version that just saves normalized .tif stacks instead of .v3draw
% files.  The .v3draw writer is currently based on MEX files that I haven't
% gotten to compile on the 2p machine.  also get rid of the double
% percentile requirement, as well as returnzstep only (now default), notdoublestack and filenumber arguments

%the Special version (2014.02.11) saves as .raw instead of .v3draw and
%generates 2 different versions, one for each of the 2 percentiles. and
%also save the file to a name ending with the argument 'filenumber'




% also I'm setting the bottom 5% equal to zero for easier 3D visualization

% if 'returnzstep' is set and true,  the output is ONLY the z step size of
% the stack (in microns)

% CRITICAL NOTE:  internally, this function swaps dimensions 1 and 2 of the
% stack because the v3draw writer from PHC used below writes the file incorrectly.








% 2014.01.28 BRL added optional percentile argument and new
% percentile-based normalization

% 2013.12.22 BRL modifies older function SPECIFICALLY TO DEAL WITH in vivo STACKS from ScanImage
%  doing  depth-normalization based on the max each slice. This isnt' the
%  best thing in the world for general images, but it actually helps see
%  the pipet
% writing to v3draw and reducing to 8bit.





InfoImage=imfinfo(fullfilestring);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);

%  get image data from ScanImage image data held in the .tif header

FinalImage = InfoImage(1).ImageDescription;  % this contains the relevant information FOR THIS STACK ONLY
% and it's a char
% array, not a struct.

searchstring =     'state.acq.zStepSize=';

t =   textscan(FinalImage, '%s');
for i = 1:numel(t{1})
    findresults = strfind(t{1}{i},searchstring );
    if numel(findresults)==1
        rightrow = i;
        zstep = str2num(t{1}{rightrow}((findresults+numel(searchstring)) : end));
        out.zstep = zstep;
    end
end



searchstring =  'state.acq.savingChannel1=';

t =   textscan(FinalImage, '%s');
for i = 1:numel(t{1})
    findresults = strfind(t{1}{i},searchstring );
    if numel(findresults)==1
        rightrow = i;
        channel1 = str2num(t{1}{rightrow}((findresults+numel(searchstring)) : end));
    end
end



searchstring =  'state.acq.savingChannel2=';

t =   textscan(FinalImage, '%s');
for i = 1:numel(t{1})
    findresults = strfind(t{1}{i},searchstring );
    if numel(findresults)==1
        rightrow = i;
        channel2 = str2num(t{1}{rightrow}((findresults+numel(searchstring)) : end));
    end
end


searchstring =  'state.acq.savingChannel3=';

t =   textscan(FinalImage, '%s');
for i = 1:numel(t{1})
    findresults = strfind(t{1}{i},searchstring );
    if numel(findresults)==1
        rightrow = i;
        channel3 = str2num(t{1}{rightrow}((findresults+numel(searchstring)) : end));
    end
end


searchstring =  'state.acq.savingChannel4=';

t =   textscan(FinalImage, '%s');
for i = 1:numel(t{1})
    findresults = strfind(t{1}{i},searchstring );
    if numel(findresults)==1
        rightrow = i;
        channel4 = str2num(t{1}{rightrow}((findresults+numel(searchstring)) : end));
    end
end


%% and now, if applicable, compare the given step size to the  file step size for combining two stacks

if combo==1
    out.zstep
    combostruct.slicemicrons
    if out.zstep ~=combostruct.slicemicrons
        sprintf('MISMATCHED Z SLICES- stacks NOT combined')
        combo =0;  %abort combining stacks
    end
end


if combo==1
writefile = [fullfilestring(1:end-4),'NormC',combostruct.otherfilestring(end-7:end-4), fullfilestring(end-6:end-4), '.tif'];
else
    writefile = [fullfilestring(1:end-4),'Norm', fullfilestring(end-6:end-4), '.tif'];
end

        out.string =  writefile;

%  now convert the given z slices to the appropriate


%%


% are there two and only two channels?
nchannels = sum([channel1 channel2 channel3 channel4]);
twochannel = nchannels==2;

% if it's a 2 channel image and the user wants only the red channel, we will skip
% every other slice
if twochannel & outputformat ==0
    iminc=2
else
    iminc = 1;
end

% Read in .tif file using tif library directly
% copied wholesale from http://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/



TifLink = Tiff(fullfilestring, 'r');
if combo ==1
    TifLink2 = Tiff(combostruct.otherfilestring, 'r');
end


if numel(dir(writefile))~=0 && ~overwrite
    'image already exists!  enable overwrite if needed'
    
    return
end


if combo==1 && numel(dir(writefile))~=0 && ~overwrite
    'image already exists!  enable overwrite if needed'
    
    return
end



%%  reading in the images and normalizing


%  if prcntile is not set, the default is to use the max for slice normalization.  if prcntile
%  is set, then mult x prcntile is used as the normalization value

% empirically, mult=3 looks ok
mult=3;

% separate read loops for the different cases
findex = 1;  % index used for the workspace output


% PREVIOUS functionality:  keeping or writing the red channel only from 1-
% or 2-channel images
if outputformat == 0
    for i=1:iminc:NumberImages
        
        if combo ==1 && i>=combostruct.startslice*iminc && i<= combostruct.endslice*iminc
            TifLink2.setDirectory(i-combostruct.startslice*iminc+1);
            tmp = double(TifLink2.read());
        else
            
            TifLink.setDirectory(i);
            
            tmp=double(TifLink.read());
        end
        
        
        
        bottomval = percentile(tmp(:), .05);
        tmp=tmp-bottomval;
        nval = mult*percentile(tmp(:), prcntile);
        
        tmp(tmp<0)=0;
        
        
        
        if i ==1
            imwrite(flipud(uint8(255*(tmp)/nval)), writefile);
        else
            
            imwrite(flipud(uint8(255*(tmp)/nval)), writefile, 'writemode', 'append');
            pause(.01)
        end
        if keepstack ==1
            out.stack(:,:,findex)=(uint8(255*(tmp)/nval));  % CRITICAL:  KEPT STACK IS NOT FLIPPED!
        end
        findex = findex+1;
        
    end
    TifLink.close();
    if combo ==1
        TifLink2.close();
    end
    return
end

combostruct
%  output summed stack
findex = 1;  % index used for the workspace output
findexA = 1;  % index used for the workspace output

nchannels
for i=1:nchannels:NumberImages
    
    tmp = zeros(nImage, mImage);
    
    
    for j = 1:nchannels
        
        tifindex =i+j-1;
        
        if combo==1  &&  tifindex >= (combostruct.startslice-1)*nchannels +1 && tifindex <= (combostruct.endslice)*nchannels
            'combo'
            TifLink2.setDirectory(tifindex- (combostruct.startslice-1)*nchannels );
            tmpj=double(TifLink2.read()); % read the next image
        else
            
            TifLink.setDirectory(tifindex);
            tmpj=double(TifLink.read()); % read the next image
        end
        
        
        bottomval = percentile(tmpj(:), .05); % normalize intensities
        tmpj = tmpj-bottomval;
        nval = mult*percentile(tmpj(:), prcntile);
        tmpj(tmpj<0)=0;
        
        
        if outputformat == 2 %  write all the channels into a single stack
            if tifindex ==1
                delete(writefile)
                imwrite(flipud(uint8(255*(tmpj)/nval)),writefile, 'writemode', 'append');
            else
                
                imwrite(flipud(uint8(255*(tmpj)/nval)), writefile, 'writemode', 'append');
                pause(.01)
            end
        end
        
        
        
        
        
        % select relevant channel for function output, if desired. doesn't
        % effect the output written to files
        if keepstack >=1 && keepstack <= nchannels
            if j == keepstack
                out.stack(:,:,findex)=(uint8(255*(tmpj)/nval));  % CRITICAL:  KEPT STACK IS NOT FLIPPED!
                findex = findex+1;
                
                
                
                
            end
        elseif keepstack == -1  % return both channels 1 and 2 (And the combined stack (below))
            
            if j ==1
                out.stack1(:,:,findex)=(uint8(255*(tmpj)/nval));  % CRITICAL:  KEPT STACK IS NOT FLIPPED!
            elseif j ==2
                out.stack2(:,:,findex)=(uint8(255*(tmpj)/nval));  % CRITICAL:  KEPT STACK IS NOT FLIPPED!
                findex = findex+1;
            end
        end
        
        
        
        tmp = tmp+tmpj/nval;  % these are doubles, so it's OK to exceed the original depth of the .tif file
    end
    
    
    
    
    if keepstack ==-2 || keepstack ==-1 % keep the combined (summed) image as function output
        out.stack(:,:,findexA)=uint8(255*(tmp/nchannels));  % CRITICAL:  KEPT STACK IS NOT FLIPPED!
        findexA = findexA+1;
    end
    
    
    
    
    if outputformat == 1
        % now write the combined stack
        if i ==1
            delete(writefile)
            imwrite(flipud(uint8(255*(tmp)/nchannels)), writefile, 'writemode', 'append');
        else
            
            imwrite(flipud(uint8(255*(tmp)/nchannels)),writefile, 'writemode', 'append');
            pause(.01)
        end
    end
    
    
    
end
if combo ==1
    TifLink2.close();
end
TifLink.close();
end

%      outputformat == 1 a combined stack from both channels of the input image (useful for point-and-click
%           targeting of pipet tip, pia and target)
% and  outputformat == 2 a two-channel output in xycz format (same as input from scanimage)




