function saveDbData(obj)
%Gets the dataset ids, names, projects and tags and saves them in table
%form

obj=obj.login;
dataSize=0;
projNames=obj.getProjectNames;
for p=1:length(projNames)
    [dsIds dsNames dsDescriptions dsTags]=obj.getProjectDs(projNames{p});
    for n=1:length(dsIds)
        dataSize=dataSize+1;
        data{dataSize,1}=dsIds(n);        
        data{dataSize,2}=projNames{p};
        data{dataSize,3}=dsNames{n};
        data{dataSize,4}=dsTags{n};
    end    
end

save (obj.SaveTablePath,'data');
end