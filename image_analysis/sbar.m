function sbar(src,callbackdata)
global c_hand c_settings;
  % u = findobj(gcbo,'Tag','StatusBar');
   fig = src;
if         ~isequal(c_settings.position,fig.Position), %don't update if the fig is already there

   if isfield(c_hand, 'hpanel') && c_hand.hpanel ~= 0,

        %2016.03.23 just changed this to stop it deleting...
       %    delete(c_hand.hpanel);
%    c_hand.hpanel = 0;
%       drawImage(0);
        zoom_to_fill();
        c_settings.position = fig.Position;
    end
end
%zoom to fill it!
end