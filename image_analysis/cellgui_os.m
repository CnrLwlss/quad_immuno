function varargout = cellgui(varargin)
% CELLGUI MATLAB code for cellgui.fig
%      CELLGUI, by itself, creates a new CELLGUI or raises the existing
%      singleton*.
%
%      H = CELLGUI returns the handle text31235231 a new CELLGUI or the handle text31235231
%      the existing singleton*.
%
%      CELLGUI('CALLBACK',hObject,eventData,handles,...) calls the lobackcal
%      function named CALLBACK in CELLGUI.M with the given input arguments.
%
%      CELLGUI('Property','Value',...) creates a new CELLGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied text31235231 the GUI before cellgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed text31235231 cellgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance text31235231 run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text text31235231 modify the response text31235231 help cellgui

% Last Modified by GUIDE v2.5 12-May-2016 09:44:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cellgui_OpeningFcn, ...
                   'gui_OutputFcn',  @cellgui_OutputFcn, ...
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


% --- Executes just before cellgui is made visible.
function cellgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle text31235231 figure
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments text31235231 cellgui (see VARARGIN)

% Choose default command line output for cellgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cellgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
try
    
    %2016.04.08 Turn off LaTex interpretation of text strings. Otherwise
    %messages show up weird if underscore or backslash are in the text.
    set(0, 'DefaulttextInterpreter', 'none')
   
    %2016.03.14 I readded this to work in the non compiled version, but it may need
    %removed for the production version!!!
    javaaddpath(which('MatlabGarbageCollector.jar'));
  
    mem = java.lang.Runtime.getRuntime.maxMemory/1e9
    if mem < 2,
       waitmsgbox(['The allocated java memory space (' num2str(round((mem),1)) ' gigabytes) is pretty small and you will not be able to edit large images. If you struggle with this then you''ll need to work on allocating more memory in JAVA. Try to find someone who knows how to do that....']);
    end
    %Having trouble with loci, so let's see which class package it is in.
   % javaaddpathstatic(which('bioformats_package.jar'));
   % javaaddpath(which('bioformats_package.jar'));

    %  javaaddpath([pwd '\bioformats_package.jar']); %This is needed so the distributable app works.
  %  javaaddpath([pwd '\loci_tools.jar']); %This is needed so the distributable app works.

    global c_settings c_original_settings image_file_ext ;
    image_file_ext = '.czi';
if get_settings_from_file(),
    put_settings_to_gui();
else
    get_settings_from_gui(); %need to do the settings here, not in the create function
    c_settings.position = get(0,'defaultfigureposition');
    %no need to set default position, it will be worked out.
end
c_original_settings = c_settings;
catch ME
       waitmsgbox(getReport(ME))
