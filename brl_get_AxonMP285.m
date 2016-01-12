function success = brl_get_AxonMP285(axonPortNumber)
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
%  BRL code to get control of axon MP285...2014.01.1X
%

% optional input is COM port number for the sutter serial control of interest, here
%labeled `Axon'


%  THIS FUNCTION DECLARES A GLOBAL VARIABLE axon285 that is used to control
%  a Sutter MP285.

% output 

%  success =    0 means axon285 initialization failed
%               1 means successful initialization 
%               2 global variable axon285 already exists


if nargin==0
    axonPortNumber = 4;
end

axonPortNumberString=['COM',num2str(axonPortNumber)];
fprintf(['* * * * * * * * * * * * * * * * * * * \n'])

fprintf(['Getting Axon MP-285 from ' ,  axonPortNumberString, '\n'])

if ~isempty(whos('global','axon285'))
    fprintf('axon285 already exists as a global variable...\n')
    success = 2;
    return
end
nothingOnAxonCom = isempty(instrfind('Port', axonPortNumberString));
if nothingOnAxonCom
    global axon285
    axon285 = dabs.sutter.MP285('comPort', 4,'baudrate', 9600)
    if strcmp('dabs.sutter.MP285', class(axon285))
                fprintf(['DECLARED GLOBAL axon285 of class ', class(axon285), '\n'])

        success=1;
        return
    else
        fprintf(['failed to acquire Axon MP-285 from COM ', num2str(axonPortNumber),'\n'])
        fprintf(['could not initialize dabs.sutter.MP285\n'])
        clear global axon285
        success =0;
        
        return
    end
    
    
else
    
   fprintf( ['failed to acquire Axon MP-285 from COM ', num2str(axonPortNumber),'\n'])
  fprintf(  [axonPortNumberString, ' has already been opened\n'])
    fprintf(  ['use ''a=instrfind'' and ''delete(a(1))'' if ''a(1)'' is a serial port object at the desired port  '])

      fprintf(  [axonPortNumberString, ' has already been opened\n'])

    success =0;
    return
end



