function get_settings_from_gui()
    %Not global setting, in case we want to check for differences
    %Actually, it is the global settings. Otherwise we may lose position
    %etc.
    global  c_hand c_settings c ;
    
    %The gui doesn't store the clim (colour range) explicitly, but the
    %contrast adjustment can change it. Need to intercept it.
    %Do this BEFORE updating the channel, so it uses the old one if the
    %channel is changing!   
    %Note, this won't be set if we don't have a current image, but that's
    %fine
    if isfield(c, 'n_chan'),
        if ~isfield(c,'clim'),
          c.clim = cell(1,c.n_chan);
        end
    end        
    save_current_clim();
    
    handles = guidata(c_hand.app);
    c_settings.show_cell_numbers = handles.showCellNum.Value;
    c_settings.threshold_factor = str2num(handles.threshold_factor.String);
    c_settings.area_min = str2num(handles.szMin.String);
    c_settings.area_max = str2num(handles.szMax.String);
    c_settings.channel = handles.channel.Value;
    c_settings.prompt_delete = handles.btnPromptDelete.Value;
    c_settings.autofind = handles.autofind.Value;
    c_settings.show_contours = handles.showContours.Value;

    %  c_settings.br_min = handles.showContours.Value;
%  c_settings.br_max = handles.showContours.Value;

   