function varargout = brl_tip_cell_update(varargin)
% BRL_TIP_CELL_UPDATE MATLAB code for brl_tip_cell_update.fig
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
%
%      BRL_TIP_CELL_UPDATE, by itself, creates a new BRL_TIP_CELL_UPDATE or raises the existing
%      singleton*.
%
%      H = BRL_TIP_CELL_UPDATE returns the handle to a new BRL_TIP_CELL_UPDATE or the handle to
%      the existing singleton*.
%
%      BRL_TIP_CELL_UPDATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRL_TIP_CELL_UPDATE.M with the given input arguments.
%
%      BRL_TIP_CELL_UPDATE('Property','Value',...) creates a new BRL_TIP_CELL_UPDATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before brl_tip_cell_update_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to brl_tip_cell_update_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help brl_tip_cell_update

% Last Modified by GUIDE v2.5 24-Nov-2014 10:03:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @brl_tip_cell_update_OpeningFcn, ...
                   'gui_OutputFcn',  @brl_tip_cell_update_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before brl_tip_cell_update is made visible.
function brl_tip_cell_update_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to brl_tip_cell_update (see VARARGIN)

% Choose default command line output for brl_tip_cell_update
handles.output = hObject;
tipCellData.archiveMode = 0;


% get the handle to the smartACT gui

tipCellData.smartACTh = findobj('name','smartACT');
tipCellData.runBh  = handles.collectTipCellSubstackB;
tipCellData.runfunctionh = @collectTipCellSubstackB_Callback;

tipCellData.importh = @importStack;
tipCellData.findTiph =@locateTipB_Callback;
tipCellData.findCellh = @locateCellB_Callback;

tipCellData.findTipB =handles.locateTipB;
tipCellData.findCellB = handles.locateCellB;


set(handles.figure1, 'UserData', tipCellData);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes brl_tip_cell_update wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = brl_tip_cell_update_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in useLatestFullStackB.
function useLatestFullStackB_Callback(hObject, eventdata, handles)
% hObject    handle to useLatestFullStackB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get path to some relevant image data
tipCellData = get(handles.figure1, 'UserData');
global spStackdata
spUdat = get(tipCellData.smartACTh,'UserData');
imPath = spStackdata.lastFullStackRaw
%
% import defined substack.
%
tipCellData.tiprows = fliplr(255-[115 180]);
tipCellData.tipcols = [10 90];
tipCellData.tipzs = [50 67]
argh = brl_tif_read(imPath, 2,2,tipCellData.tiprows ,tipCellData.tipcols,tipCellData.tipzs);

tipCellData.rawTipImage = argh;
tipCellData.normTipImage = tipCellData.rawTipImage-percentile(tipCellData.rawTipImage(:), .05);
tipCellData.normTipImage = tipCellData.normTipImage/percentile(tipCellData.normTipImage(:), get( handles.tipNormalization, 'value'));
tipCellData.normTipImage = 255*tipCellData.normTipImage;


tipCellData.segTipImage = tipCellData.normTipImage>get(handles.tipThreshold,'Value');

%
% import defined substack.
%

tipCellData.lastCellLocation = []


tipCellData.cellrows = fliplr(255-[115 180]);
tipCellData.cellcols = [90 110];
tipCellData.cellzs = [95 115];
argh = brl_tif_read(imPath, 1,2,tipCellData.cellrows ,tipCellData.cellcols, tipCellData.cellzs);

tipCellData.rawCellImage = argh;
tipCellData.normCellImage = tipCellData.rawCellImage-percentile(tipCellData.rawCellImage(:), .05);
tipCellData.normCellImage = tipCellData.normCellImage/percentile(tipCellData.normCellImage(:), get( handles.cellNormalization, 'value'));
tipCellData.normCellImage = 255*tipCellData.normCellImage;

set(handles.imageFileT,'String', imPath);
set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);




% --- Executes on button press in analyzeArchivedStackB.
function analyzeArchivedStackB_Callback(hObject, eventdata, handles)
% hObject    handle to analyzeArchivedStackB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tipCellData = get(handles.figure1, 'UserData');

% give option to load a stack and enter tip coordinates.
tipCellData.archiveMode = 1

[imPath,dir] = uigetfile('*.tif');
%
% import defined substack.
%
% tip location
tipCellData.tipLocation =  round([ 93 122 16]);

tipCellData.tiprows = [max(tipCellData.tipLocation(2)-20,1) ,tipCellData.tipLocation(2)+20] ;
tipCellData.tipcols = [max(tipCellData.tipLocation(1)-20,1),tipCellData.tipLocation(1)+20 ];
tipCellData.tipzs =   [max(tipCellData.tipLocation(3)-20,1) , tipCellData.tipLocation(3)+20];

argh = brl_tif_read(fullfile(dir,imPath), 2,2,tipCellData.tiprows ,tipCellData.tipcols,tipCellData.tipzs);

tipCellData.rawTipImage = argh;
tipCellData.normTipImage = tipCellData.rawTipImage-percentile(tipCellData.rawTipImage(:), .05);
tipCellData.normTipImage = tipCellData.normTipImage/percentile(tipCellData.normTipImage(:), get( handles.tipNormalization, 'value'));
tipCellData.normTipImage = 255*tipCellData.normTipImage;


tipCellData.segTipImage = tipCellData.normTipImage>get(handles.tipThreshold,'Value');

%
% import defined substack.
%


tipCellData.lastCellLocation =   round([ 128 122 26])


tipCellData.cellrows = [max(tipCellData.lastCellLocation(2)-20,1) tipCellData.lastCellLocation(2)+20];
tipCellData.cellcols = [max(tipCellData.lastCellLocation(1)-20,1) tipCellData.lastCellLocation(1)+20];
tipCellData.cellzs = [max(tipCellData.lastCellLocation(3)-10,1), tipCellData.lastCellLocation(3)+10];
argh = brl_tif_read(fullfile(dir,imPath), 1,2,tipCellData.cellrows ,tipCellData.cellcols, tipCellData.cellzs);

