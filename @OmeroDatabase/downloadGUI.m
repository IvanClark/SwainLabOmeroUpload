
%Prepare the path


%Load the latest version of the OmeroDatabase object - this has all the
%recorded contents of the database - much more convenient than querying the
%database itself
SavePath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/dbInfo.mat';%Path to the saved object representing the current state of the database
load(SavePath);
%Parse the important info into cell arrays
downloadDialog=figure('Units','Normalized','Position',[.3327 .4932 .2 .3],'MenuBar','None', 'NumberTitle', 'Off', 'Name', 'Omero database download','Callback');
%set(downloadDialog('WindowStyle','Modal'); %Uncomment this when finished
%writing this function
projNames=obj2.getProjectNames;
