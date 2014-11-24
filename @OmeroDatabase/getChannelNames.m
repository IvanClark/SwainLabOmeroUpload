function channelNames=getChannelNames(obj, dataset)
%Returns a structures representing the channels of the
%input dataset, in order of their appearance in the images within it.

%Get all files attached to the dataset - This will not work until the
%server software is updated - Gareth was asked to do this 14/2/14
% files=getDatasetFileAnnotations(obj.Session,dataset.getId.getValue);
% %Loop through, finding the acq file
%  for n=1:files.size(1)
%      file=files(n);
%      desc=files(n).getDescription.getValue;
%      
%  end

%Without the acq file - get the first image in the dataset and see how many
%channels it has. Then just make a cell array with 'Channel 1', 'Channel 2'
%etc.
images=dataset.linkedImageList;
if ~isempty(images)
image=images.get(0);
pix=image.getPrimaryPixels;
numChannels=pix.getSizeC.getValue;
channelNames=struct;
for n=1:numChannels
    channelNames(n).name=['Channel' num2str(n)];
end
else
    channelsNames='';
end

