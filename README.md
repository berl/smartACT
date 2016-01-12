# smartACT
Source code for software described in 3D Image-Guided Automatic Pipette Positioning for Single Cell Experiments in vivo http://www.nature.com/articles/srep18426
smartACT ReadMe v1.0
##1. License Information
##2. Dependencies
##3. Critical Notes
Appendix 1. GNU General Public License Version 3
 © 2015 Allen Institute.
 This file is part of smartACT.
 smartACT is free software: you can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free 
 Software Foundation, either version 3 of the License, or (at your option)
 any later version. smartACT is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of 
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
 General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with smartACT.
 If not, see <http://www.gnu.org/licenses/>.

 This package is currently not maintained and no support is implied. 
 Questions may be directed to Brian Long
 <brianl@alleninstitute.org> with 'smartACT' in the subject line. 

Please read this entire file before attempting to use smartACT. The smartACT code is intended primarily as a reference and starting point for technology developers and is currently coded to run on our hardware configuration. Section 3 below is particularly important. 


#1. License Information.
##a. smartACT source code and all documentation is © 2015 Allen Institute.
##b. smartACT is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
##c. smartACT is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
##d. A copy of GNU General Public License version 3 is available in Appendix 1
#2. Dependencies:
##a. Hardware: Sutter MOM scope, Sutter MP285 3-axis manipulator
##b. Software: 
###i. MATLAB 
###ii. ScanImage v 3.8 RC4  available at  http://scanimage.vidriotechnologies.com/display/ephus/ScanImage
###iii. smartACT_src directory in the MATLAB path
###iv. vaa3d available at http://vaa3d.org

#3. Critical Notes
##a. The current smartACT software is configured to run on our setup, including, but not limited to, the orientation of the axes in our manipulator and microscope. 
##b. smartACT must first be tested using fluorescent beads suspended in agarose before use in any other experiments.
##c. Important warnings about scanImage and Sutter controllers on the Sutter MOM (Sutter MOM, Sutter MP-285 manipulator, scanImage 3.8 RC4):
###i. We have observed that under some conditions in our configuration* (N = 2, otherwise unreproducible) the objective stage will drive to the end of travel, or at least straight down, possibly headed to a poorly-selected ‘HOME’ position. This took place when there was automated movement of the manipulator (pipette approach) and possibly collecting a stack or moving the objective with the Sutter ROE. The ScanImage GUI was unresponsive and both controllers were in an error state.  
###ii. The only sure way to stop an MP-285 during a move is to turn off the power switch at the control box, although the ‘RESET’ button on the MP-285 also works under non-error conditions. Either the ‘RESET’ or power methods may put scanImage and MATLAB into an unrecoverable state, requiring force-quit of MATLAB.  The use of the ‘RESET’ button during a move while the MP-285 is also in an error state has not been tested, because I have been unable to reproduce that condition.
###iii. The runaway stage condition is extremely rare, but it may be correlated with MATLAB sending multiple serial commands while the MP285 trying to move the stage due to manual controller input.
###iv. CRITICAL policies to mitigate potential problems:
####1. Never touch the ROE controller while the manipulator or stage is being moved by computer control, e.g. during a stack or approach.
####2. Do not collect stacks or focus in scanImage while the manipulator is under computer control.
####3. The ‘HOME’ position should be set away from the sample for both the pipette and objective controllers.



