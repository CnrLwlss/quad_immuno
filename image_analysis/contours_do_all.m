function contours_do_all()
global c c_settings c_hand;
figure(c_hand.hfig);
    
if isfield(c, 'polyData'),
    for i = 1:size(c.polyData,2)
        if c_settings.show_contours == 1,
                contour_display(i);
        else
            if  c.polyData{2,i} ~= 0,
                delete(c.polyData{2,i});
                c.polyData{2,i} = 0;
            end
        end
    end
end