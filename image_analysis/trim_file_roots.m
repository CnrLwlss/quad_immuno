function trimmed = trim_file_roots(list)
    trimmed = {};
    for f = list',
       [~, filename, ~] = fileparts(f{:});
       trimmed{length(trimmed)+1,1} = filename;
    end
end