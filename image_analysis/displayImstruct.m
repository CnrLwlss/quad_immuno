function displayImstruct()
% inputs: c, Channel.  Channel is either nothing, in which case each
% channel is displayed, otherwise, Ch Channel is displayed.
global c c_hand c_settings c_im; %work on the global one, saves copying
try

       
        if c_hand.hfig == 0 || ~isvalid(c_hand.hfig),
            
            if (c_hand.hfig ~=0 &&  ~isvalid(c_hand.hfig)),
               c_hand = c_hand_blank(c_hand.app); 
            end
            
            c_hand.hfig = figure('Name',c_im.file_root,'NumberTitle','off', 'SizeChangedFcn',@sbar,'MenuBar','none','Toolbar','none','Position',c_settings.position);
            %load mag glass icon
            c_hand.htoolbar = uitoolbar(c_hand.hfig);
            c_hand.mode = 'poly';
            c_hand.tb_edit = uitoggletool(c_hand.htoolbar,'CData',imread('draw.png'),'OnCallback',{@mymode, 'edit'},'OffCallback',{@mymode, 'edit'}, ...
           'TooltipString','Edit mode (left-click to set points, right-click to close the shape)',...
           'HandleVisibility','off','State','off');

            c_hand.tb_zoom = uitoggletool(c_hand.htoolbar,'CData',imread('zoom.png'),'OnCallback',{@mymode, 'zoom'},'OffCallback',{@mymode, 'zoom'}, ...
           'TooltipString','Edit mode (left-click to zoom in, right-click to zoom out)',...
           'HandleVisibility','off','Separator','on');

           uipushtool(c_hand.htoolbar,'CData',imread('expand.png'),'ClickedCallback',{@mymode, 'expand'}, ...
           'TooltipString','Zoom image to fill the current window',...
           'HandleVisibility','off');
       
            c_hand.tb_poly = uitoggletool(c_hand.htoolbar,'CData',imread('poly.png'),'OnCallback',{@mymode, 'poly'},'OffCallback',{@mymode, 'poly'}, ...
           'TooltipString','Autodraw edit mode (left-click to set first point, then just drag around the shape right-click to close it)',...
           'HandleVisibility','off','State','On');
      
        else
          try      
            figure(c_hand.hfig);
          catch
            c_hand = c_hand_blank(c_hand.app);
            c_hand.hfig = figure();
          end
          end
        drawImage(1);

           %Error processing this file, just ignore it for now 
catch ME    
    rep = getReport(ME);
   waitmsgbox(rep(1:(min(1000,size(rep,2)))));
end
    
function mymode(h, evnt, new_mode)
if strcmp(evnt.EventName,'Off'),
    return;
end
global c c_hand;
switch new_mode
    case 'poly'
        h.State = 'on';
        c_hand.tb_zoom.State = 'off';
        c_hand.mode = new_mode;
        c_hand.tb_edit.State = 'off';
    case 'edit'
        h.State = 'on';
        c_hand.tb_poly.State = 'off';
        c_hand.tb_zoom.State = 'off';
        c_hand.mode = new_mode;
    case 'zoom'
        h.State = 'on';
        c_hand.mode = new_mode;
        c_hand.tb_poly.State = 'off';
        c_hand.tb_edit.State = 'off';
    case 'expand'
       zoom_to_fill();
end
        








