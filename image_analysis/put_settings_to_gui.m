function put_settings_to_gui()
    %Not global setting, in case we want to check for differences
    global  c_hand c_settings;
    settings = c_settings;
    handles = guidata(c_hand.app);
    handles.showCellNum.Value = settings.show_cell_numbers ;
    handles.threshold_factor.String = num2str(settings.threshold_factor);
    handles.szMin.String = num2str(settings.area_min );
    handles.szMax.String = num2str(settings.area_max );
    handles.channel.Value = settings.channel ;
    handles.btnPromptDelete.Value = settings.prompt_delete ;
        handles.showContours.Value = settings.show_contours;
%         handles.br_min.Value = settings.br_min;
%         handles.br_max.Value = settings.br_max;
    %crop and display test are not retained.
