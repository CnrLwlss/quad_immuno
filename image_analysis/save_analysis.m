function success = save_analysis()
%image only means don't save the analysis, just the image itself from the
%czi
global c image_file_path c_im ;
    h = waitbar(0,'Saving...');
    h = waitbar(0.9,h,'Saving cellular analysis...');
        c.dirty = 0;
        save([image_file_path c_im.file_root '.iaf'],'c');
add_log('Done',1);

    success = 1;
