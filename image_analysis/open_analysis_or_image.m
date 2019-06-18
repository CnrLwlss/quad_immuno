
function success = open_analysis_or_image(filename, force_png, do_display)
    global image_file_path c_im c c_settings;
    success = 0;
        file_iaf = replace_ext(filename, '.iaf');
%Try to load the iaf, but if there is an error, just open the image
        if exist(fullfile(image_file_path, file_iaf), 'file'),
        try
        success = open_analysis(filename, do_display); %We pass the actual image name here. This is so that it can know what the image type is, in case the saved file doesn't hvae the image type in it. Can happen by errors.
        catch
        end
    end
       
     if success < 1,
         if success == -10, %there IS an iaf file, but it is the old format
            retain_c = 1;
             old_c = c; 
         else
             retain_c = 0;
         end
        success = open_image(filename,1,c_settings.autofind,1,0,force_png); %We are told if we are forcing png
        %now copy over the poly data etc
        if retain_c == 1    ,
            try
            c.polyData = old_c.polyData;
            c.Centroids = old_c.Centroids;
            catch me
                %ignore an error, it just means that there are no polygons
                %anyway.
            end
            save_analysis();
        end
     end
    
  c_im.file_root = replace_ext(filename,'');