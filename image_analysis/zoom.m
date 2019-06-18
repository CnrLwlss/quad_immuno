function zoom(button, x, y) %button is 1 for in, 3 for out.
%button is in (1) or out (3), x and y are the centre points for the zoom.
global c c_hand;
factor = 1.5;
if button == 3,
factor = (1.0)/factor; %zoom out
end
if isfield(c_hand,'hpanel') && c_hand.hpanel ~= 0,
api = iptgetapi(c_hand.hpanel);
c.mag = c.mag*factor;
    api.setMagnificationAndCenter(c.mag,x,y);
end
