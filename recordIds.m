function ids=recordIds(datasets)
%generates a list of dataset Ids from the input datasets array (output by
%getDatasets function)
ids=zeros(length(datasets),1);
for ds=1:length(datasets)
        ids(ds)=datasets(ds).getId.getValue;
end