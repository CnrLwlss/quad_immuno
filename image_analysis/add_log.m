function h = add_log(message, newline)
global c_hand;
if ~isfield(c_hand, 'messages') || size(c_hand.messages,1)==0,
    c_hand.messages = cell(1,0);
    c_hand.messages{1} = message;
else
    if newline==0,
        c_hand.messages{1} = message; %Just replace the top line
    else
        c_hand.messages = [message c_hand.messages(1,1:min(size(c_hand.messages,2),25))]; %adds it to the TOP of the thing
    end
end

try
 c_hand.log.String = c_hand.messages;
h = 0;
drawnow;
	
   
end