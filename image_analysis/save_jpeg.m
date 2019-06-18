function save_jpeg(data, d_min, d_max, channel)
%Saves a small uint8 version of the contrast adjusted image.
global c_hand c c_settings c_im image_file_path;
file = [image_file_path c_im.file_root '/ch' num2str(channel) '.jpg']; %I use png, it is lossless
%Trim off bottom and top 1% for the jpg
data(data<d_min) = d_min;
data(data>d_max) = d_max;
sf = 256.0/double(d_max - d_min);
%Reshape to a 256 range
imwrite(uint8((data- d_min)*sf), file, 'bitdepth',8); %A low res jpg version