size(argh)
tipCellData.cellzs = tipCellData.cellzs(1):tipCellData.cellzs(2);
tipCellData.cellzs =[tipCellData.cellzs(1) tipCellData.cellzs(size(argh,3))]
tipCellData.rawCellImage = argh;
tipCellData.normCellImage = tipCellData.rawCellImage-percentile(tipCellData.rawCellImage(:), .05);
tipCellData.normCellImage = tipCellData.normCellImage/percentile(tipCellData.normCellImage(:), get( handles.cellNormalization, 'value'));
tipCellData.normCellImage = 255*tipCellData.normCellImage;


set(handles.imageFileT,'String', fullfile(dir,imPath));
tipCellData

set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);


% --- Executes on selection change in tipImageSelectorPM.
function tipImageSelectorPM_Callback(hObject, eventdata, handles)
% hObject    handle to tipImageSelectorPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tipImageSelectorPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tipImageSelectorPM
tipCellData = get(handles.figure1, 'UserData');
if isfield(tipCellData,'tipLocation')
 set(handles.tipReportedLocationT,'String', num2str(tipCellData.tipLocation([ 1 2 3]), '%.2f   '))
end
currentSelection = get(hObject,'Value')
switch currentSelection
    
      case 1
          'image data'
          imdat3D = tipCellData.rawTipImage;
          mean(imdat3D(:))
        axes(handles.axes1)
imagesc(squeeze(sum(imdat3D,3)));colormap gray
axes(handles.axes2)
imagesc((squeeze(sum(imdat3D,1)))');
axes(handles.axes3)
imagesc(squeeze(sum(imdat3D,2)));
set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);  
          
          
          
    case 2
        'norm data'
        imdat3D = tipCellData.normTipImage;
        mean(imdat3D(:))
    
    axes(handles.axes1)
imagesc(tipCellData.tipcols, tipCellData.tiprows,squeeze(sum(imdat3D,3)));
axes(handles.axes2)
imagesc((squeeze(sum(imdat3D,1)))');
axes(handles.axes3)
imagesc(squeeze(sum(imdat3D,2)));
set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);
    
    
    
    
    case 3
             set(handles.figure1, 'UserData', tipCellData);
        guidata(hObject, handles);
        feval(@locateTipB_Callback, handles.locateTipB, [], guidata(handles.locateTipB))
                     set(handles.figure1, 'UserData', tipCellData);

                guidata(hObject, handles);

        
