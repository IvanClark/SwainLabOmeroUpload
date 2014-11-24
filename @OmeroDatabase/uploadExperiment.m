function [obj errMessage mBSize]=uploadExperiment(obj,expSource)
    %Uploads files from expSource to the Omero database represented by obj.
    %expSource can be either the full path of a folder of images saved by
    %the Swain lab microscope software or a structure with fields:
    % .database - OmeroDatabase object representing the database having the
    %             source images
    % .dataset - Omero dataset object - the dataset to be transferred
    % .metaData - metadata structure for the dataset - created by
    %             parseMetaData


    
    
    mBSize=0;
    errMessage='';

    %Get the meta data for this experiment from the microscope log and acquisition files.
    if ischar(expSource)
        metaData=parseMetaData(expSource);
    else
        metaData=expSource.metaData;
        if isempty(metaData)
           %Metadata field is empty - most likely there were not files attached to the dataset 
           %in the source database
           metaData.expname=char(expSource.dataset.getName.getValue);
           metaData.name=metaData.expname;
           metaData.description='';
           metaData.foldername='/Users/ecoli/Documents/Ivan_OmeroCode etc/OmeroCode/OmeroTemp/downloadedDataset/';
           %get tags to find the date
           tas = getObjectAnnotations(expSource.database.Session, 'tag', 'dataset', expSource.dataset.getId.getValue);
           %Define metaData.date here
           metaData.date='date unknown - no tag or log file in source database';
           for t=1:length(tas)
               isDate=obj.checkForDate(char(tas(t).getTextValue.getValue));
               if isDate
                   metaData.date=char(tas(t).getTextValue.getValue);
               end
           end
        end
        %Channel names
        
        metaData.description=[metaData.description ' Uploaded from omero.bio.ed.ac.uk'];
    end
    
    
    %Need to download the dataset if it is coming from an Omero database
    if ~ischar(expSource)
            downloadPath='OmeroTemp/downloadedDataset/';
            %Make sure the download folder is empty
            system('rm -rf OmeroTemp/downloadedDataset/*');
            metaData.name=metaData.expname;
            [expSource.database metaData anyData]=expSource.database.downloadDataset(expSource.dataset.getId.getValue, downloadPath, true,metaData);
            rootFolder=downloadPath; 

            if anyData
            disp(['Dataset: ' char(expSource.dataset.getName.getValue) ' downloaded']);
            else
                disp(['Dataset:' char(expSource.dataset.getName.getValue) ' No data was downloaded']);
            end
    else
        anyData=true;
        rootFolder=expSource;
    end
    
    %Close function if no data has been downloaded
    if ~anyData
            return
    end
    

    %Find or create the project for this experiment

    if isfield(metaData,'project')
        projName=metaData.project;
    else
        projName='Default project';
    end

    %Get the project ID for the project with the recorded name. If there is
    %no project with that name then create one.
    [prjId projDescription ind]=obj.getProjectInfo(projName);
    %Record whether a project was found or not. If a project was found then
    %the id may still be zero if this project name has been recorded by the
    %microscope software but the project has not yet been uploaded
    if ind>0
        inDbInfo=true;
        %There is a project recorded in the dbInfo file with an Id greater
        %than zero. It should therefore exist in the actual database.
        %Confirm that this is the case to avoid an error.
        project=getProject(obj.Session, (prjId));
        if isempty (project)
           %There is no project in the database with this id. Reset the id to zero - then the project will
           %be created
           prjId=0;
        end
        
    else
        prjId=0;
        inDbInfo=false;
    end

    if prjId==0
        disp(['Creating new project...' projName]);
        %Need to create a new project with the name from the log file
        project=omero.model.ProjectI;
        project.setName(omero.rtypes.rstring(projName));
        if inDbInfo
            if ~isempty(projDescription)
                project.setDescription(omero.rtypes.rstring(projDescription));
            end            
        end
        obj.Session.getUpdateService().saveAndReturnObject(project);
        %Need to run getProjects to get an object with an Id that can be
        %used.
        try
        projects=getUnloadedProjects(obj.Session);
        catch
            disp('debug getprojects');
        end
        ids=zeros(length(projects),1);
        for n=1:length(projects)
            p=projects(n);
            ids(n)=p.getId().getValue();
        end
        [prjId pIndex]=max(ids);
        project=projects(pIndex);
        %If the project was referred to in obj.Projects - need to record the Id
        %number to indicate this project has been created.
        if inDbInfo
            %This project was created from the microscope software
            obj.Projects(ind).id=prjId;%This value was previously zero - this line ensures this project will not be recreated
        else
            %This project name was typed into the log file
            obj.Projects(end+1).name=projName;
            obj.Projects(end).id=prjId;
        end
    end


    %create a new dataset for this experiment and link it to the project.
    %The dataset description will be the text in the experiment
    %description entered in the microscope software.
    
    %A quick check to make sure the experiment name is correct in the
    %metaData
    if ~isfield(metaData,'expname')
        k=strfind(metaData.logfilename,filesep);
        metaData.expname=metaData.logfilename(k(end)+1:end-7);
    end
    
    disp('Creating dataset...');
    dataset=createDataset(obj.Session,metaData.expname,project);       
    dataset.setDescription(omero.rtypes.rstring(metaData.description));
    %Record the dataset id number - will allow it to be deleted if
    %necessary
    id=dataset.getId.getValue;
    save('/Volumes/AcquisitionData2/Swain Lab/OmeroCode/currentDataset.mat','id');
    
