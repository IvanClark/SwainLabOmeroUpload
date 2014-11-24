function [obj tagIds]=generateTags(obj,metaData, dataset, user)
%Generates Omero tags for the input dataset based on the input metaData (created by
%the parseMetadata method of Timelapse). Outputs a structure array of Omero
%tag objects

%Check for any tags in the metaData derived from the log file. If there are
%any, check if they are new tags. Record
%in obj.Tags and copy their ids to the tags output array.

tagNames=obj.getTagNames(true);%Cell array of tag strings already in the database
%These 3 lines avoid an error if there is no tags field recorded in the
%metaData
if~isfield(metaData,'tags');%Need to know if there is a tag field recorded in the metaData.
	metaData.tags={metaData.date};
end
tagIds=zeros(length(metaData.tags),1);

%Check if there is a date tag in the list of tags in the metadata - if
%there isn't then add one.
anyDate=false;
for n=1:length(metaData.tags)
    isDate=obj.checkForDate(metaData.tags{n});
   if isDate
       anyDate=true;
   end
end
if ~anyDate
   metaData.tags{n+1}=metaData.date;
end

%Add a user tag to the list of tags to add.
if nargin<4
    user=obj.User
end
if ~any(strcmp(metaData.tags,user));
    metaData.tags{end+1}=user;
end

tagIndices=zeros(length(metaData.tags),1);%holds the indices (in obj.Tags) to the tag objects for each tag recorded in the metadata


%Loop through the tags required, look for each one in the recorded data
%in obj.Tags - if it's in the database then attach it to the dataset. If not,
%create it then attach it and record it in the OmeroDatabase object
for n=1:length(metaData.tags)
    comp=strcmp(metaData.tags{n},tagNames);
    comp=comp(:);
    if any(comp)
        %This tag has been recorded in the saved OmeroDatabase
        %object - doesn't mean it's in the database yet.
        ind=find(comp);%index to the tag in obj.Tags
        ind=ind(1);
        thisTagId=obj.Tags(ind).id;%This will be zero if the tag is not in the database - ie was recorded by the microscope software but not yet uploaded
        tagIndex=ind;%This will be used to alter the id if a new tag object needs to be created.
        inDbInfo=true;
    else
        %There is no tag in the OmeroDatabase object with this name
        inDbInfo=false;
        thisTagId=0;
    end
    if thisTagId==0
        %There is no tag with this string in the database - need to
        %make one.
        disp(['Creating tag: ' metaData.tags{n}]);
        thisTag=omero.model.TagAnnotationI;
        thisTag.setTextValue(omero.rtypes.rstring(metaData.tags{n}));
        if inDbInfo
            if isfield(obj.Tags,'description')
                thisTag.setDescription(omero.rtypes.rstring(obj.Tags(ind).description));
            end
        end
        %Link the newly-created tag to the dataset
        link = omero.model.DatasetAnnotationLinkI;
        link.setChild(thisTag);
        link.setParent(dataset);
        obj.Session.getUpdateService().saveAndReturnObject(link);
        clear link;

        %Now need the tag Id - this can not be obtained from the
        %thisTag object - need to get it from the database
        thisDsTags=getDatasetTagAnnotations(obj.Session, dataset.getId.getValue);
        nTags=thisDsTags.size;
         
        for tg=1:nTags
           if n==1
              tagText=thisDsTags.getTextValue.getValue;

               if strcmp(thisTag.getTextValue.getValue, tagText)
                   thisUploadedTag=thisDsTags; 
               end
           else
               %This bit needs to be tested - need a dataset with >1 new
               %tag
               tagText=thisDsTags(tg).getTextValue.getValue;
               if strcmp(thisTag.getTextValue.getValue, tagText)
                   thisUploadedTag=thisDsTags(tg);
               end
               
           end
        end
        %Record the details of the new tag in both the tagIds output and
        %obj.Tags
        thisTagId=thisUploadedTag.getId.getValue;
        tagIds(n)=thisTagId;
        %Make a record of the new tag if it doesn't exist
        if inDbInfo
            obj.Tags(tagIndex).id=thisTagId;
        else
            obj.Tags(end+1).name=metaData.tags{n};
            obj.Tags(end).id=thisTagId;
        end


    else
        %The tag is already present in the database
        %Use its Id (instead of a new tag object) to link it to the dataset
        link = omero.model.DatasetAnnotationLinkI;
        thisTag=getTagAnnotations(obj.Session, thisTagId);
        link.setChild(thisTag);
        link.setParent(dataset);
        obj.Session.getUpdateService().saveAndReturnObject(link);
        clear link;
        tagIds(n)=thisTagId;
    end

end
    








end