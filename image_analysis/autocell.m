function  autocell()
global c c_im c_settings c_hand;

%close an open figure handle, to clear up memory for large analyses
try
    if c_hand.hfig ~= 0, 
        close(c_hand.hfig); 
    end
catch ME
end

c_hand = c_hand_blank(c_hand.app);

% This is the main segmentation code
% inputs: a filename
% outputs: an imstruct with first pass segemntation.

% Params are hard coded here, and explained below, these could be specified
% as input arguments and linked to a GUI.

%If the current loaded image is NOT png, MUST load it now!
if ~strcmp(c_im.image_ext,'png')
    load_channel(0,1);
end

THRESHOLD_FACTOR = c_settings.threshold_factor;
AREA_MIN = c_settings.area_min;
AREA_MAX = c_settings.area_max;


% Documentation of the array properites from openmicroscope.org

%The data{s, 1} element is an m-by-2 cell array, where m is the number of  
%     planes in the s-th series. If t is the plane index between 1 and m:

%The data{s, 1}{t, 1} element contains the pixel data for the t-th 
%     plane in the s-th series.

%The data{s, 1}{t, 2} element contains the label for the t-th plane 
%     in the s-th series.

%The data{s, 2} element contains original metadata key/value pairs that 
%     apply to the s-th series.

%The data{s, 3} element contains color lookup tables for each plane 
%     in the s-th series.

%The data{s, 4} element contains a standardized OME metadata structure, 
%     which is the same regardless of the input file format, and contains 
%     common metadata values such as physical pixel sizes

h = waitbar(0,'Processing image...');

% Here we play with im2bw by binning the image based on a grey threhold
% level which is the mean of the image by some factor. -> this is one of
% the knobs that would be included in a gui application.
%it is default 1,3

h = waitbar(0.1,h,'Grayscaling...');

c.channel = c_settings.channel;

%Record the channel IN the c data, so we know which one we used to analyse
%it

%NOTE - I just had to scale the image based on the range of the data. I
%didn't used to have to do this.... have I changed the underlying data
%type???? I am not sure, but this certainly makes it work. I think I have
%made a booboo somewhere though. Anyway, works now, need to check with
%Mariana there are no other side effects.

data = c_im.data*(2^16/prctile(c_im.data(:),99));
bw = im2bw(data, graythresh(data)*THRESHOLD_FACTOR);

h = waitbar(0.2,h,'Standard deviations...');
imdata_dbl_std_std = std(std(double(data)));
% Here we compute images based on standard deviations
STDS = 1.66;
bwS = data > mean(mean(data))+STDS*(imdata_dbl_std_std );

% Here we compute the image minus the mean, this can be used instead of the
% thresholding in certain cases.
ImM = data - mean(mean(data));
bwS2 = ImM > STDS*(imdata_dbl_std_std );

h = waitbar(0.3,h,'Histogram equalisation...');

% Here we do histogram equalisation on the image.
HI = histeq(data);
bwH = HI > 0.8*mean(mean(HI));

% Here we clip the border so that cells that go off the image can be
% counted
BORDER = 15;
bw(:,1:BORDER) = 0;
bw(1:BORDER,:) = 0;
bw(end-BORDER:end,:) = 0;
bw(:,end-BORDER:end) = 0;

h = waitbar(0.4,h,'Image smudging...');

% He we smudge the image so that we can count easier, and get the blobs
% that are non continuous
G = bwmorph(bw,'dilate');


for i = 1:10
    h = waitbar(0.5+0.01*i,h,'Dilating...');
    G = bwmorph(G,'dilate');
end
for i = 1:10
    h = waitbar(0.6+0.01*i,h,'Skeletonising...');
    G = bwmorph(G,'skel');
end

% He we computre the complement of the image, the negative.
G = ~G;

% Snip the border again
BORDER = 15;
G(:,1:BORDER) = 0;
G(1:BORDER,:) = 0;
G(end-BORDER:end,:) = 0;
G(:,end-BORDER:end) = 0;

    h = waitbar(0.7,h,'Getting region props...');

% Do the counting, by computing the bounded boxes
V = regionprops(G);
% there are the bounded boxes
bbs = {V.BoundingBox};
% Create a figure window to show them
% These are the centroids
C = {V.Centroid};
% Quality Control.

% We need to get a judge of the error from the operator.  We also need to
% weed out false possitivies.

% Firstly, we want to weed out the counts with areas smaller than 100
% pixels, again this is another knob.  We also want to weed out the largest
% area, as this will be the artifical border we created.
 h = waitbar(0.7,h,'Calculating the areas...');

Areas = cell2mat({V.Area});
Inds = Areas > AREA_MIN & Areas ~= max(Areas) & Areas < AREA_MAX;
% calculate the final count and bounded box area.
Fa = Areas(Inds); Fc = length(Fa); Is = find(Inds);


h = waitbar(0.8,h,'Fitting convex hulls...');
% Now we go for a more complex approach, which is to fit convex hulls...
% like a boss!
V = regionprops(G,'ConvexHull');
cc = 1;
%pre-allocate the polydata with three rows, one for the poly data, one for
%poly handle, one for the text handle, one for the area of it. The last is
%an AUTO flag
c.polyData = cell(5,length(Is));
for i = 1:length(V)
    if any(i == Is)
    LL = V(i).ConvexHull;
    c.polyData{1,cc} = LL;
    c.polyData{2,cc} = 0; %CONTOUR
    c.polyData{3,cc} = 0;  %label
  %  plot(LL(:,1),LL(:,2),'-g');
    AreaPoly(cc) = polyarea(LL(:,1),LL(:,2));
    c.polyData{4,cc} = AreaPoly(cc);
c.polyData{5,cc} = 1;
    cc = cc+1;
    end
end

%clear up java heap here, just in case!
jheapcl();

h = waitbar(0.9,h,'Creating image...');

c.Centroids = C(Is);
c.dirty = 1; %Needs saved before closing
add_log('Done',1);

end