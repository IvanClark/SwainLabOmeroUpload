function filePaths=downloadFiles(obj, dataset)
%Downloads the file annotations associated with the input dataset
%Note - the m file getDatasetFileAnnotations was modified slightly from the
%published version - to allow it to work if you're not logged in as the
%same user that uploaded the files.
%Input dataset can be either a dataset Id or a dataset object
if isnumeric (dataset)
    fileAnnotations=getDatasetFileAnnotations(obj.Session,dataset);
else
    fileAnnotations=getDatasetFileAnnotations(obj.Session,dataset.getId.getValue);
end
if ~isempty(fileAnnotations)
    
    



    for n=1:fileAnnotations.size(1)
         fileName=fileAnnotations(n).getFile.getName.getValue;
         fullPath=[obj.DownloadPath filesep char(fileName)];
         a=exist(obj.DownloadPath)==7;
         if ~a
            [s, mess, messid] = mkdir(obj.DownloadPath);
            if ~isempty(mess)
               %the path is invalid - save to a temporary folder in the current
               %directory
               mkdir('OmeroTemp');
            end
         end
         %The next line downloads the file contents and saves in the folder
         %fullPath
         getFileAnnotationContent(obj.Session, fileAnnotations(n), fullPath);
         description=char(fileAnnotations(n).getDescription.getValue);
         switch description
             case 'Swain lab experiment log file'
                 filePaths.log=fullPath;
             case 'Swain lab acquisition settings file'
                 filePaths.acq=fullPath;
             case 'Swain lab position file'
                 filePaths.pos=fullPath;
             otherwise
                 %Record the path of any other file that might be attached -
                 %but do not download
                 k=strfind(char(fileName),'.');
                 name=fileName(k(end)+1:end);
                 filePaths(length(filePaths)+1).others=fileName;
         end

    end
else
    %No file annotations have been found for this dataset - most likely the
    %ds has been deleted although it's still recorded in the dbInfo
    filePaths=[];
end
end