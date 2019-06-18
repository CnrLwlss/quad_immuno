function drawImage(automag)
global c c_hand c_im c_settings;
%This draws the image in a scrollable window. The resize was not working,
%so I manually redraw it on a resize.
%just make sure the figure is selected     
if c_hand.hfig == 0 || ~isvalid(c_hand.hfig),
    displayImstruct();
    return;
end;
    disp(['drawing image ' c_im.file_root]);
    figure(c_hand.hfig);
    %If we don't specify the clim range it will sometimes use one from a
    %previous image, this makes it consistent.


if ~isfield(c_hand, 'hpanel_parent')
   c_hand.hpanel_parent = 0;
end

  if strcmp(c_im.image_ext,'png'), 
    if ~isfield(c,'clim'),
        c.clim = cell(1,c.n_chan);
    end
    if c_settings.channel <= c.n_chan,
        if isempty(c.clim{c_settings.channel}),
           c.clim{c_settings.channel} = [min(c_im.data(:)) max(c_im.data(:))];
        end
        clim = c.clim{c_settings.channel};
    else 
        clim = [];
    end
  else
      clim = [];
  end

if c_hand.hpanel_parent== 0,
    do_contours = 1;
    c_hand.hpanel_parent = uipanel('Units','normalized','position',[0 0 1 1]);
    c_hand.haxes = axes('parent',c_hand.hpanel_parent,'position',[0 0 1 1],'Units','normalized');
    %Create the image handle
        c_hand.himage = imshow(c_im.data,'parent',c_hand.haxes);
	c_hand.hpanel = imscrollpanel(c_hand.hpanel_parent,c_hand.himage);   
    
    set(c_hand.himage,'ButtonDownFcn',{@myFunc});
    set(c_hand.hfig,'WindowScrollWheelFcn',{@scrollFn});
else
        do_contours = 0;
   api = iptgetapi(c_hand.hpanel);
   mag = api.getMagnification();
   rect = api.getVisibleImageRect();
   api.replaceImage(c_im.data);
   api.setMagnificationAndCenter(mag, rect(1) + rect(3)/2, rect(2) + rect(4)/2);
   %set the climits

end

if ~isempty(clim),
    set(c_hand.haxes,'clim',double(clim));
    disp('drawing with existing contrast limits');
end


api = iptgetapi(c_hand.hpanel);
hold on;
      

        if automag == 1,
            c.mag = api.findFitMag();
        end
        if  api.getMagnification() ~= c.mag,
               api.setMagnification(c.mag);
        end
if do_contours ==1,
   contours_do_all();
   contour_numbers_do_all(); 
end   
    
     