function scrollFn(h, eventdata)
global c c_hand;

cursorPoint = get(c_hand.himage.Parent, 'CurrentPoint');
x = cursorPoint(1,1);
y= cursorPoint(1,2);

switch eventdata.VerticalScrollCount
    case -1
        zoom(1,x,y); %in
    case 1
        zoom(3,x,y); %out
end