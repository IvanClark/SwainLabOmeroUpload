function obj=updateDbInfo(obj)
        %Updates the OmeroDatabase object to reflect the current contents of the
        %database
        
        %First log in if necessary
        if ~obj.SessionActive
           obj=obj.login; 
        end
        
        %Get the list of projects
        disp('Getting projects list...');     
        prj=getProjects(obj.Session);%NOTE - THE getProjects FUNCTION HAS BEEN EDITED
                                 %TO PREVENT IT LOADING ALL THE IMAGES AND
                                 %DATASETS AS WELL AS THE PROJECTS
                                 %THIS WILL HAVE TO BE REDONE AFTER ANY UPDATES
                                 %OF OMEROMATLAB - JUST COMMENT THE LINE:
                                 %if ip.Results.loaded, parameters.leaves(); end
        
        
                                 
        %Information on projects already present in the OmeroDatabase object
        
        if ~isempty(obj.Projects)
            %THIS PART NEEDS CHECKING
            numProjects=length(obj.Projects);
            projectsRecorded=struct2cell(obj.Projects);
            projectNames=squeeze(projectsRecorded(1,:,:));%Cell array of the names of the projects already present in dbInfo
        else
             %No projects have yet been recorded.
             numProjects=0;
             projectNames=cell('');
        end
        %Loop through projects just obtained from the database and record
        %their id numbers, names and descriptions
        for n=1:length(prj)
            name=char(prj(n).getName.getValue);
            %Add to the OmeroDatabase object if it's not there already
            if ~any(strcmp(name,projectNames))
                %This project has not previously been recorded
                numProjects=numProjects+1;
                obj.Projects(numProjects).name=name;
                id=prj(n).getId.getValue;
                id=double(id);
                obj.Projects(numProjects).id=id;
            else
                %The project has been recorded - check the id is correct - may not
                %be recorded properly
                id=prj(n).getId.getValue;
                ind=find(strcmp(name,projectNames));
                ind=ind(1);
                dbInfo.Projects(ind).id=id;
            end
        end

        %Get the list of datasets
        disp('Getting datasets list...');
        datasets=getDatasets(obj.Session);%NOTE - THE getDatasets FUNCTION HAS BEEN EDITED
                                 %TO PREVENT IT LOADING ALL THE IMAGES WITH THE 
                                 %DATASETS
                                 %THIS WILL HAVE TO BE REDONE AFTER ANY UPDATES
                                 %OF OMEROMATLAB - JUST COMMENT THE LINE:
                                 %if ip.Results.loaded, parameters.leaves(); end
        %First get the list of names of datasets already recorded in the OmeroDatabase object                       
        if ~isempty(obj.Datasets)
            numDatasets=length(obj.Datasets);
            datasetsRecorded=struct2cell(obj.Datasets);
            datasetNames=squeeze(datasetsRecorded(1,:,:));%Cell array of the names of the projects already present in dbInfo
        else
             %No datasets have yet been recorded.
             numDatasets=0;
             datasetsRecorded=cell('');
             datasetNames=cell('');
        end
           
        %Loop through datasets just obtained from the database and record
        %their id numbers and names
        for n=1:length(datasets)
            name=char(datasets(n).getName.getValue);
            %Add to the OmeroDatabase object if it's not there already
            if ~any(strcmp(name,datasetNames))
                %This project has not previously been recorded
                numDatasets=numDatasets+1;
                obj.Datasets(numDatasets).name=name;
                id=datasets(n).getId.getValue;
                id=double(id);
                obj.Datasets(numDatasets).id=id;
            else
                %The dataset has been recorded - check the id is correct - may not
                %be recorded properly
                id=datasets(n).getId.getValue;
                ind=find(strcmp(name,datasetNames));
                ind=ind(1);
                obj.Datasets(ind).id=id;
            end
        end
        
        
        
        
        %Next get information on the tags. These are attached to datasets
        %so need to loop through them getting their associated tags.
        
        %First get the list of tags already recorded in this object.                              
                                 
        if ~isempty(obj.Tags)
            tagStrings=obj.getTagNames(1);
            numTags=length(obj.Tags);
        else
            numTags=0;
            tagStrings=cell('');
        end
        disp('Checking for new tags');
        %Loop through the datasets getting their associated tags
        for n=1:length(datasets)
            disp([num2str(n)  ' of ' num2str(length(datasets)) ' datasets']);
            d=datasets(n); 
            id=d.getId().getValue();
            tas = getObjectAnnotations(obj.Session, 'tag', 'dataset', id);
            %tas is a java array of tag objects associated with this dataset
            %Loop through them checking if the tag string is in obj.Tags
            for ds=0:size(tas)-1
                t=tas.get(ds);
                text=char(t.getTextValue.getValue);
                id=t.getId.getValue;
                description=t.getDescription;
                if ~isempty(description)
                    description=char(t.getDescription.getValue);
                end
                if ~any(strcmp(text,tagStrings))
                    %This tag has not yet been recorded in the object
                    numTags=numTags+1;
                    obj.Tags(numTags).name=text;
                    obj.Tags(numTags).description=description;
                    obj.Tags(numTags).id=id;
                    isDate=obj.checkForDate(text);
                    obj.DateTags(numTags)=isDate;
                    %Add to the tagstrings cell array - this will
                    %prevent duplicate tags from being uploaded
                    tagStrings{length(tagStrings)+1}=text;
                    
                end                
            end
        end

        %Save the information on the microscope computer - required by the
        %multiDGUI acquisition software (set SessionActive to false - will
        %not be logged in when this is reloaded).
        
        obj2=obj;
        obj.Session=[];
        obj.Client=[];
        obj.DateTag=[];
        obj.SessionActive=false;
        save(obj.SavePath,'obj');
        obj=obj2;
    
    


        
    end