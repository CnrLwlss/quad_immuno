function success = open_image(filename, draw, analyse, new_imstruct, force_merge, force_png)
%Can turn off draw or analyse by setting flags. Also, new_imstruct is only
%set for a BRAND new image

%I don't set image_file_name here as a global variable, as filename_root includes the path
%But for simple images you need to set the image_file_name. So that is set
%in the button handler instead.

%If we are performing automatic cell ID, we MUST use the png, but otherwise
%the jpg will do fine.

success = 1;
global c_settings c_hand c c_im image_file_path; %This retains the folder
c_im.file_root = replace_ext(filename, '');
[~, ~, image_ext] = fileparts(filename); 
c_im.data = []; %We are definitely loading a new one.
fullpath = fullfile(image_file_path, filename);
c.image_ext = image_ext;
try
if c_hand.hfig ~= 0,
   close(c_hand.hfig);
   c_hand = c_hand_blank(c_hand.app);
end
catch
end

h = waitbar(0,'Opening image...');
%    msgbox(javaclasspath('-dynamic'));

%I was going to make it optional to re-open the czi file, so reconstruct it
%from the png files, but actually we need to know the number of channels
%etc.

%So, it is better to make sure that the iaf file is ALWAYS saved.
%Must be c.image_ext, not c_im (which is the jpg or png copy of the image)
switch c.image_ext,
    case '.czi'
        try
        data =   bfopen(fullpath);
        catch ME
            waitmsgbox(getReport(ME))
            success = 0;
            return;
        end
    case '.zvi'
        try
             data =   bfopen(fullpath);
        catch ME
            waitmsgbox(getReport(ME))
            success = 0;
            return; 
        end
    case '.tif'
        info = imfinfo(fullpath);
        num_images = numel(info);
        data = cell(1, 1);
        data{1,1} = cell(num_images, 1);
          for i = 1:num_images,
               data{1,1}{i}= imread(fullpath, i);
          end
        %Split the channels into a data thing that looks like the czi
        %format
end        
%Save the channels one by one, as we will load them independently and only
%keep in memory the display channel and the boundary channel, IF we are
%doing the autocell.

%I used to preserve the clim array, but I don't know why. The whole 'c'
%structure needs re-created! But ONLY if it is specifically requested. 
if new_imstruct == 1,
    c = struct();
    c.image_ext = image_ext;
    c.n_chan = size(data{1,1},1); %This is the number of channels
    c.clim = cell(1,c.n_chan);
end

if ~exist([image_file_path c_im.file_root], 'dir'),
    mkdir([image_file_path c_im.file_root]);
end

update_channel_list();


for i = 1:c.n_chan, %This is the number of channels
    file = [image_file_path c_im.file_root '/ch' num2str(i) '.png']; %I use png, it is lossless

    if ~exist(file,'file') || isempty(c.clim{i}),
        %Need these if either we need to do the visible range or save the
        %jpg
        d = data{1,1}{i};
        d_min = prctile(d(:), 1);
        d_max = prctile(d(:), 99);
        %The default max is bad, since we are making everything too bright.
        %It is difficult to get the right metric for adjusting it though...
        %I think that having about HALF the image, on average, black, is
        %probably good. So how about adding on the range itself to the max.
        %Nice.
        d_max = min(d_max + (d_max - d_min), 2^16);
        do_clim = 1;
    else
        do_clim = 0;
    end

    if ~exist(file,'file'),
        h = waitbar(0.1+i*0.1, h,['Saving channel ' num2str(i) '...']);
        imwrite(d, file, 'bitdepth',16);
        file = [image_file_path c_im.file_root '/ch' num2str(i) '.jpg']; %I use png, it is lossless
  
        save_jpeg(d, d_min, d_max, i);        
    end
    
    if c_settings.channel == i,
         c_im.data = data{1,1}{i}; 
         c_im.image_ext = 'png';
    end
        
    %Do we save the clim anyway?? If we are just recreating the jpeg? I
    %think so. Otherwise we'd have to delete the iaf file to autocontrast.
    if do_clim==1,
        c.clim{i} = [d_min, d_max];
        c.dirty = 1;
    end
        %save the channel data
end

clim = c.clim;

if c.n_chan == 2,
    file = [image_file_path c_im.file_root '/ch' num2str(c.n_chan+1) '.jpg']   
    if ~exist(file,'file') || force_merge ==1,
        h = waitbar(0.1+i*0.1, h,'Saving merged channels 1 & 2 image...');
        v = im2uint8(cat(3, adjust(data{  1,1}{2}, clim{2}),adjust(data{1,1}{1}, clim{1})));
        v(1,1,3) = 0; %Make it 3 colours, but the last colour is blank. 
        imwrite(v, file, 'bitdepth',8);
        if c_settings.channel == c.n_chan+1,
            c_im.data = v; 
            c_im.image_ext = 'jpg';
        end
    else
        if c_settings.channel == c.n_chan+1,
            load_channel(0,0);

        end
    end
end

if c.n_chan >= 3,
    file = [image_file_path c_im.file_root '/ch' num2str(c.n_chan+1) '.jpg']   
    if ~exist(file,'file') || force_merge ==1,
        h = waitbar(0.1+i*0.1, h,'Saving merged channels 1,2, and 3 image...');
        v = im2uint8(cat(3, adjust(data{  1,1}{2}, clim{2}),adjust(data{1,1}{1}, clim{1}),adjust(data{1,1}{3}, clim{3})));
        imwrite(v, file, 'bitdepth',8);
         if c_settings.channel == c.n_chan+1,
            c_im.data = v; 
            c_im.image_ext = 'jpg';
        end
    else
        if c_settings.channel == c.n_chan+1,
            load_channel(0,0);

        end
    end
end

if c.n_chan > 3,
    file = [image_file_path c_im.file_root '/ch' num2str(c.n_chan+2) '.jpg']   
    if ~exist(file,'file') || force_merge ==1,
        h = waitbar(0.1+i*0.1, h,'Saving merged channels 2,3, and 4 image...');
        v = im2uint8(cat(3, adjust(data{1,1}{2}, clim{2}),adjust(data{1,1}{3}, clim{3}), adjust(data{  1,1}{4}, clim{4})));
        imwrite(v, file, 'bitdepth',8);
        if c_settings.channel == c.n_chan+2,
            c_im.data = v;
            c_im.image_ext = 'jpg';
        end
    else
        if c_settings.channel == c.n_chan+2,
            load_channel(0,0);
        end
    end
end          
add_log('Done',1);

clear('data');

%update the settings, since we are loading a new one and may process it.
get_settings_from_gui();

%This creates the imstruct, which no longer contains the image data, that
%is separate.




if analyse == 1,
    autocell();
end
if draw == 1,
    displayImstruct();
end

%Don't do this, as it will save an empty version of the c if we are
%recreating an old one. For batch processing make sure save is called
%anyway.
%save_analysis(); %Always save, so the iaf file is there even 
end

function vv = adjust(array, clim)
    range = double(clim(2) - clim(1));
    vv = uint8(256*double(array - clim(1))/range);  
end
