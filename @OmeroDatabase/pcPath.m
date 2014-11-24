function path=pcPath(obj)
%Returns the save path - defined for macs - for the object in PC format
k=strfind(obj.SavePath,'/');
path=obj.SavePath;
path(k)=filesep;

k=strfind(path,'Swain Lab');
path=path(k:end);
path=['C:\AcquisitionData\' path];

