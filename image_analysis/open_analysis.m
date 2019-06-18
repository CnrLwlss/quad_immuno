  
function success = open_analysis(filename, do_display)
    global c_hand image_file_path c_im c;
 
    file_iaf = replace_ext(filename, '.iaf');
    [~, ~,  image_ext] = fileparts(filename); %This relies on the actual image name being passed, not the iaf file.
    %That is FINE for a batch processing, but if the iaf file is opened
    %directly it will fail. that said, shouldn't matter as the extension
    %should be stored in the filename inside the saved iaf file, or the
    %image_ext field if filename isn't there (old versions of the prog
    %saved the filename, new saves image_ext).
    
    if c_hand.hfig ~= 0,
   try
       close(c_hand.hfig);
   catch
   end
        c_hand = c_hand_blank(c_hand.app);
    end
    
    full_path = fullfile(image_file_path, file_iaf);

   
    try
     add_log(['Loading ' file_iaf],1);
     load(full_path, '-mat', 'c'); %Must load the iaf BEFORE the channel or the iaf gets overwritten with a blank.
      %delete any handles that are loaded for the contours or numbers
       if isfield(c, 'polyData'),     
      for i = 1:size(c.polyData,2),
           for j = 2:3,
              if c.polyData{j,i} ~= 0,
                   delete(c.polyData{j,i});
                   c.polyData{j,i} = 0;
              end
          end
       end
       end
     set_dirty = 0;
     %Initialise the c_im file root
     c_im.file_root = replace_ext(file_iaf, '');
    
    if ~isfield(c, 'n_chan'),
       %This is from an older version of the program, but we need to set the number of channels. To do that we need to re-open
       %the original image file. But, we want to maintain the existing
       %polygon info without deleting it.... Easiest way? Probably pass
       %back a code to indicate that we need to recreate everything, but
       %remember the polygon data.
       success = -10; %Recreate everything 
       delete(h);
       return;
    end
    
     %All we need to preserve from the old file is the extension, since the
    %other bits of the name can be different 
    if ~isfield(c, 'image_ext'),
            if isfield(c, 'filename'),
                [~,~,c.image_ext] = fileparts(c.filename); %There MUST be a filename field if the image_ext isn't there
                c = rmfield(c, 'filename');
                set_dirty=1;
            else
                if strcmp(image_ext, '.iaf'),
                   %This is a total problem, since we don't know the image
                   %type. Can happen if there is a corrupt iaf file. It
                   %KIND of doesn't matter as long as the jpg/png images
                   %exist though.
                   waitmsgbox('The iaf file is corrupt, and the original image type is unknown (czi, tiff, etc). But that is not a major problem and can be ignored.')
                else
                    set_dirty=1;
                    c.image_ext = image_ext; 
                end
            end
    end
    
     add_log(['Loading ' filename ' image...'],1);
     load_channel(0,0); %Don't load the png by default
    
 
    %must update this, file may have moved since we last loaded it. It is
    %now pathless. Used to have the full path.
    %Note, the path can be different anyway.
    %Actually, why store the image name here? We JUST need the extension
    
    c.dirty = set_dirty;
    
    update_channel_list();

    if do_display == 1,
        displayImstruct();
    end
    success = 2; %2 means an analysis file was opened, as opposed to 1, which is an image file
    
    catch
        close(h);
        success = 0;
    end
    