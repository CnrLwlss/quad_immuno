function load_channel(force_merge, force_png)
%force_merge forces the recalc of the merged images, used only when the
%button for merge is clicked. This is to stop the merged ones recalcing
%whenever we loop through the files
global c_settings image_file_path c_im c;

%2016.03.16 I have introduced the jpg version, which is much more efficient
%for storage. I always load that version, but if we are forced to reload
%the png we will do so.
%c_hand stores WHICH image type is currently loaded.
if force_png == 1,
    c_im.image_ext = 'png';
else
    c_im.image_ext = 'jpg';
end

file = [image_file_path c_im.file_root filesep 'ch' num2str(c_settings.channel) '.' c_im.image_ext]; %I use png, it is lossless
if exist(file,'file'),
    add_log( ['Loading channel ' num2str(c_settings.channel) '...'],0);
       c_im.data =imread(file);
    add_log( ['Loaded channel ' num2str(c_settings.channel)],0);
else
    open_image([c_im.file_root c.image_ext],0,0,0,force_merge, force_png); %Must load the channel from scratch
end
