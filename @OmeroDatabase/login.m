function obj=login(obj)
    %Populates the Session and Client fields of an OmeroDatabase object by
    %logging in to the database
    sesh=true;
    try
        %If this line doesn't give an error then there is an already active session - don't do anything       
        obj.Session.getConfigService;    
    catch
    %This session is not logged in - need to create a session
    disp('Connecting to Omero database...');
    obj=obj.getPwd;
    obj.Client=omero.client(obj.Server,obj.Port);
    omTimer=omeroKeepAlive(obj.Client);
    obj.Session= obj.Client.createSession(obj.Uname, obj.pwd);
    obj.UserId = obj.Session.getAdminService().getEventContext().userId;
    obj.GroupId = obj.Session.getAdminService().getEventContext().groupId;
    sesh=false;
    end
    
    if sesh
       disp('The Omero session associated with this OmeroDatabase object is already logged in');
    end
    
end