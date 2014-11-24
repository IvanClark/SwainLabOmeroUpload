function [id description ind]=getProjectInfo(obj, projName)
%Returns the id, description and index (in obj.Projects) of the input project. Returns 0 if there is no project with
%the input name.
ind=[];
if ~isempty(obj.Projects)
    projCell=struct2cell(obj.Projects);
    names=projCell(1,:);
    ind=strcmp(projName,names);
    ind=find(ind);
    if ~isempty(ind)
        ind=ind(1);
        id=obj.Projects(ind).id;
        if isfield(obj.Projects,'description')
            description=obj.Projects(ind).description;
        else
            description='';
        end
    else
        %No project exists with this name
        id=0;
        description='';
    end
else
    id=0;
    description='';
    
end