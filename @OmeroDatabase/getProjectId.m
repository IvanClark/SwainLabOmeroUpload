function id=getProjectId(obj, projName)
%Returns the id of the input project. Returns 0 if there is no project with
%the input name.
projCell=struct2cell(obj.Projects);
names=projCell(1,:);
ind=strcmp(projName,names);
ind=find(ind);
ind=ind(1);
id=obj.Projects(ind).id;