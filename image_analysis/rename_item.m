function new_name = rename_item(filename_root)
global image_file_path ;

    %We need to stitch the relative path onto the path here!
    [rel_path name ext] = fileparts(filename_root);
    full_path = fullfile(image_file_path, rel_path);
    file_root = name;


new_name = inputdlg('Change name to (don''t include any part of the folder path! Just the last section of the name will be renamed) ',['Rename ' file_root],1,{file_root});
if ~isempty(new_name),
    new_name = new_name{:};
    
    count = 0;
    [thisone count] = domove(full_path, file_root, ext, new_name, count);
    if thisone < 0,
       new_name = '';
       return;
    end

        [thisone count] = domove(full_path, file_root, '.iaf', new_name, count);
    if thisone < 0,
       new_name = '';
       return;
    end

    [thisone count] = domove(full_path, file_root, '.csv', new_name, count);
    if thisone < 0,
       new_name = '';
       return;
    end
    
    [thisone count] = domove(full_path, file_root, '', new_name, count);
    if thisone < 0,
       new_name = '';
       return;
    end

    if ~strcmp(new_name, ''),
        [rel_path name ext] = fileparts(filename_root);
        if ~isempty(rel_path), %Check if blank, otherwise we always put a \ prefix on a rename in the same folder.
            new_name = [rel_path filesep new_name];
        end
        
    end
    
end


function [res count] = domove(path, old_root, ext, new_root, count)
    res = 0;
    
  %  [rel_path name ext] = fileparts(old_root);
    
    old_file = [path old_root ext];
    new_file = [new_root ext]; %as we are RENAMING not moving, we don't use the path here. We can only rename within the same folder
    if ~exist(old_file, 'file'),
        return; %Nothing to move
    end
    
    msg = ['Moving ' old_root ' to ' new_root];
    add_log(msg,1);
    
    if exist(new_file, 'file'),
        msg = ['ERROR: ' new_file ' already exists so the rename cannot be done.'];
        add_log(msg,1);
        waitmsgbox(msg);

        if count > 0,
            msg = 'ERROR: Some files have been renamed but some have FAILED. You had better check the files in the folders and manually rename those that failed, or switch everything back. Just make sure it is consistent :-)';
            add_log(msg,1);
            waitmsgbox(msg);
       end
        res = -1;
        return;
    end
    
    try
        %movefile is SO SLOW! Changed to rename.
        s = dos(['rename "' old_file '" "' new_file '"']);
%    [s,mess,messid] = movefile(old_file, new_file);
    res = 1;
    catch ME
        s = -1;
        res = 0;
        add_log(getReport(ME),1);
        waitmsgbox(getReport(ME));
    end
    if s ~= 0,
        msg = ['ERROR: ' new_file ' could not be renamed, unknown error.'];
        add_log(msg,1);
        waitmsgbox(msg);

        if count > 0,
            msg = 'ERROR: Some files have been renamed but some have FAILED. You had better check the files in the folders and manually rename those that failed, or switch everything back. Just make sure it is consistent :-)';
            add_log(msg,1);
            waitmsgbox(msg);
       end
        res = -1;
        return;
    end
    count = count + 1;
