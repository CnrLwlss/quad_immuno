function put_settings_to_file()
global c_settings;
filename = 'cellgui_settings.mat';
save(filename,'c_settings'); 
end
