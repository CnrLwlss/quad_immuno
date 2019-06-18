function  analyseImstruct()
% inputs : c
% outputs : c with fields representing each cells mean intensity for
% each channel, and the mean intensity of cells per channel.

%This used to do ALL channels at once, but now I load the channels
%separately, so I load each one in turn. Note the currently loaded channel
%is just copied, rather than re-loaded.

global c c_settings c_hand c_im;
if ~isfield(c, 'polyData'),
    return;
end;

if ~isfield(c, 'channel'), %if there has been no auto analysis, channel won't be set
    c.channel = c_settings.channel;
end

numpols = size(c.polyData,2);

if numpols == 0,
    return;
end;

loaded_channel = c_settings.channel;

loaded_image = c_im.data;

%Make the array that will take the intensities for each channel;
means= zeros(numpols,c.n_chan,'double');

%The slow thing is preparing the poly. Fill out THAT channel at the same
%time. Then iterate the 
ind_array = cell(1, numpols);

h = waitbar(0,'Finding polygons and first channel...');

size_x = uint32(size(c_im.data, 2));
size_y = uint32(size(c_im.data, 1));

%using the full image, which makes a massive mask. Try to make it more
%efficient by just working in the region bounded by the polygon.


for i = 1:numpols,
     add_log(fixstr(['Mapping cell ' num2str(i) ]),0);
        %This used to use a poly as a mask, now I extract the indices. Should
        %be quicker......
        pd = c.polyData{1,i};
        %The points can be OFF the image, so trim them to fit.
         pd(:,2) = min(max(pd(:,2),1), double(size_y-1));
         pd(:,1) = min(max(pd(:,1),1), double(size_x-1));
        
        %Fix the polygons so we can see the changes
        c.polyData{1,i} = pd;   
        
        %Need to shift over a WHOLE number of pixels, if there are halves
        %then floor it
        x_shift = (floor(min(pd(:,1)))-1); %subtract 1, so that we end up always at least pixel 1
        y_shift = (floor(min(pd(:,2)))-1); %subtract 1, so that we end up always at least pixel 1
        pd(:,1) = pd(:,1) - x_shift;
        pd(:,2) = pd(:,2) - y_shift;

        x_max =  (ceil(max(pd(:,1))));   
        y_max =  (ceil(max(pd(:,2))));   
          ind = uint32(find(poly2mask(pd(:,1),pd(:,2),y_max,x_max)));
   
        %The indexing is down then along.  
        
        n_col_offset = floor((ind-1)/y_max); %Subtract 1, since the 10th pixel of a 10x10 is in row 1, which has offset of zero. 20th is in row 2, which is offset of 1.
        n_row_offset = mod(ind-1, y_max)+1; %10th pixel in 10x10 has offset of 10, so subtract 1 from the thing and add 1 at the end
        x = (x_shift + n_col_offset)*size_y;
        y = n_row_offset+y_shift;
        ind_array{i} = uint32(y+x);
end

%Go through the channels, load each one if it is not, and do each cell
for ch = 1:c.n_chan,
    %Start at 0.1 
    if ch ~= loaded_channel || ~strcmp(c_im.image_ext,'png'), %For analying, we MUST use the png
        c_settings.channel = ch;
        load_channel(0,1); %MUST be the PNG!
    else
        c_im.data = loaded_image;
    end
    chtext = fixstr([c_im.file_root ' channel ' num2str(ch) ]);
    
    h = waitbar(ch*0.2 ,h,chtext);
   % chtext = [chtext ' cell '];

           array = reshape(double(c_im.data),1,numel(c_im.data));
           for i = 1:numpols,
 %       h = waitbar(ch*0.2 + i*0.2/numpols,h,[chtext num2str(i)]);
 try     
 means(i, ch) = mean(array(ind_array{i}));
 catch me
 xxxxx=1;
 end
 
 end
end
%This is not the EXACT polygon area, but it is close enough, definitely.
%Also note, I square root it, so that it is a nominal RADIUS, nor area.
%Actually, I just export the area, not the radius.
means(:,c.n_chan +1) = cellfun(@(x) (size(x,1)), ind_array, 'UniformOutput',true)';
c.Intensities.AllChannels = means';
add_log('Done',1);
%close(h);

if numpols > 0,
    c.meanIntensities.AllChannels = mean(c.Intensities.AllChannels,2);
else
    c.meanIntensities.AllChannels = [0;0;0;0];
end

if c_settings.channel ~= loaded_channel,
   %Reset the loaded image
   c_im.data = loaded_image;
   c_settings.channel = loaded_channel;
end
