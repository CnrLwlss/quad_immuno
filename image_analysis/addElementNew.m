function  addElementNew(xx,yy, button)
    global c c_hand c_settings;
    if ~isfield(c, 'newShape'),
        c.newShape = struct('cc',1);
    end
    
    switch button, 
        case 1 %left click

        c.newShape.x(c.newShape.cc) = xx; c.newShape.y(c.newShape.cc) = yy;
        hold on; 
        h = plot(c.newShape.x(c.newShape.cc),c.newShape.y(c.newShape.cc),'sg','MarkerSize',3,'Tag','newdot');
        set(h,'ButtonDownFcn',{@myFunc});
        c.newShape.cc = c.newShape.cc+1;
        case 3 %right click
        
      try
            %if it fails ignore. things may not be set
            iptremovecallback(c_hand.hfig,'WindowButtonMotionFcn',c_hand.h_movefn);
            iptremovecallback(c_hand.hfig,'WindowScrollWheelFcn',c_hand.h_scrollfn);
            catch me
            end
        if ~isfield(c.newShape, 'x'),
            return; %It's a right click when there is no new shape, so just return
        end
        c.newShape.x(c.newShape.cc) = c.newShape.x(1); c.newShape.y(c.newShape.cc) = c.newShape.y(1);
        %extend cell array first
        if ~isfield(c, 'polyData'),
            c.polyData = cell(5,0);
            c.Centroids = [];   
        end
        c.polyData{end,end+1} = [];
        %Then set poly dimensions
        c.polyData{1,end} = [c.newShape.x',c.newShape.y'];
        c.polyData{5,end} = 0; %This is NOT an automatic shape!
        A = c.newShape.x(1:end-1).*c.newShape.y(2:end)-c.newShape.x(2:end).*c.newShape.y(1:end-1);
        As = sum(A)/2;
        x_bar = (sum((c.newShape.x(2:end)+c.newShape.x(1:end-1)).*A)*1/6)/As;
        y_bar = (sum((c.newShape.y(2:end)+c.newShape.y(1:end-1)).*A)*1/6)/As;
        c.Centroids{end+1} = [x_bar,y_bar];
        contour_display(size(c.polyData,2));
        if (c_settings.show_cell_numbers),
            contour_number_display(size(c.polyData,2));
        end
        %Remove the dots
        dots = findall(c_hand.hfig,'Tag','newdot');
        delete(dots);
        %Clear the new shape
        c = rmfield(c, 'newShape');
        c.dirty = 1;
    end
    
end
