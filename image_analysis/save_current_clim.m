function save_current_clim()
%I can't find a callback to save the current clim (the contrast range) on
%the channel being displayed. So instead I need to make sure to save the
%current one whenever a button or action is done that might require it.
%So, that would be any open, save, or change of channel. Or any of the
%batch things.

%I will make sure to call it in get_settings_from_gui, as that is one of
%the settings in reality.
global c_hand c c_settings c_im image_file_path;

%Only save the contrast numbers IF the current image is png, the jpg will
%be already adjusted
if ~isempty(c_im) & isfield(c_im, 'image_ext'),
    if strcmp(c_im.image_ext,'png'),
        try
        x = imhandles(c_hand.hfig);
        if ~isequal(c.clim{c_settings.channel} ,x.Parent.CLim),
            hwait = waitbar(0, ['Saving compact version of channel ' num2str(c_settings.channel) '...']);
            c.clim{c_settings.channel} = x.Parent.CLim;
            save_jpeg(c_im.data, x.Parent.CLim(1), x.Parent.CLim(2), c_settings.channel);
            delete(hwait);
        end
        catch m
        end
    end    
    end