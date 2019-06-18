function [alldata] = merge_imaris_xlss(folder, files, outfile)
    %Take a set of files and merge all the csvs into a single table
    alldata = cell(0);

    wb = waitbar(0,'Processing...');
    inc = 1.0/size(files, 2);
    progress = 0;

    badfiles = {};
    goodfiles = {};

    Excel = actxserver ('Excel.Application'); 



    for f = files
        full_path = f{1,1};
        [pathstr,name,ext] = fileparts(full_path); 
        rel_path = strrep(pathstr, [folder filesep], '')  ; 
        folders = [name regexp(rel_path,filesep,'split')];    
        %Get the last folder excluding the _Statistics ending
        root_name = strrep(folders{1,end},'_Statistics','');

        name = strrep(name, [root_name '_'], '');
        folders{1,end} = root_name;
        folders{1,end+1} = name;

        data1 = get_excel_sheet_data(Excel, full_path);

        for fol = folders,
            data1(1:end,end+1) = fol;
        end

        if size(alldata,1) == 0,
            %Set it up from the folder heirarchy
            alldata = {'Value','Channel','ID','Filename'};
            for i=1:size(folders,2)-1, %The first one is the filename
                alldata{1,end+1} = sprintf('Folder%i',i);
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
        close(wb);

    invoke(Excel, 'Quit');
    % End process
    delete(Excel);

        if size(badfiles,1) > 0,
           listdlg('PromptString','The conversion is complete but with errors. These files failed to convert. Clicking OK or Cancel will close the box, but do nothing else. I just can''t make this list have only one button...','ListString',badfiles) 
        else
            waitmsgbox('Done! All files merged and saved without any errors. You can now upload it to the website for analysis.');
        end
