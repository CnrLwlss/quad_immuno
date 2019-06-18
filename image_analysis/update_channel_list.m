function update_channel_list()
global c c_hand;
n = c.n_chan;
list = findobj( c_hand.app,'Tag','channel');
v = list.String;

switch c.n_chan
    case 2
        v_new = [strcat({'Channel '},cellstr(num2str((1:c.n_chan)'))); 'Channels 1 & 2';];
    case 3
        v_new = [strcat({'Channel '},cellstr(num2str((1:c.n_chan)'))); 'Channels 1, 2 & 3';];
    otherwise
        v_new = [strcat({'Channel '},cellstr(num2str((1:c.n_chan)'))); 'Channels 1, 2 & 3'; 'Channels 2, 3 & 4'];
end

if ~isequal(v, v_new),
   list.String = v_new;
   list.Value = min(list.Value, size(v_new, 1));
end