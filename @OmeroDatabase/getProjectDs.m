function [dsIds dsNames dsDescriptions dsTags]=getProjectDs(obj,projName)
%Returns arrays describing the datasets associated with the project with
%the input name

disp('Getting the project from the database');
[prjId projDescription ind]=obj.getProjectInfo(projName);




proj=getProjects(obj.Session,prjId,false);
%Download the datasets
dsList=proj.linkedDatasetList;
%Loop through them, getting ids, names, tags and descriptions
dsIds=zeros(1,dsList.size);
dsNames={};
dsDescriptions={};
dsTags={};
disp('Downloading dataset names, ids and tags');
for n=1:dsList.size
    ds=dsList.get(n-1);
    dsIds(n)=ds.getId.getValue;
    dsNames{n}=char(ds.getName.getValue);
    if ~isempty(ds.getDescription)   
        dsDescriptions{n}=char(ds.getDescription.getValue);
    else
        dsDescriptions{n}='';
    end
    tags=getDatasetTagAnnotations(obj.Session,ds.getId.getValue);
    tagString='';
    for tg=1:length(tags)
        tagName=tags(tg).getTextValue.getValue;
        if tg==1
            tagString=char(tagName);
        else
            tagString=[tagString ', ' char(tagName)];
        end
    end
    dsTags{n}=tagString;
    n
end

