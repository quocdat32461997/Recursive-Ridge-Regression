%import_vhdr - the script to import raw data and pre-process
%Usage:
%      >> import_vhdr(); %raw files ending with .vhdr converted into
                         %EEG structures
%Inputs:    none
%Outputs: 
%   EEG     - EEGLAB EEG structure
%   com     - history string
%Notes:
%   Import 'Brain Vision Data Exchange' format files with this script.
%   EEG data is stored at eeg
%   May need to change data path based on your system
%   Author: Dat Quoc Ngo, 2019

data_path = 'D:\Research\additional data\SMNV_Dat_export\';

%extract list of files
fileList = dir(strcat(data_path,'*.vhdr')); 
fileList = struct2table(fileList);
file = fileList.name; %name of files in file

%extract data
for f = 1:size(file, 1)
    fileName = char(file(f));
    
    %open files
    disp(fileName);
    [eeg, com] = pop_loadbv(data_path, fileName);
    fileName = fileName(1:(size(fileName,2)-5));
    fileName = strcat("pre_processed_data\", fileName, ".mat");
    save(fileName, "eeg", "com"); 
end