end
%    waitmsgbox(javaclasspath('-dynamic'));
% --- Outputs from this function are returned text31235231 the command line.
function varargout = cellgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle text31235231 figure
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnOpenImage.
function btnOpenImage_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 btnOpenImage (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    save_current_clim();
    get_settings_from_gui();
    global image_file_ext image_file_path c_settings c_im; %This retains the folder

    if isnumeric(image_file_path),
        image_file_path = filesep;
    end
    %addpath(genpath(pwd));

    if save_if_dirty(1) < 1,
        return;
    end

    [v,image_file_path] = uigetfile([image_file_path '.czi']);
    if v ~= 0,
        [~, name,ext] = fileparts(v);
        image_file_ext = ext;
        c_im.file_root = name;
        open_image(name,1,c_settings.autofind, 1,0);

    end 
       catch ME    
   waitmsgbox(getReport(ME))
end


% --- Executes on button press in btnProcess.
function btnProcess_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 btnProcess (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c;
save_current_clim();
get_settings_from_gui();
analyseImstruct();
writeImstruct();
waitmsgbox ('Image processed, a CSV file of the channel intensities has been saved')


% --- Executes on button press in btnSaveAnalysis.
function btnSaveAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 btnSaveAnalysis (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_current_clim();
get_settings_from_gui();
save_analysis();
waitmsgbox ('Analysis saved. An iaf file for the associated czi file has been saved in the same folder, you can reload this to recover the cell layout.')

    
% --- Executes on button press in btnOpenAnalysis.
function btnOpenAnalysis_Callback(hObject, eventdata, handles)
    % hObject    handle text31235231 btnOpenAnalysis (see GCBO)
    % eventdata  reserved - text31235231 be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
   save_current_clim();
 get_settings_from_gui();
    global image_file_path; %This retains the folder
    if isnumeric(image_file_path),
        image_file_path = filesep;
    end
    
    success = save_if_dirty(1);
    if success < 0,
        return;
    end
   
    global c;
    [v,image_file_path] = uigetfile([image_file_path '.iaf']);
if v ~= 0,
    open_analysis(v,1);
end

        
% --- Executes on button press in btnBatch	.
function btnBatchSetFolder_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 btnBatchSetFolder (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_current_clim();

global c image_file_path; %This retains the folder
if ~exist('image_file_path') || isnumeric(image_file_path) ,
    image_file_path = '/';
end
get_settings_from_gui();
    folder = [uigetdir(image_file_path) filesep];
    if folder  ~= 0,
    image_file_path = folder;
    files = load_folder(folder, 'czi');
    lbf = handles.listBatchFiles;
    files = strrep( strrep( {files.name}, [folder filesep], ''), '.czi','');
    set(lbf,'String',files);
end

x = questdlg('Is this the first time you have processed these folders? If so, please click ''Scan'' to iterate through all the czi files and extract the images. This can take a long time to process. If you don''t need to do this close the dialog with the X in the top corner. Note - if you don''t want to automatically scan for objects when opening the files make sure that ''Auto find cells on open'' is unticked before continuing. ','File scanning','Scan', 'Don''t scan','Don''t scan');
switch x,
case 'Scan'
    i = 0;
    h = waitbar(0,'Opening files...');
    for f = files,
        i = i + 1;
        h = waitbar(i/size(files,2),h,['Opening file ' num2str(i) ' of ' num2str(size(files,2   )) ' ...']);
        %We have to check if the analysis file is opened, or the image was
        %a new one. If analysis, do NOT save. Otherwise save.
        success = open_analysis_or_image(f{:},1,0); %We force the png load, as we will be generally creating them anyway, and need to have png in case we are finding objects. We don't display
        if success == 1, %success is 2 for an existing iaf file.
            if ~isfield(c, 'dirty'),
                c.dirty = 1;
            end
            save_if_dirty(0);
        end
     end
add_log('Done',1);

end  
%Now load the current batch item
load_batch_item();

% --- Executes on button press in btnBatchProcess.
function btnBatchProcess_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 btnBatchProcess (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Go through each file and save the csv file
batch_process();


% --- Executes on selection change in listBatchFiles.
function listBatchFiles_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 listBatchFiles (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listBatchFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listBatchFiles
global c_hand;

%This detects double clicking, but that still sends a single click through,
%which we don't like as it forces reloading of each image you are renaming,
%slow. So instead I have a tickbox for 'rename mode';

%typ = get(c_hand.app, 'selectiontype');
%if  strcmp(typ,'open'),%This picks up a double click
if get(findobj(c_hand.app, 'Tag','rename_mode'),'Value') == 1,
    contents = cellstr(get(hObject,'String'));
    current = contents{hObject.Value};
    new_name = rename_item(current );
    if ~isempty(new_name),
       contents{hObject.Value} = new_name; 
       set(hObject,'String',contents);
       add_log(['Renamed ' current ' as ' new_name],1);
    end
else
    load_batch_item();
end




% --- Executes during object creation, after setting all properties.
function listBatchFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle text31235231 listBatchFiles (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mergeImaris.
function mergeImaris_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 mergeImaris (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_current_clim();
global g_folder;
if g_folder ~= 0,
    files = load_folder(g_folder, 'csv');
    files = {files.name};
    [outfile pathname] = uiputfile('*.csv','Choose a filename to save the output for further analysis');
    if outfile ~= 0,
        merge_imaris_csvs(g_folder, files,[pathname outfile]);
    end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over mergeImaris.
function mergeImaris_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle text31235231 mergeImaris (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mergeImarisXLS.
function mergeImarisXLS_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 mergeImarisXLS (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_current_clim();
global g_folder;
if g_folder ~= 0,
    files = load_folder(g_folder, 'xls');
    files = {files.name};
    [outfile pathname] = uiputfile('*.csv','Choose a filename to save the output for further analysis');
    if outfile ~= 0,
        merge_imaris_xlss(g_folder, files,[pathname outfile]);
    end
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over mergeImarisXLS.
function mergeImarisXLS_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle text31235231 mergeImarisXLS (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on button press in btnPromptDelete.
function btnPromptDelete_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 btnPromptDelete (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_current_clim();

% Hint: get(hObject,'Value') returns toggle state of btnPromptDelete
global c_settings;
c_settings.prompt_delete = hObject.Value;

function success = check_and_load(filename_root, force_png)
    success = save_if_dirty(1);
    if success == 1,
        success= open_analysis_or_image(filename_root, force_png,1); %We force display, dunno if we need to but safer
    end


    

% --- Executes on button press in btnMergeBatch.
function btnMergeBatch_Callback(hObject, eventdata, handles)
save_current_clim();
% hObject    handle text31235231 btnMergeBatch (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get_settings_from_gui();
global this_out_path;

if size(this_out_path,1) == 0,
   this_out_path = [getenv('HOMEDRIVE') getenv('HOMEPATH')]; 
end
list = findobj(gcf,'Tag','listBatchFiles');
contents = cellstr(list.String);

[outfile pathname] = uiputfile([this_out_path '*.csv'],'Choose a filename to save the output for further analysis');
if outfile ~= 0,
    merge_batch_csvs(contents', [pathname outfile]);
end
this_out_path = pathname;

function threshold_factor_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 threshold_factor (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_factor as text
%        str2double(get(hObject,'String')) returns contents of threshold_factor as a double


% --- Executes during object creation, after setting all properties.
function threshold_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle text31235231 threshold_factor (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function szMin_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 szMin (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of szMin as text
%        str2double(get(hObject,'String')) returns contents of szMin as a double
do_min_max();

% --- Executes during object creation, after setting all properties.
function szMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle text31235231 szMin (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function szMax_Callback(hObject, eventdata, handles)
% hObject    handle text31235231 szMax (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of szMax as text
%        str2double(get(hObject,'String')) returns contents of szMax as a double
do_min_max();

% --- Executes during object creation, after setting all properties.
function szMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle text31235231 szMax (see GCBO)
% eventdata  reserved - text31235231 be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showCellNum.
function showCellNum_Callback(hObject, eventdata, handles)
% hObject    handle to showCellNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c_settings;
% Hint: get(hObject,'Value') returns toggle state of showCellNum
 c_settings.show_cell_numbers = eventdata.Source.Value;
    show_cell_numbers();



% --- Executes on button press in btnUpdate.
function btnUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to btnUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c  c_settings c_im;
settings_old = c_settings;
get_settings_from_gui(); %need to do the settings here in case they have changed

if (settings_old.channel ~= c_settings.channel),
    imstruct.filename = c.filename;
    c = imstruct; %set it to erase previous data. NO need to save the channel in the c struct, it is set in autocell.
    %swap them over 
end
autocell();
displayImstruct();


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text11.
function text11_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://research.ncl.ac.uk/mitoresearch/immuno/');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
save_if_dirty(1);
global  c_original_settings c_hand c_settings;
get_settings_from_gui();
if ~isequal(c_original_settings, c_settings ),
btn =  questdlg('The general settings have been changed, do you want to save them as the defaults?');
               switch btn,
                   case 'Yes'
                       put_settings_to_file();
                       delete(hObject);
                   case 'No'
                       delete(hObject);
                   case 'Cancel'
               end
else
    try
       close(c_hand.hfig); 
    catch
    end
   delete(hObject);
end
catch ME
    waitmsgbox(getReport(ME))
    delete(hObject);
end
% Hint: delete(hObject) closes the figure


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global c c_hand c_settings;

c_hand = c_hand_blank(gcf);

c = struct(); %just a blank one

addpath(genpath(pwd));


% --- Executes on selection change in channel.
function channel_Callback(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel
set_current_channel();


% --- Executes during object creation, after setting all properties.
function channels_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in example_areas.
function example_areas_Callback(hObject, eventdata, handles)
% hObject    handle to example_areas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of example_areas
get_settings_from_gui();
draw_example_areas(get(hObject,'Value'));

% --- Executes on button press in crop.
function crop_Callback(hObject, eventdata, handles)
% hObject    handle to crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get_settings_from_gui();
do_crop(get(hObject,'Value'));

% Hint: get(hObject,'Value') returns toggle state of crop

function do_min_max()
global c_hand c_settings;
get_settings_from_gui();
h = findobj(c_hand.app, 'tag','example_areas');
draw_example_areas(h.Value);


% --- Executes on button press in autofind.
function autofind_Callback(hObject, eventdata, handles)
% hObject    handle to autofind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c_hand c_settings;
get_settings_from_gui();



function javaaddpathstatic(file, classname)
%JAVAADDPATHSTATIC Add an entry to the static classpath at run time
%
% javaaddpathstatic(file, classname)
%
% Adds the given file to the static classpath. This is in contrast to the
% regular javaaddpath, which adds a file to the dynamic classpath.
%
% Files added to the path will not show up in the output of
% javaclasspath(), but they will still actually be on there, and classes
% from it will be picked up.
%
% Caveats:
%  * This is a HACK and bound to be unsupported.
%  * You need to call this before attempting to reference any class in it,
%    or Matlab may "remember" that the symbols could not be resolved. Use
%    the optional classname input arg to let Matlab know this class exists.
%  * There is no way to remove the new path entry once it is added.
 
% Andrew Janke 20/3/2014 http://stackoverflow.com/questions/19625073/how-to-run-clojure-from-matlab/22524112#22524112
 
parms = javaArray('java.lang.Class', 1);
parms(1) = java.lang.Class.forName('java.net.URL');
loaderClass = java.lang.Class.forName('java.net.URLClassLoader');
addUrlMeth = loaderClass.getDeclaredMethod('addURL', parms);
addUrlMeth.setAccessible(1);
 
sysClassLoader = java.lang.ClassLoader.getSystemClassLoader();
 
argArray = javaArray('java.lang.Object', 1);
jFile = java.io.File(file);
argArray(1) = jFile.toURI().toURL();
addUrlMeth.invoke(sysClassLoader, argArray);
 
if nargin > 1
    % load the class into Matlab's memory (a no-args public constructor is expected for classname)
    eval(classname);
end


% --- Executes on button press in showContours.
function showContours_Callback(hObject, eventdata, handles)
% hObject    handle to showContours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c_hand c_settings;
get_settings_from_gui();
do_cell_contours();    
% Hint: get(hObject,'Value') returns toggle state of showContours

% --- Executes on button press in contrast.
function contrast_Callback(hObject, eventdata, handles)
% hObject    handle to contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_current_clim();
global c_hand c_im;
if c_hand.hfig ~= 0 && isvalid(c_hand.hfig),
    if c_hand.contrast ~= 0,
        try
            delete (c_hand.contrast );
        catch me
        end
         
%        if ~isvalid(c_hand.contrast),
 %           c_hand.contrast = 0;
 %       else
 %           figure(c_hand.contrast);
 %       end
    end
    
    
   % if c_hand.contrast == 0,
        %Make sure that the current figure is loaded as png.
        if ~strcmp(c_im.image_ext,'png') 
%            c_im.image_ext = 'png'; %this is set in load_channel anyway.
            load_channel(0,1);
            drawImage(0);
        end
        c_hand.contrast  = imcontrast(c_hand.hfig);
    %end
end


     


% --- Executes on button press in btnRedoMerge.
function btnRedoMerge_Callback(hObject, eventdata, handles)
% hObject    handle to btnRedoMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c_settings c image_file_path c_im;
get_settings_from_gui();
file = [image_file_path c_im.file_root '/ch' num2str(c.n_chan+1) '.jpg']; %merged is jpg
if exist(file,'file'),
    delete(file);
end
c_settings.channel = c.n_chan+1;
put_settings_to_gui();
load_channel(1,0); %force the merge recalcuation
drawImage(0);

function set_current_channel()
save_current_clim();
get_settings_from_gui();
load_channel(0,0); %Don't force the png by default.
drawImage(0);

function load_batch_item()
global image_file_ext c_hand c_im;
hObject = findobj(c_hand.app, 'tag','listBatchFiles');
contents = cellstr(get(hObject,'String'));
val = min(size(contents, 1),hObject.Value);
if val ~= hObject.Value,
    hObject.Value = val;
end
current = contents{hObject.Value};
    if isempty(c_im) || ~strcmp(c_im.file_root, current),
   if ~isempty(c_im),
        old = c_im.file_root;
   else
       old = [];
   end
        image_file_ext = '.czi';
   % c_im.file_root = current; %CAN'T DO THIS BEFORE CALLING CHECK AND
   % LOAD!!!!!!!! IF you do, it saves the shapes on the wrong image.
   
   if check_and_load(current,0) == 0, %we don't by default load the png, but maybe we should...
       c_im.file_root = old; %revert if fail
   end
end



function log_Callback(hObject, eventdata, handles)
% hObject    handle to log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of log as text
%        str2double(get(hObject,'String')) returns contents of log as a double


% --- Executes during object creation, after setting all properties.
function log_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rename_mode.
function rename_mode_Callback(hObject, eventdata, handles)
% hObject    handle to rename_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rename_mode


% --- Executes on button press in savemap.
function savemap_Callback(hObject, eventdata, handles)
% hObject    handle to savemap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_current_screenshot();

% --- Executes on button press in savemaps.
function savemaps_Callback(hObject, eventdata, handles)
% hObject    handle to savemaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c_hand image_file_path c_im;
list = findobj(gcf,'Tag','listBatchFiles');
contents = cellstr(list.String);
h = waitbar(0,'Screenshotting files...');
i = 0;
count = size(contents,1);
for file_root = contents',
    i = i + 1;
    h = waitbar(i/count,h, fixstr(['Screenshotting ' file_root{:}]));
    open_analysis_or_image(file_root{:},0,1); %force jpg load, and display

    save_current_screenshot();
end

function save_current_screenshot()
    drawnow; %force it to update the screen
global c_hand c_im image_file_path;
f = getframe(c_hand.hfig);
im = frame2im(f);
imwrite(im,[image_file_path c_im.file_root '_screenshot.jpg']);


