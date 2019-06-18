function waitbar(varargin) 
    switch length(varargin),
        case 1
        message = varargin{1};
        case 2
        message = varargin{2};
        case 3
        message = varargin{2};
    end
        global c_hand;
%  statusbar(c_hand.app, message); 
    add_log(message);
     