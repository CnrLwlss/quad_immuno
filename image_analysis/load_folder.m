function [files] = load_folder(folder, ext)
%loads a list of files from the folder
files = rdir([folder filesep '**' filesep '*.' ext]);
