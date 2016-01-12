# smartACT
Source code for software described in 3D Image-Guided Automatic Pipette Positioning for Single Cell Experiments in vivo http://www.nature.com/articles/srep18426
smartACT ReadMe v1.0
1. License Information
2. Dependencies
3. Critical Notes
4. smartACT instructions v1.1
Appendix 1. GNU General Public License Version 3
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

Please read this entire file before attempting to use smartACT. The smartACT code is intended primarily as a reference and starting point for technology developers and is currently coded to run on our hardware configuration. Section 3 below is particularly important. 


1. License Information.
a. smartACT source code and all documentation is © 2015 Allen Institute.
b. smartACT is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
c. smartACT is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
d. A copy of GNU General Public License version 3 is available in Appendix 1
2. Dependencies
a. Hardware: Sutter MOM scope, Sutter MP285 3-axis manipulator
b. Software: 
i. MATLAB 
ii. ScanImage v 3.8 RC4  available at  http://scanimage.vidriotechnologies.com/display/ephus/ScanImage
iii. smartACT_src directory in the MATLAB path
3. Critical Notes
a. The current smartACT software is configured to run on our setup, including, but not limited to, the orientation of the axes in our manipulator and microscope. 
b. smartACT must first be tested using fluorescent beads suspended in agarose before use in any other experiments.
c. Important warnings about scanImage and Sutter controllers on the Sutter MOM (Sutter MOM, Sutter MP-285 manipulator, scanImage 3.8 RC4):
i. We have observed that under some conditions in our configuration* (N = 2, otherwise unreproducible) the objective stage will drive to the end of travel, or at least straight down, possibly headed to a poorly-selected ‘HOME’ position. This took place when there was automated movement of the manipulator (pipette approach) and possibly collecting a stack or moving the objective with the Sutter ROE. The ScanImage GUI was unresponsive and both controllers were in an error state.  
ii. The only sure way to stop an MP-285 during a move is to turn off the power switch at the control box, although the ‘RESET’ button on the MP-285 also works under non-error conditions. Either the ‘RESET’ or power methods may put scanImage and MATLAB into an unrecoverable state, requiring force-quit of MATLAB.  The use of the ‘RESET’ button during a move while the MP-285 is also in an error state has not been tested, because I have been unable to reproduce that condition.
iii. The runaway stage condition is extremely rare, but it may be correlated with MATLAB sending multiple serial commands while the MP285 trying to move the stage due to manual controller input.
iv. CRITICAL policies to mitigate potential problems:
1. Never touch the ROE controller while the manipulator or stage is being moved by computer control, e.g. during a stack or approach.
2. Do not collect stacks or focus in scanImage while the manipulator is under computer control.
3. The ‘HOME’ position should be set away from the sample for both the pipette and objective controllers.


4. smartACT Instructions  version 1.1  2015.10.26
a. Start up equipment, MATLAB, scanImage and smartACT, in that order
b. Enable scanimage user-function ‘brl_sp_grab_handler’ for EventName ‘acquisitionDone’
c. Press ‘Initialize SmartACT’ 
d. Position the pipette within about 20-30 micron (z) of the pia, within the (xy) field of view of your target cells.
e. Collect a 256x256 1x zoom stack that includes about 20-30 microns above the pipette tip (z) and at least 10 microns below your target cell. >Note: MATLAB’s .tif write conflicts with Windows when the Windows Explorer is open at the write (Save) directory.  Close the Explorer window when writing to disk or normalizing images!
f. Click ‘normalize latest .tif’ and drag the resulting file into Vaa3D. 
g. Visualize stack in 3D in Vaa3D by typing ctl-v.
h. Right click in 3D viewer and select ‘1-right-click to define a marker’, and then select the pipette tip, the pia above the target cell, and the target cell.  Hit ‘Esc’ to finish. Click ‘Save markers to SWC format’ on the main Vaa3D window to export the file.
i. Back in the smartACT GUI, make any modifications to the Approach Parameters and then click ‘Confirm Parameters’
j. Click  ‘Load Target Data Reset Origin’ and select your .swc file from Vaa3d. 
k. Confirm that the Approach Control is set up with ‘Direction : Forward’ and ‘Stepping Mode : Continuous‘, and press the green START button to begin the approach.
l. The approach will automatically stop about 30 microns (z) from the target location and open a new window.  Collect a tip-and-cell substack for adaptive correction and then collect a stack to document cell morphology. In each case, click ‘calculate … stack’, verify the z coordinates and then click OK.  You can use higher zoom and number of pixels for the cell stack, and the scan shift variables to center the image on the cell without adjusting the motor position. MAKE SURE YOU GO BACK TO 256x256 and ZOOM 1 BEFORE COLLECTING ANY OTHER DATA FOR SmartACT!    Automatic x-y functionality and increased zoom may be added to future versions.
m. If the substack z locations are out of range of the original stack when you click ‘calculate tip-and-cell substack’ or the cell-only version, hit ‘CANCEL’ 
n. The resulting tip and cell images should appear in the 3-view windows.  Select ‘Segmented image’ from the drop-down menu, adjust the normalization and threshold to see the calculated tip position (magenta circle). Click ‘Locate Tip’ after verifying the location and then repeat for the cell image, including clicking ‘Locate Cell’.  Note that the cell localization takes a bit longer on this machine, so it may take a few seconds to update.
o. In smartACT click ‘Adapt Approach’.  This will bring up a simple plot showing the initial trajectory (blue), after the correction for the tip location (green) and after the correction for tip and cell locations (red). Unless the red and blue trajectories are very far apart (>~10 microns) click ‘confirm approach’ and click the green START button to finish the trajectory.
p. Press ‘update coordinates’ and then ‘Abort experiment and retract’ to retract the pipette and return to the original location above the surface of the brain.

