function draw_example_areas(draw)
global c_hand c_settings;
   try

        figure(c_hand.hfig);
        delete(findall(c_hand.hfig, 'tag','example_area_square'));
       
       if draw == 1,
           %Draw squares from 1000, 5000, 25000 125000 
        offset = 10;
         x_offset = offset;
        
         areas = [c_settings.area_min c_settings.area_max];
           for i = areas,
               area = i;
         length = sqrt(area);
   
         plot([x_offset x_offset (x_offset+length) (x_offset+length) x_offset],[offset (offset+length) (offset+length) offset offset],'-w','Tag','example_area_square');
         h = text(x_offset ,offset+length+20,num2str(area),'Color','w','FontSize',10,'tag','example_area_square');
         x_offset = x_offset + length + offset;
      end
end

   catch
    
   end

