function anyImage = findImages(obj,dirName)
%This was adapted from:
%http://stackoverflow.com/questions/2652630/how-to-get-all-files-under-a-specific-directory-in-matlab

anyImage=false;

dirData = dir(dirName);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  
if any(~cellfun(@isempty, strfind(fileList,'.png')))
    anyImage=true;
    return;
end
  

subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                           %#   that are not '.' or '..'
for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];%# Recursively call getAllFiles
    if any(~cellfun(@isempty, strfind(fileList,'.png'))) || 
        anyImage=true;
    return;
    end
end

end