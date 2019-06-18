function  removeElement(index)
    global c;
% Input, imstruct and the index of the element to be removed
    % Output, imstruct with element removed and renumbered.
    % Create a copy with elements removed
    %delete the handles of the displayed one
    if c.polyData{2,index} ~= 0, delete(c.polyData{2,index});   end;
    if c.polyData{3,index} ~= 0, delete(c.polyData{3,index});   end;
    %Renumber all elements AFTER this one
    for i = index+1:size(c.polyData,2),
        if c.polyData{3,i} ~= 0, %if they are not visible, don't update them!
            c.polyData{3,i}.String=num2str(i-1);
        end
    end

    c.polyData(:,index) = [];
    c.Centroids(index) = [];
%    displayImstruct(imstruct,1); %do NOT redraw the others!
    c.dirty = 1;
    c.numbering_off = 1;
end