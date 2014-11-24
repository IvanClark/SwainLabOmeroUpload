function path=getOriginalPath(logfile)
%Returns the original path in which a microscopy experiment was saved (from
%the logfile)
%logfile input can be either a path or an open file handle
if ischar(logfile)
    logfile=fopen(logfile);
end

rawdata=textscan(logfile,'%s','BufSize',20000,'delimiter',char(10));
rawdata=rawdata{:};
acqLine=strfind(rawdata,'Acquisition settings are saved in:');
acqLine=find(~cellfun(@isempty,acqLine));
path=rawdata{acqLine+1};
%path is now the full path to the acq file.
%Remove the filename for the folder location
k=strfind(path,'/');
path=path(1:k(end));
fclose(logfile);
