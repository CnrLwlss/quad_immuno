function contour_number_display(i)
global c;
try
   if isempty(c.polyData{3,i}),
             c.polyData{3,i} = 0;
   end             
     if c.polyData{3,i} == 0,
         h = text(c.Centroids{i}(1),c.Centroids{i}(2),num2str(i),'Color','c','FontSize',10);
            c.polyData{3,i} = h; %text handle
            set(h,'ButtonDownFcn',{@myFunc});
       end
   end
end