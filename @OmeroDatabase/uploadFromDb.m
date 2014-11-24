function uploadFromDb(obj, source,loadInfo)
%Login to email to send any messages
    myaddress = 'swainlabomero@gmail.com';
    mypassword='alcatrasSaccharomyces';
    setpref('Internet','E_mail',myaddress);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',myaddress);
    setpref('Internet','SMTP_Password',mypassword);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
                      'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');


    %Uploads all data to the Omero database represented in obj from another
    %Omero database (defined in source)
    sourceDb=OmeroDatabase('Swain Lab',source);
    sourceDb.DataPath=source;
    sourceDb=sourceDb.login;
    datasets=getUnloadedDatasets(sourceDb.Session);
    %Load all datasets in the target databaset (need their details to check
    %if the datasets to be transferred are already there)
    obj=obj.login;
    disp('Loading target database datasets');
    datasetsTarget=getUnloadedDatasets(obj.Session);
    
    %Load all datasets in the source database (to get their ID numbers) -
    %without the images
    disp('Loading source datasets');
    if loadInfo %don't run through the datasets in both databases if you don't have to
    load('savedDbInformation');
    else
    
    %Create a cell array of strings having the original acq file paths of
    %all the datasets in the target database - this will be used to check
    %if the new dataset is already present
    acqFilePathsTarget=cell(length(datasetsTarget),1);
    for targetDs=1:length(datasetsTarget)
        try
            obj.DownloadPath='OmeroTemp/Target';
            dsIdTarget=datasetsTarget(targetDs).getId.getValue;
            filePathsTarget=obj.downloadFiles(dsIdTarget);
            if ~isempty(filePathsTarget)

                metaDataTarget=parseMetaData('OmeroTemp/Target');   

                acqFilePathsTarget{targetDs}=metaDataTarget.acqfilename;

                %Delete the files for the current dataset
                system('rm -rf OmeroTemp/Target/*');

            end
        catch
            disp('debug - getting acqFilePathsTarget');
            system('rm -rf OmeroTemp/Target/*');
        end      
    end
    %Also loop through the source datasets - get the id numbers so that
    %upload can be run in the same order each time this function is run.
    for ds=1:length(datasets)
        sourceDs(ds).name=char(datasets(ds).getName.getValue);
        sourceDs(ds).id=datasets(ds).getId.getValue
    end
    
    
    

    end

   
    
    
    %Loop through the source datasets uploading data if it's not in the
    %target databae
    system('rm -rf OmeroTemp/Source/*');

    for db=1:length(sourceDs)
        db
        %Catch errors due to loss of connection:
        overAllSuccess=false;
        while ~overAllSuccess
            try
                %Make sure you're logged in to the target database
                success=false;
                while ~success
                    try
                    obj=obj.login;
                    success=true;
                    catch
                        disp('Failed target database login - will retry in 1 min');
                        pause(60);
                    end
                end
                dsId=sourceDs(db).id;
                %Need to know if this dataset is present in the target database
                %Download file attachments to find out
                sourceDb.DownloadPath='OmeroTemp/Source';
                while ~success
                    try
                    sourceDb=sourceDb.login;
                    success=true;
                    catch
                        disp('Failed source database login - will retry in 1 min');
                        pause(60);
                    end
                end

                system('rm -rf OmeroTemp/Source/*');
        try
                filePaths=sourceDb.downloadFiles(dsId);
        catch
            disp('Logging in again to sourceDb');
            sourceDb.Client.closeSession;
            pause(2);
            sourceDb=sourceDb.login;
            filePaths=sourceDb.downloadFiles(dsId);
        end

                if isempty(filePaths)
                    disp(['Dataset has no file attachments' char(datasets(db).getName.getValue)]);
                        expSource.metaData=[];
                        expSource.dataset=getDatasets(sourceDb.Session,sourceDs(db).id);
                        expSource.database=sourceDb;
                        try
                            [obj errMessage mBSize]=uploadExperiment(obj,expSource);
                        catch err  
                            disp('error uploading dataset with no file attachments');
                            mailMessage=['Failure to upload dataset. Name: ' char(expSource.dataset.getName.getValue) ' Dataset Id: ' num2str(expSource.dataset.getId.getValue) err.message] ;
                            sendmail('ivan.clark@ed.ac.uk','OMERO upload from database - no file attachments',mailMessage);
                            overAllSuccess=true;
                            sourceDs(db).errors=true;
                            save('savedDbInformation','sourceDs','acqFilePathsTarget');
                        end
                else

                    metaData=parseMetaData('OmeroTemp/Source');
                end
                    if exist('metaData')==1
                    if ~any(strcmp(acqFilePathsTarget,metaData.acqfilename))
                        %the dataset is not in the target database - need to copy it.
                        disp('Copying data from source database');
                        expSource.metaData=metaData;
                        expSource.dataset=getDatasets(sourceDb.Session,sourceDs(db).id);
                        expSource.database=sourceDb;
                        %sourceDb.Client.closeSession;
                        try
                        disp(['Running upload experiment for ' char(datasets(db).getName.getValue)])   

                        [obj errMessage mBSize]=uploadExperiment(obj,expSource);
                        catch err
                        mailMessage=['Failure to upload dataset. Name: ' char(expSource.dataset.getName.getValue) ' Dataset Id: ' num2str(expSource.dataset.getId.getValue) err.message] ;
                        sendmail('ivan.clark@ed.ac.uk','OMERO upload from database',mailMessage);
                        overallSuccess=true;
                        sourceDs(db).errors=true;
                        save('savedDbInformation','sourceDs','acqFilePathsTarget');
                        end
                        %
                    else
                        disp(['Dataset: ' metaData.acqfilename ' is in the target databsase, not uploaded']);
                    end
                    end
                    %Delete the files for the current dataset - these will be replaced
                    %on the next loop iteration
                    system('rm -rf OmeroTemp/Source/*');
                    pause (5);
                    %Save the Omero Database object - so that the saved version has
                    %all the correct database info
                    obj2=obj;
                    %Next two lines avoid a not serializable warning on saving.
                    obj2.Session=[];
                    obj2.Client=[];
                    save(obj.SavePath,'obj2');
                    %also save table for GUI
                    obj.saveDbData;
                    overAllSuccess=true;
            catch err
                disp('Transfer has failed. Will repeat after re-establishing database connections');
                disp (err.message);
                pause(60);
            end
        end
    end
    end
        
    
    
    






