function success = save_if_dirty(prompt)
    global c;
    success = 1;
    if isfield(c, 'dirty') && c.dirty == 1,
        if prompt == 0,
                success = save_analysis();
        else
        
        btn =  questdlg(['The currently loaded image has been changed, do you want to save the changes first?']);
       switch btn,
           case 'Yes'
                success = save_analysis();
           case 'No'
           case 'Cancel'
               success = 0;
       end 
        end
    end

