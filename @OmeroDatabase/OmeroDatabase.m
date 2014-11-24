classdef OmeroDatabase
    %Class of objects holding information about the contents of the Omero
    %database. Used to coordinate such information between uploading
    %scripts, manual entry to the database and microscope acquisition
    %software
properties
    SavePath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/dbInfo.mat';%Path to the saved object representing the current state of the database
    DataPath='/Volumes/AcquisitionData2/Swain Lab/';
    SaveTablePath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/dbTable.mat';%Path to the saved file containing dataset info
    UploadedPath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/uploaded.mat';
    Datasets
    Tags%Structure with 3 fields, name (tag string), id, description (in that order). The tag description is only recorded here if it has been created in the microscopy acquisition software - this data is not downloaded by the updateDbInfo function
    DateTags%boolean vector. Indicates which of the entries in the Tags property represents a date
    Projects%Structure with 3 fields: name, id, description (in that order). The project description is only recorded here if it's been created in the microscope acquisition software - this data is not downloaded by the updateDbInfo function.
    User%Common name of user (eg 'Ivan')
    Uname%Omero database username of user (eg 'v1iclar2')
    pwd
    Server='omero.bio.ed.ac.uk';
    Port=4064;
    Session
    SessionActive
    Client
    UserId%Id number of user in Omero database
    GroupId%Group Id number in Omero database
    DateTag%tag object for the date of the experiment currently being uploaded
    %The following properties are required for downloading
    DownloadPath%Full path to folder in which to save data
    FilePaths%structure - records the paths to any downloaded file attachments
    DataTable%Cell array - records the dataset ids, names, projects and tags in the database
    
    
    
end

methods
    function obj=OmeroDatabase(user,server, session)
        %Constructor - loads saved version of the object or creates empty
        %object. Then updates to current version of the database by calling
        %the updateDbInfo method
        
        %First ensure all necessary scripts are are on the Matlab path
        obj.preparePath;
        
        %Determine from the 'server' input, which Omero database is
        %required - set other values accordingly - default values are
        %correct for the ECDF server
        if nargin==1
            server='omero.bio.ed.ac.uk';%default server on ECDF
        end
        obj.Server=server;        
        
        switch server
            case 'skye.bio.ed.ac.uk'
                obj.SavePath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/dbInfoSkye.mat';%Path to the saved object representing the current state of the database
                obj.UploadedPath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/uploadedSkye.mat';
                obj.SaveTablePath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/dbTableSkye.mat';

                obj.Port=40640;
            case 'omero.bio.ed.ac.uk'
                %ECDF server
                SavePath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/dbInfo.mat';%Path to the saved object representing the current state of the database
                UploadedPath='/Volumes/AcquisitionData2/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/uploaded.mat';
                obj.Port=4064;
        end
       
        if exist (obj.SavePath)==2
            try
            load(obj.SavePath);
            %This has loaded an object called obj2.
            %Copy relevant information to the new object.
            %(We load obj2, rather than obj so that new methods written for
            %this class are available to obj).
            obj.Datasets=obj2.Datasets;
            obj.Tags=obj2.Tags;
            obj.Projects=obj2.Projects;
            obj.DateTag=obj2.DateTags;
            catch
                disp('OmeroDatabase constructor - error loading saved object');
            end
        else
            obj.Datasets=[];
            obj.Tags=[];
            obj.Projects=[];
        end
        if nargin>0
            obj.User=user;
        else
            obj.User='Ivan';
        end

        if nargin>2
            obj.Session=session;
            obj.SessionActive=true;
        else
            obj.SessionActive=false;
        end        
        
        %obj=obj.updateDbInfo;
        obj2=obj;
        save(obj.SavePath,'obj2');
    end
end
methods (Static)
	isData=checkForDate(tagString);
    uploadAll(server,source);
    [swain tyers millar]=getUsers;
    preparePath;
    uploadFromDb(user,source,load);
    path=getOriginalPath(logfile);
end
end