%     
%     %Project now created - will link to dataset
%     %Link the dataset to the project
%     link = omero.model.ProjectDatasetLinkI;
%     link.setChild(dataset);
%     link.setParent(omero.model.ProjectI(prjId, false));
%     obj.Session.getUpdateService().saveAndReturnObject(link);

    %For some reason the dataset ID can't be obtained directly from the
    %newly-created datset (variable 'dataset'). To get round this -  get all 
    %dataset links to the current project and find the new one - one with the
    %highest ID. Need the database ID to link images to the database.



    %Get or create the appropriate project
    project=getProject(obj.Session, (prjId));
    dsLinks=project.copyDatasetLinks;
    dsIds=zeros(length(dsLinks));
    for n=0:dsLinks.size-1
       linkN=dsLinks.get(n);
       dsIds(n+1)=linkN.getChild.getId.getValue;    
    end
    [dsId dsIndex]=max(dsIds);
    linkMax=dsLinks.get(dsIndex-1);
    dataset=linkMax.getChild;
    disp(['Dataset Id is:' num2str(dsId)])
    dsId=java.lang.Long(dsId);
    %Get the appropriate tags for this dataset
    %First get the appropriate user
    
    
    [obj tags]=obj.generateTags(metaData,dataset,metaData.user);
    

    disp('Getting service objects...');
    %Get omero service objects
    queryService = obj.Session.getQueryService();
    pixelsService = obj.Session.getPixelsService();
    
    containerService = obj.Session.getContainerService();

    disp('Creating pixels type object...');
    % Get a 16bit pixels type object - all images are saved as 16bit from the
    % microscope - can't save different channels with different bit depths in
    % Omero
    p = omero.sys.ParametersI();
    p.add('type',rstring('uint16'));
    q=['from PixelsType as p where p.value= :type'];
    pixelsType = queryService.findByQuery(q,p);

    %Determine number of positions
    if isfield(metaData,'points')
        numPoints=length(metaData.points);
    else
        numPoints=1;
    end
    
    
    
    
    %%Loop through the positions in this experiment, making an image for each
    disp('Starting loop through positions...');

    for pos=1:numPoints
        %Create the correct folder name
        if isfield(metaData,'points')
            pointName=metaData.points(pos).name
        else
            pointName='';
        end
        if ~strcmp(rootFolder(end),filesep)
            folder=[rootFolder filesep pointName]
        else
            folder=[rootFolder pointName]
        end
                
        %Get the details of all image files in this folder.
        imageFiles=dir(fullfile(folder,'*.png'));

        %Need to know the dimensions (x,y,z,t,c) before creating the image in
        %Omero.
        %x and y - load one image to get that information
        if ~isempty(imageFiles)
        i1=imread([folder filesep imageFiles(1).name]);
        w=whos('i1');i
        mB=w.bytes/10^6;
        mBSize=mBSize+mB;
        sizeX=size(i1,2);
        sizeY=size(i1,1);
        %For z and t information need the image file names arranged by channel
        clear chFiles;
        for ch=1:length(metaData.channels)
            chanStruct=dir(fullfile(folder,['*_' metaData.channels(ch).name '_*']));
            %Convert to a cell array
            chanCell=struct2cell(chanStruct);
            chanCell=(chanCell(1,:))';
            chFiles.(metaData.channels(ch).name)=chanCell;%chFiles will be a structure of cell arrays
        end

        %Now parse the file names to find the maximum z section and the maximum
        %timepoint
        clear chFileInfo
        sizeZ=1;
        sizeT=1;
        for ch=1:length(metaData.channels)
            if ~isempty(chFiles.(metaData.channels(ch).name));
                chFileNames=chFiles.(metaData.channels(ch).name);
                fileNum=1;
                toDelete=false(1,length(chFileNames));
                for n=1:length(chFileNames)
                    a=char(chFileNames{n});
                    %Check that this is a real image file
                    b=strfind(a,['_' metaData.channels(ch).name '_']);
                    chNamePos=length(a)-b(end)-length(metaData.channels(ch).name);%The distance of the last character of the channel name from the end of the string - should be either 8 or 5
                    if chNamePos==8 || chNamePos==5
                        goodFilename=true;
                    else
                        goodFilename=false;
                    end
                    if ~isempty(strfind(a,'.png')) && goodFilename
                        try
                        tNum=a(length(metaData.name)+2:length(metaData.name)+7);
                        catch
                            disp('debug tnum');
                        end
                        tNum=str2num(tNum);
                        try
                        chFileInfo.(metaData.channels(ch).name).timepoints(fileNum)=tNum;
                        catch
                            disp('Debug point: chFileInfo etc.');
                        end
                        k=strfind(a,'_');
                        d=a(:,k(end)+1:k(end)+3);
                        zNum=str2num(d);
                        if ~isempty(zNum)
                            chFileInfo.(metaData.channels(ch).name).sections(fileNum)=zNum;
                        else
                            chFileInfo.(metaData.channels(ch).name).sections(fileNum)=1;
                            zNum=1;
                        end
                        fileNum=fileNum+1;
                    else
                        %The current filename is not a correct image file -
                        %delete it from chFiles.
                        chFiles.(metaData.channels(ch).name)=[];
                    end
                end
                sizeT=max(tNum,sizeT);
                sizeZ=max(sizeZ, max(chFileInfo.(metaData.channels(ch).name).sections));     
           end
        end   
        try
        sizeC=length(fields(chFileInfo));
        catch
            disp('chFileInfo error debug');
        end
        if isempty(sizeZ)
            sizeZ=1;
        end
        if isempty(sizeT)
            sizeT=1;
        end

        %Create the image in Omero for this position
        disp('Creating image...');
        %Get hostname - to record upload
        [idum,hostname]= system('hostname');
