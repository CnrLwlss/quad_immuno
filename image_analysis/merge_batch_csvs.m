function merge_batch_csvs(file_roots, outfile)
global image_file_path;
count = size(file_roots,2);
alldata = {};

goodfiles = {};
badfiles = {};

h_output = fopen(outfile,'wt');

fprintf(h_output, '%s', 'Value,ID,Channel'); %the top of the csv file.


counter = 0;

for ff= file_roots,
    file_root = ff{:};
    
    counter = counter + 1;
    add_log(fixstr(['Merging ' file_root]),0);
    
    full_path = [image_file_path file_root '.csv'];
    rel_path = [file_root '.csv'];

    folders = regexp(rel_path,filesep,'split');    %I used to use strsplit, but the arguments reverse in the compliler, how WEIRD!!!!
    folders_s = sprintf('%s\n',[',' strjoin(folders,',')]);
    folders_s = strrep(folders_s,'.csv','');
    [path name ext] = fileparts(rel_path);
    
    folders{1,end} = name;
    
    if counter ==1,
        for i=1:size(folders,2)-1,
            fprintf(h_output, ',Folder %i',i);
        end
        fprintf(h_output, '%s',',Filename',i);
        fprintf(h_output,'\n');
    end
            
    if exist(full_path),
%        add_log(full_path,1);
        %Now load the csv file
        h_f = fopen(full_path);

        %This is the top line
        tline = fgets(h_f);
        channels= regexp(tline,',','split');    %I used to use strsplit, but the arguments reverse in the compliler, how WEIRD!!!!
%        channels = strsplit(tline, ',');
        %There is a DUD blank channel for now, I don't know why it is happening, well, I kind of do, I put a , on the end of the csv title row
        %So I have to trim that off before merging the csvs.
        %If I leave off the comma at the end the last one (Area) ends up
        %having a newline put into each value, which is rubbish.
        %Anyway, this works, but it is a fiddle!
        channels = channels(1,1:end-1);
        findstr=    repmat('%d ',1,size(channels,2));
        %if tline has Channel in it, we have to record that.
        data = textscan(h_f, findstr,'delimiter',',');
 %       min_channels = min(size(data,2),min_channels);
        %remove any channels above the min channel
%        channels(channels > min_channels) = [];
        

        %Comes as a cell array of columns
        fclose(h_f);
        
        nrow = size(data{1},1);
        
        
        ch = 0;
        for chan = channels, 
            ch = ch + 1;
            folder_and_chan = [',' chan{:} folders_s];
            yy = [num2str(data{:,ch}) repmat(',',nrow,1) num2str((1:nrow)') repmat(folder_and_chan ,nrow,1)]';
            fprintf(h_output,'%s',yy);
        end
    end
end
add_log('Saving the merged csv file...',1);

fclose(h_output);

add_log('Done',1);

    if size(badfiles,1) > 0,
       listdlg('PromptString','The conversion is complete but with errors. These files failed to convert. Clicking OK or Cancel will close the box, but do nothing else. I just can''t make this list have only one button...','ListString',badfiles) 
    else
        waitmsgbox('Done! All files merged and saved without any errors. You can now upload it to the website for analysis.');
    end
    
    
