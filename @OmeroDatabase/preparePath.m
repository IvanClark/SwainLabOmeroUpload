function preparePath

disp('Preparing file paths...');
thispath=mfilename('fullpath');
k=strfind(thispath,'/');
Thatpath=[thispath(1:k(end-1)) 'OMERO.matlab-5.0.0-ice35-b19'];
addpath(genpath(Thatpath));
loadOmero;
addpath(genpath('/Users/iclark/Documents/YeastSegmentation/Segmentation software'));
