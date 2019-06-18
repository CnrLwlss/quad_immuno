function [alldata] = merge_imaris_csvs(folder, files, outfile)
%Take a set of files and merge all the csvs into a single table
alldata = cell(0);

wb = waitbar(0,'Processing...');
inc = 1.0/size(files, 2);
progress = 0;

badfiles = {};
goodfiles = {};

for f = files
    full_path = f{1,1};
    [pathstr,name,ext] = fileparts(full_path); 
    rel_path = strrep(pathstr, [folder filesep], '')  ; 
    folders = regexp(rel_path,filesep,'split');   
    %Get the last folder excluding the _Statistics ending
    root_name = strrep(folders{1,end},'_Statistics','');
    %Read in the CSV file
    name = strrep(name, [root_name '_'], '');
    folders{1,end} = root_name;
    folders{1,end+1} = name;
    
    %Now load the csv file
    h_f = fopen(full_path);
    %skip first 4 lines
    for k=1:4
        tline = fgets(h_f);
    end
    if strfind(tline,'Channel'),
        findstr=    '%f %s %s %d %d %d %d';
        i_chan = 4;
        i_id = 6;
    else
        findstr=    '%f %s %s %d %d %d';
        i_chan = 0;
        i_id = 5;
    end
    %if tline has Channel in it, we have to record that.
    data = textscan(h_f, findstr,'delimiter',',');
    fclose(h_f);
    %Create an array with the relevant info
    data1 = horzcat(num2cell(data{1}), num2cell(data{i_id}));
    if i_chan ~= 0,
        data1 = horzcat(data1, num2cell(data{i_chan}));
    else
        data1(:,end+1) = {-1}; %No such channelm just means blank
    end
    
    for fol = folders,
        data1(1:end,end+1) = fol;
    end
    
    if size(alldata,1) == 0,
        %Set it up from the folder heirarchy
        alldata = {'Value','ID','Channel'};
        for i=1:size(folders,2),
            alldata{1,end+1} = sprintf('Folder %i',i);
        end
    end   
    try
        alldata = vertcat(alldata,data1);
        goodfiles{end + 1} = full_path;
    catch ME
        badfiles{end + 1} = full_path;
    end
    progress = progress + inc;
    waitbar(progress, wb,['Processing...']);
end
    waitbar(progress, wb,['Saving...']);
    cell2csv(outfile,alldata);
%    waitbar(progress, wb,['Creating zip file...']);
%    zip([outfile '.zip'], outfile);
add_log('Done',1);


    if size(badfiles,1) > 0,
        waitmsgbox('At least one of the files has caused an error (see the error message once you click OK....) This is USUALLY caused by a csv file that is NOT in the right format. This can happen if you have saved an output csv file in the root folder that you are importing, you must delete or move ANY csv files that are not in the imaris csv format.')
        listdlg('PromptString','The conversion is complete but with errors. These files failed to convert. Clicking OK or Cancel will close the box, but do nothing else. I just can''t make this list have only one button...','ListString',badfiles) 
    else
        waitmsgbox('Done! All files merged and saved without any errors. You can now upload it to the website for analysis.');
    end
    