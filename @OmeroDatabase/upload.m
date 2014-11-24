function [obj anyErrors]=upload(obj)
    uploadRecord='';
    anyErrors=false;
    %Create temporary file for the upload record
    uploadRecordFile=fopen('tempuploadrecord.txt','wt');
    fprintf(uploadRecordFile,['Swain lab Omero upload: ' date 10]);
    fclose (uploadRecordFile);
    %Uploads any new data from the current user to the Omero database
    if ~strcmp(obj.DataPath(end), filesep)
       obj.DataPath(end+1)=filesep; 
    end
    yearFolders=dir(fullfile([obj.DataPath obj.User '/RAW DATA/']));
    %Reference for months as folder names
    monthCell={'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
    %Get the information on experiments already uploaded
    load(obj.UploadedPath);
    cumSize=0;
    
    %Loop through the images
        for y=1:length(yearFolders)
            if ~isempty(yearFolders(y).name) && ~strcmp(yearFolders(y).name,'.') && ~strcmp(yearFolders(y).name,'..') && ~strcmp(yearFolders(y).name,'.DS_Store') && length(yearFolders(y).name)==4

                monthFolders=dir(fullfile([obj.DataPath obj.User '/RAW DATA/' yearFolders(y).name]));
                for m=1:length(monthFolders)
                    if any(strcmp(monthCell,monthFolders(m).name))
                        dayFolders=dir(fullfile([obj.DataPath obj.User '/RAW DATA/' yearFolders(y).name '/' monthFolders(m).name]));
                        for d=1:length(dayFolders)
                           k=strfind(dayFolders(d).name,'-');
                           if length(k)==2
                               expFolders=dir(fullfile([obj.DataPath obj.User '/RAW DATA/' yearFolders(y).name '/' monthFolders(m).name '/' dayFolders(d).name]));
                               for experiment=1:length(expFolders)
                                   expFolderName=expFolders(experiment).name;
                                   if ~strcmp(expFolderName,'..') && ~strcmp(expFolderName,'.') && ~strcmp(expFolderName,'.DS_Store');
                                       %This is a valid experimental folder name
                                       %Create the full path string and a name to be recorded as having been uploaded.
                                       expFolderName=[obj.DataPath obj.User '/RAW DATA/' yearFolders(y).name '/' monthFolders(m).name '/' dayFolders(d).name '/' expFolderName]
                                       %Check if the folder (or subfolders) contain any images files
                                       imageFolder=obj.anyImages(expFolderName);
                                       if imageFolder
                                       nameForRecord=[expFolderName '/' dayFolders(d).name];%Ivan debugging note - I'm not sure why the day folder name is added here - can't change it now or a lot of data will be uploaded twice.
                                       %Don't upload experiments with an'in progress' file - unless they
                                       %are more than 4 days old (expt should be finished by then).
                                       dt=date;
                                       mth=dt(4:end);
                                       isNew=strcmp(mth, dayFolders(d).name(4:end));%will be 1 if we are still in the month in which the experiment was recorded
                                       %Define exeriment as old if
                                       %experiment was > 4 days ago
                                       if isNew
                                           day=str2num(dt(1:2));
                                           expDay=str2num(dayFolders(d).name(1:2));
                                           if day-expDay>4
                                               isNew=false;
                                           end
                                       else
                                       %Define experiment as new if it was
                                       %recorded in the previous month and
                                       %this month is <=4 days old
                                           day=str2num(dt(1:2));
                                           if day<5
                                               thisMonth=dt(4:6);%month when this is running
                                               thisYear=dt(8:end);
                                               exptMonth=dayFolders(d).name(4:6);%Month when expt was recorded
                                               exptMonthNum=find(strcmp(exptMonth,monthCell));
                                               exptYear=dayFolders(d).name(8:end); 
                                               if exptMonthNum==12
                                                   nextMonth='Jan';
                                                   %Need to change one of the years to satisfy
                                                   %the and statement below
                                                   thisYearNum=str2double(thisYear)-1;
                                                   thisYear=num2str(thisYearNum);
                                               else
                                                   nextMonth=monthCell{exptMonthNum+1};
                                               end
                                               if strcmp(nextMonth,thisMonth) && strcmp(exptYear,thisYear)
                                                   %This is being run in the month after expt was recorded - don't upload
                                                   isNew=false;
                                               end
                                           end
                                       end
                                       
                                       
                                       
                                       
                                       
                                           if ~(exist([expFolderName '/temp_InProgress.txt'])==2) || ~isNew                           
                                               %Has this experiment been uploaded
                                               %already?
                                               try
                                                   if isfield (uploaded,obj.User)
                                                       if ~isempty(uploaded.(obj.User));
                                                           if ~any(strcmp(nameForRecord, uploaded.(obj.User)))                                  
                                                                [obj errMessage mBsize]=obj.uploadExperiment(expFolderName);
                                                                cumSize=cumSize+mBsize
                                                                uploaded.(obj.User){end+1}=nameForRecord;
                                                                %Record in the temp upload record file
                                                                uploadRecordFile=fopen('tempuploadrecord.txt','a+');
                                                                if isempty(errMessage)
                                                                    errMessage='No upload errors';
                                                                end                                           
                                                                fprintf(uploadRecordFile,[10 'Upload of ' expFolderName 10 errMessage]);
                                                                fclose(uploadRecordFile);                                                               
                                                           end
                                                       else
                                                           [obj errMessage mBSize]=obj.uploadExperiment(expFolderName);
                                                           cumSize=cumSize+mBSize
                                                           uploaded.(obj.User){end+1}=nameForRecord;
                                                           %Record in the temp upload record file
                                                           uploadRecordFile=fopen('tempuploadrecord.txt','a+');
                                                           if isempty(errMessage)
                                                               errMessage='No upload errors';
                                                           end                                           
                                                           fprintf(uploadRecordFile,[10 'Upload of ' expFolderName 10 errMessage]);
                                                           fclose(uploadRecordFile);  
                                                       end
                                                   else
                                                       [obj errMessage mBSize]=obj.uploadExperiment(expFolderName);
                                                       cumSize=cumSize+mBSize
                                                       %Record in the temp upload record file
                                                       uploadRecordFile=fopen('tempuploadrecord.txt','a+');
                                                       if isempty(errMessage)
                                                           errMessage='No upload errors';
                                                       end                                           
                                                       fprintf(uploadRecordFile,[10 'Upload of ' expFolderName 10 errMessage]);
                                                       fclose(uploadRecordFile); 
                                                       uploaded.(obj.User)={};
                                                       uploaded.(obj.User){end+1}=nameForRecord;
                                                   end
                                               save(obj.UploadedPath,'uploaded');

                                               catch err
                                                   %Email successful uploads
                                                   sendmail('ivan.clark@ed.ac.uk','OMERO upload record',uploadRecord);
                                                   
                                                   %Record error - send email to Ivan and add to the record sent to the user
                                                   disp(['Folder ' expFolderName ' in ' obj.User '/RAW DATA/' yearFolders(y).name '/' monthFolders(m).name '/' dayFolders(d).name '/  not uploaded due to error.']);
                                                   if ~anyErrors%Only add the first error to the message
                                                       mailErrorMessage=['Omero upload error: Experiment' expFolderName 10 err.message];
                                                       for stck=1:length(err.stack)
                                                            mailErrorMessage=[mailErrorMessage 10 'File: ' err.stack(stck).file 10 'Line: ' num2str(err.stack(stck).line) 10];
                                                       end
                                                       uploadRecord=[uploadRecord 10 mailErrorMessage];
                                                   end                                                   
                                                   anyErrors=true;
                                                   
                                                   %The error may have been caused by a loss of the connection - login might fix it for the next dataset
                                                   user=obj.User;
                                                   obj.User='upload';
                                                   obj=obj.login;
                                                   obj.User=user;
                                                   
                                                   %Delete the failed dataset that you have just created                                                                                                      
                                                   try
                                                       load('/Volumes/AcquisitionData2/Swain Lab/OmeroCode/currentDataset.mat');
                                                       deleteDatasets(obj.Session,id);
                                                       disp(['Dataset: ' id ' deleted due to upload error']);
                                                       mailErrorMessage=[mailErrorMessage 'Dataset: ' num2str(id) ' deleted due to upload error'];
                                                   catch
                                                       
                                                       mailErrorMessage=[mailErrorMessage 'Dataset: ' num2str(id) ' failed to delete.' err.message];
                                                   end
                                                   %Send email with the
                                                   %error message - this
                                                   %will generate a lot of
                                                   %spam - get rid of it
                                                   %when things are up and
                                                   %running well
                                                   sendmail('ivan.clark@ed.ac.uk','OMERO upload error',mailErrorMessage);

                                               end
                                           end
                                       end
                                   end
                               end
                           end                       
                        end
                    end            
                end
            end       
        end





end