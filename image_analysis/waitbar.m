function h = waitbar(varargin) 
    newline = 1;
    switch length(varargin),
        case 1
        message = varargin{1};
        newline = 1;
        case 2
        message = varargin{2};
        case 3
        message = varargin{3};
        newline = 0;
    end
        global c_hand;
 % statusbar(c_hand.app, message); 
    add_log(message, newline);
     h =0;