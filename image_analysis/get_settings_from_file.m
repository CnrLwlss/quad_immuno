function success = get_settings_from_file()
global c_settings c;
filename = 'cellgui_settings.mat';
success = 0;
if exist(filename,'file'),
try
load('cellgui_settings.mat','c_settings'); 
    success = 1;
catch 
end
if ~isfield(c_settings,'channel'),
    c_settings.channel = 4;
end

if ~isfield(c_settings,'autofind'),
    c_settings.autofind = 0;
end

if ~isfield(c_settings,'show_contours'),
    c_settings.show_contours = 0;
end

%if ~isfield(c_settings,'br_min'),
%    c_settings.br_min = 0;
%    c_settings.br_max = 255*255-1;
%end
if isfield(c, 'n_chan'),
    if ~isfield(c,'clim'),
        c.clim = cell(1,c.n_chan);
    end
end
end
