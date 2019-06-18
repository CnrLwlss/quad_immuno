function contour_display(i)
global c;
LL =         cell2mat(c.polyData(1,i));
h = plot(LL(:,1),LL(:,2),'-c'); %g does green
set(h,'ButtonDownFcn',{@myFunc});
%       h = plot(c.Centroids{i}(1),c.Centroids{i}(2),'sg','MarkerSize',10); %Don't plot
%       centroid, not much use
c.polyData{2,i} = h; %Save the handle
set(h,'ButtonDownFcn',{@myFunc});
%I used to do show cell numbers here, but it screwed up handles, so deal
%with cell numbers and contours totally separately now.
