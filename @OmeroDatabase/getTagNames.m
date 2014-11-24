function tagNames=getTagNames(obj,dates)
%Returns a cell array with the names of the tags recorded in the
%OmeroDatabase object. dates is a boolean. If true - return all tags. If
%false return only the tags that are not date tags.
if ~isempty(obj.Tags)
tagCell=struct2cell(obj.Tags);

if dates
    tagNames=tagCell(1,:);
else
    if ~isempty(obj.DateTags)
        tagNames=tagCell(1-obj.DateTags);
    else
        %The info on whether a tag is a date tag isn't there
        tagNames=tagCell(1,:);
        numTags=0;
        for n=1:length(tagNames)
            if ~obj.checkForDate(tagNames{n})
                numTags=numTags+1;
                newTags{numTags}=tagNames{n};                
            end
        end
        tagNames=newTags;
    end
end
%tagNames=sort(tagNames);This line should be moved to microscope
%acquisition software - makes the menu look tidier - but would mess up the
%data upload software
else
    tagNames={};
end

