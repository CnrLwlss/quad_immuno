function zoom_to_fill()
global c_hand c;
 api = iptgetapi(c_hand.hpanel);
        c.mag = api.findFitMag();
        api.setMagnification(c.mag);