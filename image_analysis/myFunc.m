function myFunc(h, eventdata)
%The image has been clicked. If it is within an existing shape, offer to
%delete it.


    global c c_hand c_settings;

    x = eventdata.IntersectionPoint(1);
    y = eventdata.IntersectionPoint(2);
    button = eventdata.Button;
    
    %if it is zoom, then zoom!
   
    if strcmp(c_hand.tb_zoom.State,'on'),

        zoom(button, x, y);
        return; 
    end
    
    cc = 1; 
    found = 0;
    if isfield(c, 'polyData'),
        for i = 1:size(c.polyData,2)
            LL = cell2mat(c.polyData(1,i));
            if inpolygon(x,y, LL(:,1), LL(:,2)),
                found = 1;
               remove = 0;

               if c_settings.prompt_delete == 1,
                   btn =  questdlg(['Do you want to delete cell number ' num2str(i) '?']);
                   switch btn,
                       case 'Yes'
                            remove = 1;
                       case 'No'
                       case 'Cancel'
                   end
               else
                   remove = 1;
               end
                   if remove == 1,

                    removeElement(i);
                    break;
               end

            end
        end
    end
    if found == 0,
        
        %Depends on the edit mode
        switch c_hand.mode 
            case 'edit'
               %Start a new shape
                  addElementNew( x,y, button);
            case 'poly'
                if button == 1,
                    try
                        %if it fails ignore. things may not be set
                    iptremovecallback(c_hand.hfig,'WindowButtonMotionFcn',c_hand.h_movefn);
                
                    catch me
                    end

                    %First dot
                    addElementNew( x,y, button);
                    %Set up a timer to check progress.
                   c_hand.h_movefn = iptaddcallback(c_hand.hfig, 'WindowButtonMotionFcn', @polyfn);
                else
                    addElementNew( x,y, button);
                end
        end
    end
    
end

function polyfn(varargin)
global c ;
    last_point = [c.newShape.x(end) c.newShape.y(end)];
    C = get (gca, 'CurrentPoint');
    C = C(1,1:2); %get just the position

    V = C - last_point;
    D = sqrt(V * V');
    if D > 3,
          addElementNew( C(1),C(2), 1);
    end
end

