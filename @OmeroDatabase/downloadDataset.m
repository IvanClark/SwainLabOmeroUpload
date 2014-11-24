function [obj metaData anyData]=downloadDataset(obj, dsId, downloadPath, allPos, metaData)
    %Creates a folder of images downloaded from the Omero dataset
    %represented by the input Id
    
    %If there is a fourth input and it is true (logical), then all
    %positions are dowloaded without a user prompt
    
    %Optional fifth input removes the need to run parseMetadata
    
    %Output anyData - if false there is no downloaded data
    anyData=false;
    obj.preparePath;
    if ~obj.SessionActive
        obj=obj.login;
    end
    %Get download location
    if nargin>2
        obj.DownloadPath=downloadPath;
    else
        disp('Enter location to download dataset');
        obj.DownloadPath=uigetdir('Location to save the file');
    end
    if ~strcmp(obj.DownloadPath(end),filesep)
        obj.DownloadPath(end+1)=filesep;
    end
    
    %Download the dataset with images
    disp(['Loading the dataset ' num2str(dsId) ' from Omero server']);
    params=omero.sys.ParametersI();
    params.leaves;
    proxy=obj.Session.getContainerService;
    datasets=proxy.loadContainerHierarchy('omero.model.Dataset', toJavaList(java.lang.Long(dsId)), params);
    dataset=datasets.get(0);
    %Download the attached files - this provides the channels and other
    %metadata info from the acq and log files.\
    try
        obj.FilePaths=obj.downloadFiles(dataset);
    catch
       disp('Failed to download text files');
    end
    
    images=dataset.linkedImageList;

    %Get the metaData from the Acq file - gives you the channel names
    if nargin<5
    metaData=parseMetaData(obj.DownloadPath);  
    else
        if ~isfield(metaData,'channels')
           %Generate the channel names from the downloaded image
            metaData.channels=obj.getChannelNames(dataset);
        end
    end
if ~isempty(metaData.channels)
    
    if ~allPos
        %User should be asked which positions to download
        %Get list of positions
        for p=1:size(images)
            posList{p}=char(images.get(p-1).getName.getValue);
        end
        [selection,ok] = listdlg('PromptString','Please select positions to download','ListString',posList);
    else
        selection=1:size(images);
    end
    
    for p=1:length(selection)%p is for positions - number of images is usually the number of positions in the acquisition
        image=images.get(selection(p)-1);
        pixels=image.getPrimaryPixels;
        %get the image dimensions
        sizeZ = pixels.getSizeZ().getValue(); % The number of z-sections.
        sizeT = pixels.getSizeT().getValue(); % The number of timepoints.
        sizeC = pixels.getSizeC().getValue(); % The number of channels.
        sizeX = pixels.getSizeX().getValue(); % The number of pixels along the X-axis.
        sizeY = pixels.getSizeY().getValue(); % The number of pixels along the Y-axis.
        posName=char(image.getName.getValue);
        if isempty(posName)
            %This acquisition doesn't have multiple positions - just save
            %in obj.DownloadPath - no need to make a position directory
            posName=char(dataset.getName.getValue);
            posPath=obj.DownloadPath;
        else
            mkdir(obj.DownloadPath,posName);
            posPath=[obj.DownloadPath posName];
        end
        posName        
        [store, pixels] = getRawPixelsStore(obj.Session, image);
        for t=1:sizeT
            for c=1:sizeC
                
                for z=1:sizeZ
                    
                    plane = store.getPlane(z-1, c-1, t-1);
                    
                    
                    
                    plane = toMatrix(plane, pixels)';
                    if max(plane(:))>0%Will get an empty image if this channel is not used at this timepoint
                        anyData=true;
                        filename=obj.makeFileName(metaData, z,c,t);
                        fullPath=[posPath filesep filename];
                        imwrite(plane,fullPath);
                    end
                end
            end
        end 
        store.close();
        clear store;
        clear pixels;
    end
    obj.Client.closeSession;
else
    %No channel names have been defined. Probably means there are no images
    %in the dataset
    
end
end