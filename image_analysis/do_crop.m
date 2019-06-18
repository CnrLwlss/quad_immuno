function do_crop(val)
global c_hand c c_settings c_im;
try
    
   if c_hand.hfig == 0 || ~isvalid(c_hand.hfig),
        return;
   end
    
   %delete any polygons. as cropping will require restarting.
   if isfield(c, 'polyData'),
        c =  rmfield(c,'polyData');
   end
   if isfield(c, 'Centroids'),
       c =  rmfield(c,'Centroids');
   end
   
   if val == 1,
        figure(c_hand.hfig);
        if ~strcmp(c_im, 'png'),
             load_channel(0,1); %If we are cropping, we must use the png for use in autofind
             drawImage(1);
        end
        c_im.data = imcrop();
           if c_hand.hfig ~= 0 && isvalid(c_hand.hfig),
               close(c_hand.hfig);
           end
           c_hand = c_hand_blank(c_hand.app);
            displayImstruct();
   else
       %reload the data
      if c_hand.hfig ~= 0 && isvalid(c_hand.hfig),
          close(c_hand.hfig);
      end
      c_hand = c_hand_blank(c_hand.app);
      
       load_channel(0,0); %Cropping is going off, so don't need to load png.
       displayImstruct();
   end
catch ME
      waitmsgbox(getReport(ME));
end