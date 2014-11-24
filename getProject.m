function project=getProject(session, prjId)
%Returns a project object with the given input Id.
%A simplified and working version of the getProjects function from omero
%matlab
objectTypes = getObjectTypes();
objectNames = {objectTypes.name};
type='project';
objectType = objectTypes(strcmp(type, objectNames));
params=omero.sys.ParametersI();
id=toJavaList(java.lang.Long(prjId));
proxy = session.getContainerService();

objectList = proxy.loadContainerHierarchy(objectType.class,id,params)
project=toMatlabList(objectList);
end