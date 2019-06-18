function batch_process()
global c_hand;
list = findobj(gcf,'Tag','listBatchFiles');
contents = cellstr(list.String);
h = waitbar(0,'Processing files...');
i = 0;
count = size(contents,1);
for file_root = contents',
    i = i + 1;
    h = waitbar(i/count,h, fixstr(['Processing ' file_root{:}]));
    filename = file_root{:};
    open_analysis_or_image(filename,1,0); %force png load, don't display
    %save the image
    %This doesn't work for some reason, it creates a blank image. Ignore
    %for now.
    %    print(c_hand.hfig,[image_file_path c_im.file_root ' overlay.jpg'],'-djpeg');
    analyseImstruct();
	writeImstruct();
    save_if_dirty(0);   
end
add_log('Done',1);

try
if c_hand.hfig ~= 0,
   close(c_hand.hfig);
   c_hand = c_hand_blank(c_hand.app);
end
catch
end
waitmsgbox ('All the csv files have been calculated. Now you can combine them into a merged file if you want to process them further.')