try
        iId = pixelsService.createImage(uint32(sizeX), uint32(sizeY), uint32(sizeZ), uint32(sizeT), toJavaList(uint32(1:sizeC)), pixelsType,pointName, [char('Image uploaded from matlab script by:') hostname ' from ' metaData.foldername]);
catch
    disp('debug point - createimage');
end
        imageId = iId.getValue();
        % Then you have to get the PixelsId from that image, to initialise the rawPixelsStore. Use the containerService to get the Image with pixels loaded:
        image = containerService.getImages('Image',  toJavaList(uint64(imageId)),[]).get(0);
        pixels = image.getPrimaryPixels();
        pixelsId = pixels.getId().getValue();
        rawPixelsStore = obj.Session.createRawPixelsStore(); 
        rawPixelsStore.setPixelsId(pixelsId, true)

        %Now can upload the data from each image - using the setPlane method
        disp('Starting loop through channels...');
        for ch=1:sizeC
            chFields=fields(chFileInfo);
            chName=chFields{ch};

            disp(['Uploading data for channel ' chName]);
            maxCh=0;
            minCh=0;
            %Loop through each of the image files
            for f=1:length(chFiles.(chName))
                filename=chFiles.(chName){f};
                k=strfind(filename,['_' chName '_']);
                t=str2num(filename(k-6:k-1));%The timepoint
                k=strfind(filename,['_']);
                z=filename(k(end)+1:k(end)+3);
                z=str2num(z);
                if isempty(z)
                    z=1;
                end
                filename=[folder filesep filename];
                isFile=exist(filename,'file');
                if isFile==2
                    try
                        thisSlice=imread(filename);
                    catch
                        errMessage=[errMessage 'Warning: image file ' filename ' failed to load. Replaced with blank slice.'];
                        thisSlice=zeros(512,512);%NB this line needs edited if we're using this script to upload images of different sizes

                    end
                        
                else
                    thisSlice=zeros(512,512);%NB this line needs edited if we're using this script to upload images of different sizes
                    errMessage=[errMessage 'Warning: image file ' filename ' not found. Replaced with blank slice.'];

                end
                thisMax=max(thisSlice(:));
                maxCh=max(thisMax,maxCh);
                thisMin=min(thisSlice(:));
                minCh=min(thisMin, minCh);

                %Upload the loaded slice to Omero
