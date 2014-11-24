function uploadFile(obj, filename, dataset, description)  
    %Uploads the file represented by the input filename to the omero
    %database and links it to the input dataset.
    fa = writeFileAnnotation(obj.Session, filename, 'description',description);   
    link = omero.model.DatasetAnnotationLinkI;
    link.setParent(dataset)
    link.setChild(fa)
    link = obj.Session.getUpdateService().saveAndReturnObject(link);

    
    
%     iUpdate = obj.Session.getUpdateService(); % service used to write object
%     file = java.io.File(filename);
%     name = file.getName();
%     absolutePath = file.getAbsolutePath();
%     path = absolutePath.substring(0, absolutePath.length()-name.length());
%     originalFile = omero.model.OriginalFileI;
%     originalFile.setName(omero.rtypes.rstring(name));
%     originalFile.setPath(omero.rtypes.rstring(path));
%     originalFile.setSize(omero.rtypes.rlong(file.length()));
%     originalFile.setSha1(omero.rtypes.rstring('ivan'));
%     originalFile.setMimetype(omero.rtypes.rstring('text'));    
%     % now save the originalFile object
%     originalFile = iUpdate.saveAndReturnObject(originalFile);
%     % Initialize the service to load the raw data
%     rawFileStore = obj.Session.createRawFileStore();
%     rawFileStore.setFileId(originalFile.getId().getValue());
% 
%     %code for small file.
%     fid = fopen(filename);
%     byteArray = fread(fid,[1, file.length()], 'uint8');
%     rawFileStore.write(byteArray, 0, file.length());
%     fclose(fid);
% 
% 
%     originalFile = rawFileStore.save();
%     % Important to close the service
%     rawFileStore.close();
%     
%     
%     %File is uploaded. Create a file annotation object to link it to the
%     %dataset
%     fa = omero.model.FileAnnotationI;
%     fa.setFile(originalFile);
%     if nargin>3
%         fa.setDescription(omero.rtypes.rstring(description)); % The description set above e.g. PointsModel
%     end
%     fa.setNs(omero.rtypes.rstring('Created by MultiDGUI on Swain microscope')); % The name space you have set to identify the file annotation.
%     % save the file annotation.
%     fa = iUpdate.saveAndReturnObject(fa);
% 
%     % now link the image and the annotation
%     link = omero.model.DatasetAnnotationLinkI;
%     link.setChild(fa);
%     link.setParent(dataset);
%     % save the link back to the server.
%     iUpdate.saveAndReturnObject(link);