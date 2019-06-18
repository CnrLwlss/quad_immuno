function filename = replace_ext(filename, new_ext)
        %swaps the existing file extension for a different one.
        [path, name, ext] = fileparts(filename);
        filename = fullfile(path, [name new_ext]);
end