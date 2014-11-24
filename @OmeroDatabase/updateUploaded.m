function updateUploaded(obj)

%Recreates the saved list of uploaded files
%Wrote this because the file became corrupted (19/11/14) so had to
%reconstitute - should keep a backup to avoid this (and of the two other
%database record files, dbInfo and dbTable
 
    %First log in if necessary
    if ~obj.SessionActive
       obj=obj.login; 
    end
    %Get the datasets
    disp('Getting datasets list...');
    datasets=getUnloadedDatasets(obj.Session);
    %Loop through the datasets list - downloading the files to recreate the
    %original folder
    
    uploaded=struct;
    acqFilePaths=cell(length(datasets),1);
    for ds=1:length(datasets)
        try
            obj.DownloadPath='OmeroTemp/Target';
            dsId=datasets(ds).getId.getValue;
            system('rm -rf OmeroTemp/Target/*');
            filePaths=obj.downloadFiles(dsId);
            if ~isempty(filePaths)
                logfile=dir(fullfile(obj.DownloadPath,'*log*'));
                logfile=[obj.DownloadPath filesep logfile.name];
                path=obj.getOriginalPath(logfile);
                %get the user
                k=strfind(path,'/');
                l=strfind(path,'RAW DATA');
                m=find(k<l);
                user=path(k(m(end-1))+1:k(m(end))-1);
                if ~isfield(uploaded,user)
                    numEntries=0;
                else
                    numEntries=length(uploaded.(user));
                end
                uploaded.(user){numEntries+1}=path;
                %Delete the files for the current dataset
                system('rm -rf OmeroTemp/Target/*');
            end
        catch
            disp('debug - getting acqFilePathsTarget');
            system('rm -rf OmeroTemp/Target/*');
        end      
    end
    save(obj.UploadedPath,'uploaded');
        