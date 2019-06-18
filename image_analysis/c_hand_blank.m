function c_hand = c_hand_blank(app)
%c_hand are the handles for figures and toolbars and suchlike
%we don't want them saved to the iaf file, so we store them in a separate
%global variable

c_hand.hfig = 0;
c_hand.hpanel = 0;
c_hand.app = app;
c_hand.log = findobj(app, 'Tag', 'log');
%retain any messages already in the log
c_hand.messages = c_hand.log.String';
c_hand.contrast = 0;