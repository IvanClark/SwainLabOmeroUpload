function filename=makeFileName(obj, metaData, z,c,t)
%Returns a MultiDGUI type filename for the input image, z section, channel
%and timepoint

%First make a cell array of channel names - this will later be done by
%interrogating an annotation to the image

expName=metaData.name;


%create a filename - includes the channel name and the path via folder
chName=metaData.channels(c).name;
filename=[expName,'_',sprintf('%06d',t),'_',chName];
filename=strcat(filename,'_',sprintf('%03d',z),'.png');



end