%                sliceData=omerojava.util.GatewayUtils.convertClientToServer(pixels, thisSlice') ;
                %Change bck to z-1 for multisection
               % try
               
               
                byteArray=toByteArray(thisSlice, pixels);
                
                %pause(1)
                rawPixelsStore.setPlane(byteArray, int32(z-1),int32(ch-1),int32(t-1))
               
  
                
            
                
                
            end
            

            pixelsService.setChannelGlobalMinMax(pixelsId, ch-1, double(minCh), double(maxCh));


        end
        rawPixelsStore.close();
            %Link the new image to the dataset
            %First get a working version of the dataset:
            disp('Linking image to dataset...');
            param = omero.sys.ParametersI();
            param.noLeaves(); % indicate to load the images.
            results = obj.Session.getContainerService().loadContainerHierarchy('omero.model.Dataset', java.util.Arrays.asList(dsId), param);
            if (results.size == 0)
               exception = MException('OMERO:CreateImage', 'Dataset Id not valid');
               throw(exception);
            end 
            dataset = results.get(0);
            %Now create a link object and use it.
            link2 = omero.model.DatasetImageLinkI;
            link2.setChild(omero.model.ImageI(image.getId().getValue(), false));
            link2.setParent(omero.model.DatasetI(dataset.getId().getValue(), false));
            obj.Session.getUpdateService().saveAndReturnObject(link2);

            %Add the tags for this experiment to the image

            for n=1:length(tags);
                %link tag and image
                link = omero.model.ImageAnnotationLinkI;
                thisTag=getTagAnnotations(obj.Session, tags(n));
                link.setChild(thisTag);
                link.setParent(omero.model.ImageI(image.getId().getValue(), false));
                obj.Session.getUpdateService().saveAndReturnObject(link);
                clear link;
            end
        end
    end
    %Link the log, Acq and pos (if present) files to the dataset.
    %First record the fact that this dataset has been uploaded in the log file.
    if isfield(metaData,'logfilename')
    logFile=fopen(metaData.logfilename,'a');%'a'= append - text will be added to the file.
    fprintf(logFile,'\r\n');
    fprintf(logFile,'\r\n');
    %Get the name of this computer (copied from GETCOMPUTERNAME on file 
    %exchange%   m j m a r i n j (AT) y a h o o (DOT) e s
    % (c) MJMJ/2007
    %
    [ret, name] = system('hostname');   
    if ret ~= 0,
       if ispc
          name = getenv('COMPUTERNAME');
       else      
          name = getenv('HOSTNAME');      
       end
    end
    compName = lower(name);

    fprintf(logFile,'%s',['Uploaded to Omero database  by ' compName 'on ' datestr(now)] );
    fprintf(logFile,'\r\n');
    fprintf(logFile,'%s','Function omeroUpload.m');
    fprintf(logFile,'\r\n');
    fprintf(logFile,'%s',['Dataset ID:' num2str(double(dsId))]);
    fclose(logFile);
end

try
    if exist(metaData.logfilename)==2
        
            obj.uploadFile(metaData.logfilename,dataset,'Swain lab experiment log file');
        
        
    end

    if exist(metaData.acqfilename)==2 
        obj.uploadFile(metaData.acqfilename,dataset,'Swain lab acquisition settings file');
    else
        %File may not be there because the acqfilename in the dataset
        %refers to the original location on the microscope computer - won't
        %exist if uploading from another database
        if exist([rootFolder metaData.expname 'Acq.txt'])==2
        	obj.uploadFile([rootFolder metaData.expname 'Acq.txt'],dataset,'Swain lab acquisition settings file');
        end
    end

    if exist(metaData.posfilename)==2
        obj.uploadFile(metaData.posfilename,dataset,'Swain lab position file');
        else
        %File may not be there because the posfilename in the dataset
        %refers to the original location on the microscope computer - won't
        %exist if uploading from another database
        if exist([rootFolder metaData.expname 'Pos.txt'])==2
        	obj.uploadFile([rootFolder metaData.expname 'Pos.txt'],dataset,'Swain lab acquisition settings file');
        end
    end
catch
	errMessage='WARNING: AT LEAST ONE TEXT FILE FAILED TO UPLOAD!';
end   
    obj2=obj;
    %Next two lines avoid a not serializable warning on saving.
    obj2.Session=[];
    obj2.Client=[];
    save(obj.SavePath,'obj2');
    

end



