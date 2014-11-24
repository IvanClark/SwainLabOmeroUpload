function uploadAll (server,source)
    %Uploads any new data from all Swain lab users to the Omero database. This
    %is a static method - creates it's own OmeroDatabase objects for each user.
    %Inputs:
    %
    %server = string,full address of the Omero server
    %source = string, full path to folder containing the images (future -
    %or full address of Omero server from which data should be copied)
    [swain tyers millar]=OmeroDatabase.getUsers;
    %Load the record of files already uploaded
    load('/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/uploadedSkye.mat');
    %(The original, empty, uploaded file was created using this code:
    %for n=1:length(swain)
    %    uploaded.(swain{n})=cell('');
    %end
    OmeroDatabase.preparePath;

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
    sendmail('ivan.clark@ed.ac.uk','OMERO upload','Omero code. uploadAll is running');
    
    
    %Create a date tag - to be shared by all datasets created today.
    dateTag=omero.model.TagAnnotationI;
    dateTag.setTextValue(omero.rtypes.rstring(date));
    user='upload';
    obj=OmeroDatabase(user,server);
    obj.DataPath=source;
    
    obj=obj.login;
    obj.DateTag=dateTag;
    %loop through each user, uploading their new images
    for u=1:length(swain)
        disp(swain{u})
        obj.User=swain{u};
        [obj anyErrors]=obj.upload;
        %Send email listing the uploaded experiments
        
        %First read the contents of the upload record file
        uploadRecordFile=fopen('tempuploadrecord.txt','r');
        s = textscan(uploadRecordFile,'%s','Delimiter','\n');
        s=s{:};
        uploadRecord='';
        for n=1:length(s)
            uploadRecord=[uploadRecord s{n} 10];
        end
        
        if ~isempty(uploadRecord)
            if anyErrors
                %sendmail(obj.getUserEmail,'OMERO upload - with an error',uploadRecord);
                sendmail('ivan.clark@ed.ac.uk','OMERO upload - with an error',uploadRecord);
            else
                %sendmail(obj.getUserEmail,'OMERO upload',uploadRecord);
                sendmail('ivan.clark@ed.ac.uk','OMERO upload',uploadRecord);
            end

        end        
    end
    %Update the saved dataset table
    obj.saveDbData;
    %Close the session
    obj.Client.closeSession;
end
    
    
   
