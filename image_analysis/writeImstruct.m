function  writeImstruct()
 global c c_im image_file_path;
    % input: c
    %output: file with mean intensities per channel, file with c.
    %Both are saved in the same dir as the czi file.
     filename_stub = c_im.file_root;
    filename = [image_file_path filename_stub '.csv'];

    F = datestr(now);
    F(F == ':') = '_';
    try
    fid=fopen(filename,'wt');
     
    %This makes a column for each channel, plus one for the cell radius(-1 channel).
    fprintf(fid,[strjoin(strcat('Ch',cellstr(num2str((1:c.n_chan)'))'),',') ',Area,\n']);
    fclose(fid);
    catch
        waitmsgbox(['Failed to save the file ' filename '. Probably the file is being edited or the file path is invalid.']);
    end
        
    if isfield(c, 'Intensities'),
        S = c.Intensities.AllChannels';
        dlmwrite (filename, S, '-append');

    end
end