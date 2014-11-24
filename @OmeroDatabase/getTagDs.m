function [dsIds dsNames dsDescriptions tagString]=getTagDs(obj,tagName)

%Returns arrays describing the datasets associated with the input tag name


%Get a cell array with all the tag names
tagNames=obj.getTagNames(true);
tagIndex=find(strcmp(tagNames,tagName));

tagId=obj.Tags(tagIndex).id;
%Get the tag object
tag=getTagAnnotations(obj2.Session, tagId);



end