%           'segment data'
% % generate MIPs after smoothing
% get(handles.tipThreshold,'Value')
% mean(tipCellData.normTipImage(:))
% [tipCellData.im3, tipCellData.im2, tipCellData.im1] = brl_MIP_segmentation(tipCellData.normTipImage, get(handles.tipThreshold,'Value')); 
% % and extract coordinates:
% tipCellData.tipdata = brl_find_tip_2(tipCellData.im3, tipCellData.im2, tipCellData.im1)
% tipCellData.tipdataStackCoordinates = brl_tipdata_to_stack(tipCellData.tipdata, tipCellData.tiprows(1), tipCellData.tipcols(1), tipCellData.tipzs(1))
% 
% axes(handles.axes1)
% imagesc(tipCellData.tipcols, tipCellData.tiprows,tipCellData.im3); 
% hold all, plot(max(tipCellData.tipdataStackCoordinates.tipj3),mean(tipCellData.tipdataStackCoordinates.tipi3), 'om')
% plot(tipCellData.tipdataStackCoordinates.tipj3,tipCellData.tipdataStackCoordinates.tipi3,'.g')
% hold off
% axes(handles.axes2)
% imagesc(tipCellData.tipcols, tipCellData.tipzs,(tipCellData.im1')); 
% hold all, plot(mean(tipCellData.tipdataStackCoordinates.tipi1),max(tipCellData.tipdataStackCoordinates.tipj1), 'om') , 
% plot(tipCellData.tipdataStackCoordinates.tipi1,tipCellData.tipdataStackCoordinates.tipj1,'.g')
% hold off
% axes(handles.axes3)
% imagesc(tipCellData.tipzs, tipCellData.tiprows,tipCellData.im2); 
% hold all, plot(mean(tipCellData.tipdataStackCoordinates.tipj2),mean(tipCellData.tipdataStackCoordinates.tipi2), 'om'), 
% plot(tipCellData.tipdataStackCoordinates.tipj2,tipCellData.tipdataStackCoordinates.tipi2,'.g')
% hold off
%        
% actualTipPixels = tipCellData.tipdata.coordinates+[tipCellData.tiprows(1) tipCellData.tipcols(1) tipCellData.tipzs(1)] -[1 1 1]  ; 
% tipCellData.tipMeasuredLocation = actualTipPixels;
% set(handles.tipMeasuredLocationT,'String', [sprintf('%.2f', actualTipPixels(1)), '     ', sprintf('%.2f', actualTipPixels(2)),'     ',sprintf('%.2f', actualTipPixels(3))])
%  
    
    case 4   % cloak the pipet
 tipCellData.tipdata.rp2
        tipCellData.tipdata.ind2
        
 % the object I want is the one that includes the centroid of the MIP pipets
 coordinates3D = [tipCellData.tipdata.rp2(tipCellData.tipdata.ind2).Centroid(2), tipCellData.tipdata.rp3(tipCellData.tipdata.ind3).Centroid(1),  tipCellData.tipdata.rp2(tipCellData.tipdata.ind2).Centroid(1)]
 parameters.coordinates3D= round(coordinates3D);
 
 
tipCellData.tipBinary= brl_identify_tip(tipCellData.normTipImage> 255*get(handles.tipThreshold, 'Value'),parameters);
tipCellData.cloakedTipImg = brl_cloak_object(tipCellData.normTipImage, tipCellData.tipBinary);



axes(handles.axes1)
imagesc(tipCellData.tipcols, tipCellData.tiprows,squeeze(sum(tipCellData.cloakedTipImg,3))); 
hold all,
plot(max(tipCellData.tipdataStackCoordinates.tipj3),mean(tipCellData.tipdataStackCoordinates.tipi3), 'om')
plot(tipCellData.tipdataStackCoordinates.tipj3,tipCellData.tipdataStackCoordinates.tipi3,'.g'),hold off


axes(handles.axes2)
imagesc(tipCellData.tipcols, tipCellData.tipzs+udat.substackSliceStart, squeeze(sum(tipCellData.cloakedTipImg,1))'); 
hold all, 
plot(mean(tipCellData.tipdataStackCoordinates.tipi1),max(tipCellData.tipdataStackCoordinates.tipj1), 'om') , 
plot(tipCellData.tipdataStackCoordinates.tipi1,tipCellData.tipdataStackCoordinates.tipj1,'.g')
hold off


axes(handles.axes3)
imagesc(tipCellData.tipzs+udat.substackSliceStart, tipCellData.tiprows,squeeze(sum(tipCellData.cloakedTipImg,2))); 
hold all, plot(mean(tipCellData.tipdataStackCoordinates.tipj2),mean(tipCellData.tipdataStackCoordinates.tipi2), 'om'), 
plot(tipCellData.tipdataStackCoordinates.tipj2,tipCellData.tipdataStackCoordinates.tipi2,'.g')
hold off
    
actualTipPixels = tipCellData.tipdata.coordinates+[tipCellData.tiprows(1) tipCellData.tipcols(1) tipCellData.tipzs(1)] -[1 1 1]  ; 
tipCellData.tipMeasuredLocation = actualTipPixels;
set(handles.tipMeasuredLocationT,'String', [sprintf('%.2f', actualTipPixels(1)), '     ', sprintf('%.2f', actualTipPixels(2)),'     ',sprintf('%.2f', actualTipPixels(3))])

set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);






end




% --- Executes on selection change in cellImageSelectorPM.
function cellImageSelectorPM_Callback(hObject, eventdata, handles)
% hObject    handle to cellImageSelectorPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cellImageSelectorPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cellImageSelectorPM
tipCellData = get(handles.figure1, 'UserData');
if isfield(tipCellData, 'lastCellLocation')
set(handles.cellOriginalLocationT,'String', num2str(tipCellData.lastCellLocation([2 1 3]) ,'%.2f   '))
end
udat = get(findobj(0,'name','smartACT'),'UserData')

currentSelection = get(hObject,'Value')
switch currentSelection
    
      case 1
          'image data'
          imdat3D = tipCellData.rawCellImage;
          mean(imdat3D(:))
        axes(handles.axes4)
imagesc(squeeze(sum(imdat3D,3)));colormap gray
axes(handles.axes5)
imagesc((squeeze(sum(imdat3D,1)))');
axes(handles.axes6)
imagesc(squeeze(sum(imdat3D,2)));
set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);  
          
          
          
    case 2
        'norm data'
        imdat3D = tipCellData.normCellImage;
        mean(imdat3D(:))
    
    axes(handles.axes4)
imagesc(tipCellData.cellcols, tipCellData.cellrows,squeeze(sum(imdat3D,3)));
axes(handles.axes5)
imagesc(tipCellData.cellcols, tipCellData.cellzs, (squeeze(sum(imdat3D,1)))');
axes(handles.axes6)
imagesc(tipCellData.cellzs,  tipCellData.tiprows, squeeze(sum(imdat3D,2)));
set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);
    
    
    
        imdat3D = tipCellData.normCellImage;
        set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);

 
    case 3
        set(handles.figure1, 'UserData', tipCellData);
        guidata(hObject, handles);
        feval(@locateCellB_Callback, handles.locateCellB, [], guidata(handles.locateCellB))
                guidata(hObject, handles);

%           'segment data';
% % generate MIPs after smoothing and locate cells
% 
% mean(tipCellData.normTipImage(:))
%         params.big = 20;
%         params.small = 2;
%         params.thresh =255*get(handles.cellThreshold,'Value');
% tipCellData.locateCellStruct = brl_locate_cells(tipCellData.normCellImage,params);
% keepRegions=[];
% actualCellPixels = [];
% for i = 1:numel(tipCellData.locateCellStruct.rpdata)
% idat=    tipCellData.locateCellStruct.rpdata(i);
% 
% actualCellPixels(i,:) = tipCellData.locateCellStruct.rpdata(i).Centroid([2 1 3])+[tipCellData.cellrows(1) tipCellData.cellcols(1) tipCellData.cellzs(1)+udat.substackSliceStart] -[1 1 1]  
% if idat.Area >100
% 
%     keepRegions =[keepRegions; i]
% end
% 
% end
% 
% 
% %  figure out which object is the cell of interest
% 
% % 1. find the objects that are big enough to be cells
% 
% if numel(keepRegions)==1
%     tipCellData.cellLocationPixels = actualCellPixels(keepRegions,:);
% cellnumber=1
% 
% 
% else
% 
% % if there is more than one of these, 
% % 2. find the object whos centroid is closest to the original cell location
% 
% distances = sqrt(sum((actualCellPixels(keepRegions(:),:)- repmat(tipCellData.lastCellLocation([2,1,3]), numel(keepRegions),1)).^2,2));
% 
% % note that this is NOT scaled to microns, just in voxels.  
% 
% if min(distances)> 15  % hard coded estimate here... many ways to parameterize this if needed
%     set(handles.cellMeasuredLocationT,'String','cell displacement greater than ~18 microns')
% set(handles.figure1, 'UserData', tipCellData);
% guidata(hObject, handles);
% return
% end
% % take the closest one...
% cellnumber = keepRegions(distances(:)==min(distances(:)))
% tipCellData.cellLocationPixels = actualCellPixels(cellnumber,:);
% 
% 
% 
% end
% 
% tipCellData.cellzs+udat.substackSliceStart
% 
% axes(handles.axes4)
% imagesc(tipCellData.cellcols, tipCellData.cellrows,squeeze(max(tipCellData.locateCellStruct.labelmatrix,[],3))); 
% hold all, plot(actualCellPixels(:,2),actualCellPixels(:,1),'.b')
% plot(actualCellPixels(cellnumber,2),actualCellPixels(cellnumber,1),'or')
% hold off
% axes(handles.axes5)
% imagesc(tipCellData.cellcols, tipCellData.cellzs+udat.substackSliceStart,squeeze(max(tipCellData.locateCellStruct.labelmatrix,[],1))'); 
% hold all,plot(actualCellPixels(:,2),actualCellPixels(:,3),'.b')
% plot(actualCellPixels(cellnumber,2),actualCellPixels(cellnumber,3),'or')
% hold off
% axes(handles.axes6)
% imagesc(tipCellData.cellzs+udat.substackSliceStart,tipCellData.cellrows, squeeze(max(tipCellData.locateCellStruct.labelmatrix,[],2))); 
% hold all, plot(actualCellPixels(:,3),actualCellPixels(:,1),'.b')
%  plot(actualCellPixels(cellnumber,3),actualCellPixels(cellnumber,1),'or')
% hold off
% 
% 
% set(handles.cellMeasuredLocationT,'String', [sprintf('%.2f', actualCellPixels(cellnumber,1)), '     ', sprintf('%.2f', actualCellPixels(cellnumber,2)),'     ',sprintf('%.2f', actualCellPixels(cellnumber,3))])
%  
    
    case 4   % cloak the pipet
%  tipCellData.tipdata.rp2
%         tipCellData.tipdata.ind2
%         
%  % the object I want is the one that includes the centroid of the MIP pipets
%  coordinates3D = [tipCellData.tipdata.rp2(tipCellData.tipdata.ind2).Centroid(2), tipCellData.tipdata.rp3(tipCellData.tipdata.ind3).Centroid(1),  tipCellData.tipdata.rp2(tipCellData.tipdata.ind2).Centroid(1)]
%  parameters.coordinates3D= round(coordinates3D);
%  
%  
% tipCellData.tipBinary= brl_identify_tip(tipCellData.normTipImage> 255*get(handles.tipThreshold, 'Value'),parameters);
% tipCellData.cloakedTipImg = brl_cloak_object(tipCellData.normTipImage, tipCellData.tipBinary);
% 
% 
% 
% axes(handles.axes1)
% imagesc(tipCellData.tipcols, tipCellData.tiprows,squeeze(sum(tipCellData.cloakedTipImg,3))); 
% hold all, plot(max(tipCellData.tipdataStackCoordinates.tipj3),mean(tipCellData.tipdataStackCoordinates.tipi3), 'om'), plot(tipCellData.tipdataStackCoordinates.tipj3,tipCellData.tipdataStackCoordinates.tipi3,'.g')
% hold off
% axes(handles.axes2)
% imagesc(squeeze(sum(tipCellData.cloakedTipImg,1))'); 
% hold all, plot(mean(tipCellData.tipdataStackCoordinates.tipi1),max(tipCellData.tipdataStackCoordinates.tipj1), 'om') , plot(tipCellData.tipdataStackCoordinates.tipi1,tipCellData.tipdataStackCoordinates.tipj1,'.g')
% hold off
% axes(handles.axes3)
% imagesc(squeeze(sum(tipCellData.cloakedTipImg,2))); 
% hold all, plot(mean(tipCellData.tipdataStackCoordinates.tipj2),mean(tipCellData.tipdataStackCoordinates.tipi2), 'om'), plot(tipCellData.tipdataStackCoordinates.tipj2,tipCellData.tipdataStackCoordinates.tipi2,'.g')
% hold off
%     
% actualTipPixels = tipCellData.tipdata.coordinates+[tipCellData.tiprows(1) tipCellData.tipcols(1) tipCellData.tipzs(1)] -[1 1 1]  ; 
% tipCellData.tipMeasuredLocation = actualTipPixels;
% set(handles.tipMeasuredLocationT,'String', [sprintf('%.2f', actualTipPixels(1)), '     ', sprintf('%.2f', actualTipPixels(2)),'     ',sprintf('%.2f', actualTipPixels(3))])
% 



end


% --- Executes on button press in collectTipCellSubstackB.
function collectTipCellSubstackB_Callback(hObject, eventdata, handles)
% hObject    handle to collectTipCellSubstackB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This will start the process of collecting a substack


global spStackdata
udat = get(findobj(0,'name','smartACT'),'UserData')

info.si = 'not used';
 info.useLastFullStack = 1
 
% Collect a stack with both tip and cell. 

% 
% This requires first:
% 1.establishing a new set of fields for latest tip and cell locations in image and manipulator coordinates
% 2.at the same time, figure out how to log ALL of the relevant approach data in one place, including the 'trajectory' of 
% % measured tip locations and measured cell locations, relevant files, etc.
% 3. then I need to use brl_tif_read to read in the correct subvolumes with the correct channel
% 

zTopBuffer = 15; % increased from 10, 12/9/14
zBottomBuffer = 15; %increased form 10 12/15/14
   imageZCoordinate = [max(udat.currentTipImage(3)-zTopBuffer,1)  udat.currentCellImage(3)+zBottomBuffer]
    startz = spStackdata.origStartRelZ+(spStackdata.zStepSize*(imageZCoordinate(1)-1));
    stopz  = spStackdata.origStartRelZ+(spStackdata.zStepSize*(imageZCoordinate(2)-2))  ; % note that we don't include slice at z+zdepth 
                                                                                                      % because we want the stack to be zdepth slices
    spStackdata.substackGrab = 1;
    spStackdata.ignorePostProcessing = 0;
    udat.substackSliceStart =round(imageZCoordinate(1));
    udat.substackSliceEnd = round(imageZCoordinate(2));
  udat.substackStartz = startz;
  udat.substackStopz = stopz;    
    
    set(findobj(0,'name','smartACT'),'UserData', udat)
    set(handles.okCollectStackB,'enable', 'on', 'string', '<html>OK collect<br>Tip And Cell Stack')
    set(handles.cancelB,'enable', 'on')

    % now print the coordinates to the GUI to allow the user to check:
    set(hObject,'string',[ 'start z = ', num2str(udat.substackStartz), '  stop z = ', num2str(udat.substackStopz)], 'fontsize', 8);
%     
% try
% brl_collect_SI_Stack(startz, stopz)
% catch
% set(findobj(0,'name','smartACT'),'UserData', udat)
% end
% the rest of the action will take place triggered by the OK button
udat.substackToCollect = 'tipAndCell';


set(findobj(0,'name','smartACT'),'UserData', udat)

%importstack()
guidata(hObject, handles);



% --- Executes on button press in okCollectStackB.
function okCollectStackB_Callback(hObject, eventdata, handles)
% hObject    handle to okCollectStackB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(findobj(0,'name','smartACT'),'UserData')


set(handles.okCollectStackB,'enable', 'off')
    set(handles.cancelB,'enable', 'off')

switch udat.substackToCollect
    case 'tipAndCell'
        brl_collect_SI_Stack(udat.substackStartz, udat.substackStopz)
    case 'cellOnly'
        brl_collect_SI_Stack(udat.cellSubstackStartz, udat.cellSubstackStopz)

end




set(findobj(0,'name','smartACT'),'UserData', udat)

% the rest of the action will take place inside brl_sp_grab_handler, but
% use the other buttons here via feval
set(handles.collectTipCellSubstackB,'string','<html>Calculate New <br> Tip and Cell  Substack');
        set(handles.collectCellSubstackB,'string','<html>Calculate New <br>  Cell  Substack');

guidata(hObject, handles);


% --- Executes on button press in cancelB.
function cancelB_Callback(hObject, eventdata, handles)
% hObject    handle to cancelB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.okCollectStackB,'enable', 'off')
    set(handles.cancelB,'enable', 'off')
    
    set(handles.collectTipCellSubstackB,'string','<html>Calculate New <br> Tip and Cell  Substack');
        set(handles.collectCellSubstackB,'string','<html>Calculate New <br>  Cell  Substack');

guidata(hObject, handles);


% --- internal function to handle reading in an existing file .
function importStack(~)
% hObject    handle to anything ? (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tcuh = findobj('name','brl_tip_cell_update');
tipCellData = get(tcuh, 'UserData');
global spStackdata

if spStackdata.acquisitionRunning ==1
    return
end

udat = get(findobj(0,'Name', 'smartACT'), 'UserData');
if numel(udat) ==0
    return
end
tipCellData.archiveMode = 0;

%
tipCellData.file = brl_get_latest_file(udat.directory, '*.tif', 'Norm')
% this will be the last .tif file created, which should be the substack.
% there's not too much information to indicate this... I can check the last

scimdata = scim_openTif(tipCellData.file);
scimdata.acq
if udat.substackSliceEnd - udat.substackSliceStart + 1  == scimdata.acq.numberOfZSlices
'imported image is substack'
end

%tipCellData.file='E:\Data\BRLtest\tx\Cux2B002.tif'
%
% import defined substack.
%
% tip location
tipCellData.tipLocation =  udat.currentTipImage([1 2 3])

tipCellData.tipSubstackLocation = [tipCellData.tipLocation]-[0 0 udat.substackSliceStart-1]

tipCellData.tiprows = round([max(tipCellData.tipSubstackLocation(1)-20,1) ,tipCellData.tipSubstackLocation(1)+20]) ;
tipCellData.tipcols = round([max(tipCellData.tipSubstackLocation(2)-20,1),tipCellData.tipSubstackLocation(2)+20 ]);
tipCellData.tipzs =   round([max(tipCellData.tipSubstackLocation(3)-20,1) , tipCellData.tipSubstackLocation(3)+20]);

argh = brl_tif_read(tipCellData.file, get(udat.tipChannelh,'value'),2,tipCellData.tiprows ,tipCellData.tipcols,tipCellData.tipzs);
zlist = tipCellData.tipzs(1):tipCellData.tipzs(2);
tipCellData.tipzs =[zlist(1) zlist(size(argh,3))]
tipCellData.rawTipImage = argh;
tipCellData.normTipImage = tipCellData.rawTipImage-percentile(tipCellData.rawTipImage(:), .05);
tipCellData.normTipImage = tipCellData.normTipImage/percentile(tipCellData.normTipImage(:), get( findobj('tag','tipNormalization'), 'value'));
tipCellData.normTipImage = 255*tipCellData.normTipImage;


tipCellData.segTipImage = tipCellData.normTipImage>get(findobj('tag','tipThreshold'),'Value');

%
% import defined substack.
%


tipCellData.lastCellLocation =  udat.currentCellImage([2 1 3]);
tipCellData.cellSubstackLocation =  tipCellData.lastCellLocation-[0 0 udat.substackSliceStart-1]

tipCellData.cellrows = round([max(tipCellData.cellSubstackLocation(1)-20,1) tipCellData.cellSubstackLocation(1)+20]);
tipCellData.cellcols = round([max(tipCellData.cellSubstackLocation(2)-20,1) tipCellData.cellSubstackLocation(2)+20]);
tipCellData.cellzs = round([max(tipCellData.cellSubstackLocation(3)-10,1), tipCellData.cellSubstackLocation(3)+10])

argh = brl_tif_read(tipCellData.file, get(udat.cellChannelh,'value'),2,tipCellData.cellrows ,tipCellData.cellcols, tipCellData.cellzs);
size(argh)
zlist = tipCellData.cellzs(1):tipCellData.cellzs(2);
tipCellData.cellzs =[zlist(1) zlist(size(argh,3))]
tipCellData.rawCellImage = argh;
tipCellData.normCellImage = tipCellData.rawCellImage-percentile(tipCellData.rawCellImage(:), .05);
tipCellData.normCellImage = tipCellData.normCellImage/percentile(tipCellData.normCellImage(:), get( findobj('tag','cellNormalization'), 'value'));
tipCellData.normCellImage = 255*tipCellData.normCellImage;


set(findobj('tag', 'imageFileT'),'String', tipCellData.file);
set(findobj(0,'Name', 'smartACT'), 'UserData', udat);


set(tcuh, 'UserData', tipCellData);



% --- Executes on button press in locateTipB.
function locateTipB_Callback(hObject, eventdata, handles)
% hObject    handle to locateTipB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

udat = get(findobj('name', 'smartACT'), 'userdata');
     % recapitulate what's in the popup menu callbacks- this callback will be
     % called externally

     %
%    feval(get(handles.tipNormalization,'Callback'), handles.tipNormalization, [])
%       feval(get(handles.tipThreshold,'Callback'), handles.tipThreshold, [])
tipCellData = get(handles.figure1, 'UserData') 
set(handles.tipReportedLocationT,'String', num2str(tipCellData.tipLocation([1 2 3]), '%.2f   '))

% generate MIPs after smoothing
tval = get(handles.tipThreshold,'Value');
mean(tipCellData.normTipImage(:))


tipCellData.normTipImage = tipCellData.rawTipImage-percentile(tipCellData.rawTipImage(:), .05);
tipCellData.normTipImage(tipCellData.normTipImage(:)<0)=0;
tipCellData.normTipImage = tipCellData.normTipImage/percentile(tipCellData.normTipImage(:), get( handles.tipNormalization, 'value'));
tipCellData.normTipImage(tipCellData.normTipImage(:)>1)=1;
tipCellData.normTipImage = 255*tipCellData.normTipImage;



[tipCellData.im3, tipCellData.im2, tipCellData.im1] = brl_MIP_segmentation(tipCellData.normTipImage, tval);

% and extract coordinates:
tipCellData.tipdata = brl_find_tip_2(tipCellData.im3, tipCellData.im2, tipCellData.im1)
testStruct = tipCellData.tipdata
tipCellData.tipdataStackCoordinates = brl_tipdata_to_stack(tipCellData.tipdata, tipCellData.tiprows(1), tipCellData.tipcols(1), tipCellData.tipzs(1))

axes(handles.axes1)
imagesc(tipCellData.tipcols, tipCellData.tiprows,tipCellData.im3); 
hold all, plot(max(tipCellData.tipdataStackCoordinates.tipj3),mean(tipCellData.tipdataStackCoordinates.tipi3), 'om'), plot(tipCellData.tipdataStackCoordinates.tipj3,tipCellData.tipdataStackCoordinates.tipi3,'.g')
hold off
axes(handles.axes2)
imagesc(tipCellData.tipcols, tipCellData.tipzs,(tipCellData.im1')); 
hold all, plot(mean(tipCellData.tipdataStackCoordinates.tipi1),max(tipCellData.tipdataStackCoordinates.tipj1), 'om') , plot(tipCellData.tipdataStackCoordinates.tipi1,tipCellData.tipdataStackCoordinates.tipj1,'.g')
hold off
axes(handles.axes3)
imagesc(tipCellData.tipzs, tipCellData.tiprows,tipCellData.im2); 
hold all, plot(mean(tipCellData.tipdataStackCoordinates.tipj2),mean(tipCellData.tipdataStackCoordinates.tipi2), 'om'), plot(tipCellData.tipdataStackCoordinates.tipj2,tipCellData.tipdataStackCoordinates.tipi2,'.g')
hold off
    
actualTipPixels = tipCellData.tipdata.coordinates+[tipCellData.tiprows(1) tipCellData.tipcols(1) tipCellData.tipzs(1)+udat.substackSliceStart] -[1 1 1]   ; 
tipCellData.tipMeasuredLocation = actualTipPixels;
set(handles.tipMeasuredLocationT,'String', [sprintf('%.2f', actualTipPixels(1)), '     ', sprintf('%.2f', actualTipPixels(2)),'     ',sprintf('%.2f', actualTipPixels(3))])



% now update the smartACT userdata struct with the new tip coordinates

iTip = udat.Locations.pipetTip;

% and in microns
actualTipMicrons= actualTipPixels([2 1 3]).*([udat.xScale udat.yScale udat.zScale]);
% and relative coordinates for the MP285

actualTipMP285= [iTip(1:2) -iTip(3)]+[-actualTipMicrons(1:2) actualTipMicrons(3)];


if ~isfield(udat, 'tipTraj')
        udat.tipTraj=[];
    end
    % update a trajectory for the tip.  it's ok if the last position
    % repeats or something....   |  prev tip pixels  | prev tip Microns |  prev tip mp285   | new tip pixels |    new tip microns |    new tip mp285
    udat.tipTraj = [udat.tipTraj; [udat.currentTipImage, udat.currentTipMicrons, udat.CurrentLocation,actualTipPixels, actualTipMicrons, actualTipMP285]];
    newt = udat.tipTraj ; % just to echo to command line for debugging   
    
udat.potentialCoordinates.actualTipPixels = actualTipPixels;
udat.potentialCoordinates.actualTipMicrons = actualTipMicrons;
udat.potentialCoordinates.actualTipMP285 = actualTipMP285;
udat.potentialCoordinates.tipThreshold = get(handles.tipThreshold, 'value');
udat.potentialCoordinates.tipNorm = get(handles.tipNormalization,'value');

udat.tipUpdateWorked = 1;

    set(findobj('name', 'smartACT'), 'userdata',udat);




set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);




% --- Executes on button press in locateCellB.
function locateCellB_Callback(hObject, eventdata, handles)
% hObject    handle to locateCellB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%    feval(get(handles.cellNormalization,'Callback'), handles.cellNormalization, [])
%       feval(get(handles.cellThreshold,'Callback'), handles.cellThreshold, [])
      
      udat = get(findobj('name', 'smartACT'), 'userdata');

tipCellData = get(handles.figure1, 'UserData');
set(handles.cellOriginalLocationT,'String', num2str(tipCellData.lastCellLocation([1 2 3]) ,'%.2f   '))

      params.big = 20;
        params.small = 2;
        params.thresh =255*get(handles.cellThreshold,'Value');
tipCellData.locateCellStruct = brl_locate_cells(tipCellData.normCellImage,params);
keepRegions=[];
actualCellPixels = [];
for i = 1:numel(tipCellData.locateCellStruct.rpdata)
idat=    tipCellData.locateCellStruct.rpdata(i);

actualCellPixels(i,:) = tipCellData.locateCellStruct.rpdata(i).Centroid([2 1 3])+[tipCellData.cellrows(1) tipCellData.cellcols(1) tipCellData.cellzs(1)+udat.substackSliceStart] -[1 1 1]  
if idat.Area > 100

    keepRegions =[keepRegions; i]
end

end


%  figure out which object is the cell of interest

% 1. find the objects that are big enough to be cells
distances = sqrt(sum((actualCellPixels(keepRegions(:),:)- repmat(tipCellData.lastCellLocation([1 2 3]), numel(keepRegions),1)).^2,2))

if numel(keepRegions)==1
    tipCellData.cellLocationPixels = actualCellPixels(keepRegions,:);
    cellnumber =1;
elseif numel(keepRegions)==0
    udat.cellUpdateWorked = 0;
    set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);
else

% if there is more than one of these, 
% 2. find the object whos centroid is closest to the original cell location

distances = sqrt(sum((actualCellPixels(keepRegions(:),:)- repmat(tipCellData.lastCellLocation([1 2 3]), numel(keepRegions),1)).^2,2))


% note that this is NOT scaled to microns, just in voxels.  

if min(distances)> 17  % hard coded estimate here... many ways to parameterize this if needed
    set(handles.cellMeasuredLocationT,'String','cell displacement greater than ~20 microns')
set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);
return
end
% take the closest one...
cellnumber = keepRegions(distances(:)==min(distances(:)));
    tipCellData.cellLocationPixels = actualCellPixels(cellnumber,:);



end



axes(handles.axes4)
imagesc(tipCellData.cellcols, tipCellData.cellrows,squeeze(max(tipCellData.locateCellStruct.labelmatrix,[],3))); 
hold all, plot(actualCellPixels(:,2),actualCellPixels(:,1),'.b')
plot(actualCellPixels(cellnumber,2),actualCellPixels(cellnumber,1),'or')
hold off
axes(handles.axes5)
imagesc(tipCellData.cellcols, tipCellData.cellzs+udat.substackSliceStart,squeeze(max(tipCellData.locateCellStruct.labelmatrix,[],1))'); 
hold all,plot(actualCellPixels(:,2),actualCellPixels(:,3),'.b')
plot(actualCellPixels(cellnumber,2),actualCellPixels(cellnumber,3),'or')
hold off
axes(handles.axes6)
imagesc(tipCellData.cellzs+udat.substackSliceStart,tipCellData.cellrows, squeeze(max(tipCellData.locateCellStruct.labelmatrix,[],2))); 
hold all, plot(actualCellPixels(:,3),actualCellPixels(:,1),'.b')
 plot(actualCellPixels(cellnumber,3),actualCellPixels(cellnumber,1),'or')
hold off


set(handles.cellMeasuredLocationT,'String', [sprintf('%.2f', actualCellPixels(cellnumber,1)), '     ', sprintf('%.2f', actualCellPixels(cellnumber,2)),'     ',sprintf('%.2f', actualCellPixels(cellnumber,3))])
 

% now update the smartACT userdata struct with the new cell coordinates

iTip = udat.Locations.pipetTip

% convert from pixels to microns
aCellMicrons= actualCellPixels(cellnumber,:).*([udat.xScale udat.yScale udat.zScale])
iTip


actualCellMicrons = aCellMicrons
% and substract iTip location to get to relative coordinates for the MP285
actualCellMP285= actualCellMicrons-iTip([2 1 3])
actualCellMP285 = [actualCellMP285([2 1]) actualCellMP285( 3)]


udat.currentCellMP285= [iTip(1:2) -iTip(3)]+[-udat.currentCellMicrons(1:2) udat.currentCellMicrons(3)];
udat.cellTraj=[]

if ~isfield(udat, 'cellTraj')
        udat.cellTraj=[];
end
    
% udat
% actualCellPixels
% actualCellMicrons
% actualCellMP285
% this coordinate transformation is a wreck.  image locations are good:

%  udat.currentCellImage,  vs actualCellPixels(cellnumber,[2 1 3]), and
%  these are used later
       udat.cellTraj = [udat.cellTraj; [udat.currentCellImage,actualCellPixels(cellnumber,[2 1 3])]];
    newt = udat.cellTraj  % just to echo to command line for debugging   

    udat.potentialCoordinates.currentCellImage = actualCellPixels(cellnumber,[2 1 3]);
udat.potentialCoordinates.cellThreshold = get(handles.cellThreshold, 'value');
udat.potentialCoordinates.cellNorm = get(handles.cellNormalization,'value');
    
    
    udat.cellUpdateWorked = 1;
    set(findobj('name', 'smartACT'), 'userdata',udat);



set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);





% --- Executes on slider movement.
function cellThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to cellThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tipCellData = get(handles.figure1, 'UserData');
set(handles.cellThreshValT,'String', num2str(get(handles.cellThreshold,'value')));


tipCellData.segCellImage = tipCellData.normCellImage>255*get(handles.cellThreshold,'Value');
set(handles.cellThreshValT,'String', num2str(get(handles.cellThreshold,'value')));



set(handles.figure1, 'UserData', tipCellData);
feval( @cellImageSelectorPM_Callback,handles.cellImageSelectorPM,[], handles)

guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes on slider movement.
function cellNormalization_Callback(hObject, eventdata, handles)
% hObject    handle to cellNormalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


tipCellData = get(handles.figure1, 'UserData');


tipCellData.normCellImage = tipCellData.rawCellImage-percentile(tipCellData.rawCellImage(:), .05);
tipCellData.normCellImage(tipCellData.normCellImage(:)<0)=0;
tipCellData.normCellImage = tipCellData.normCellImage/percentile(tipCellData.normCellImage(:), get( handles.cellNormalization, 'value'));
tipCellData.normTipImage(tipCellData.normTipImage(:)>1)=1;
tipCellData.normCellImage = 255*tipCellData.normCellImage;

set(handles.cellNormValT,'String', num2str(get(handles.cellNormalization,'value')));

feval( @cellImageSelectorPM_Callback, handles.cellImageSelectorPM, [], handles)


set(handles.figure1, 'UserData', tipCellData);
guidata(hObject, handles);

% --- Executes on slider movement.
function tipNormalization_Callback(hObject, eventdata, handles)
% hObject    handle to tipNormalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


tipCellData = get(handles.figure1, 'UserData');



tipCellData.normTipImage = tipCellData.rawTipImage-percentile(tipCellData.rawTipImage(:), .05);
tipCellData.normTipImage(tipCellData.normTipImage(:)<0)=0;
tipCellData.normTipImage = tipCellData.normTipImage/percentile(tipCellData.normTipImage(:), get(handles.tipNormalization, 'value'));
tipCellData.normTipImage(tipCellData.normTipImage(:)>1)=1;
tipCellData.normTipImage = 255*tipCellData.normTipImage;

tipCellData.segTipImage = tipCellData.normTipImage>255*get(handles.tipThreshold,'Value');

set(handles.tipNormValT,'String', num2str(get(handles.tipNormalization,'value')));

set(handles.figure1, 'UserData', tipCellData);

feval( @tipImageSelectorPM_Callback,handles.tipImageSelectorPM,[], handles)
set(handles.figure1, 'UserData', tipCellData);

guidata(hObject, handles);

% --- Executes on slider movement.
function tipThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to tipThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


tipCellData = get(handles.figure1, 'UserData');

tipCellData.normTipImage = tipCellData.rawTipImage-percentile(tipCellData.rawTipImage(:), .05);
tipCellData.normTipImage(tipCellData.normTipImage(:)<0)=0;
tipCellData.normTipImage = tipCellData.normTipImage/percentile(tipCellData.normTipImage(:), get( handles.tipNormalization, 'value'));
tipCellData.normTipImage(tipCellData.normTipImage(:)>1)=1;
tipCellData.normTipImage = 255*tipCellData.normTipImage;


tipCellData.segTipImage = tipCellData.normTipImage>255*get(handles.tipThreshold,'Value');
set(handles.tipThreshValT,'String', num2str(get(handles.tipThreshold,'value')));



set(handles.figure1, 'UserData', tipCellData);
feval( @tipImageSelectorPM_Callback,handles.tipImageSelectorPM,[], handles)
set(handles.figure1, 'UserData', tipCellData);

guidata(hObject, handles);



% --- Executes on button press in internalImportB.
function internalImportB_Callback(hObject, eventdata, handles)
% hObject    handle to internalImportB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

importStack()
    guidata(hObject, handles);


% --- Executes on button press in resetCellTrajectoryB.
function resetCellTrajectoryB_Callback(hObject, eventdata, handles)
% hObject    handle to resetCellTrajectoryB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
udat = get(findobj('name', 'smartACT'), 'userdata');

 udat.cellTraj=[];

    set(findobj('name', 'smartACT'), 'userdata',udat);
    guidata(hObject, handles);

    

% --- Executes on button press in collectCellSubstackB.
function collectCellSubstackB_Callback(hObject, eventdata, handles)
% hObject    handle to collectCellSubstackB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this botton collects a new stack, but only including the cell, with the
% depth of the stack coming from the text input 
% IT DOES NOT use the gui to show the image or attempt to localize the cell

global spStackdata
udat = get(findobj(0,'name','smartACT'),'UserData')

info.si = 'not used';
 info.useLastFullStack = 1
 zbstring = get(handles.stackHalfDepthT,'string');
zBuffer = str2num(zbstring)./spStackdata.zStepSize ;% convert microns to slices
zTopBuffer = zBuffer;
zBottomBuffer = zBuffer;
   imageZCoordinate = [max((udat.currentCellImage(3)-zTopBuffer),1)  udat.currentCellImage(3)+zBottomBuffer]
    udat.cellSubstackStartz = spStackdata.origStartRelZ+(spStackdata.zStepSize*(imageZCoordinate(1)-1))
    udat.cellSubstackStopz  = spStackdata.origStartRelZ+(spStackdata.zStepSize*(imageZCoordinate(2)-2))   % note that we don't include slice at z+zdepth 
    set(hObject,'string',[ 'start z = ', num2str(udat.cellSubstackStartz), '  stop z = ', num2str(udat.cellSubstackStopz)]);
    spStackdata.substackGrab = 1;
    spStackdata.ignorePostProcessing = 1;
udat.substackToCollect = 'cellOnly';
    set(handles.okCollectStackB,'enable', 'on', 'string', '<html>OK collect<br>Cell ONLY Stack')
    set(handles.cancelB,'enable', 'on')
    


set(findobj(0,'name','smartACT'),'UserData', udat)

%importstack()
guidata(hObject, handles);




function stackHalfDepthT_Callback(hObject, eventdata, handles)
% hObject    handle to stackHalfDepthT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stackHalfDepthT as text
%        str2double(get(hObject,'String')) returns contents of stackHalfDepthT as a double

    
    
    
%%  ____________  object  create functions below      -------------

% --- Executes during object creation, after setting all properties.
function cellNormalization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellNormalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% --- Executes during object creation, after setting all properties.
function cellImageSelectorPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellImageSelectorPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function tipImageSelectorPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipImageSelectorPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function tipNormalization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipNormalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function cellThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function tipThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function tipThreshValT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipThreshValT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function tipNormValT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipNormValT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function cellNormValT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellNormValT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function cellThreshValT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellThreshValT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function stackHalfDepthT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stackHalfDepthT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
