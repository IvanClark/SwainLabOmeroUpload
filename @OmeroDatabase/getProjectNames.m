function projNames=getProjectNames(obj)
%Returns a cell array with the names of all projects in the database
projCell=struct2cell(obj.Projects);
projNames=projCell(1,:);
projNames=sort(projNames);