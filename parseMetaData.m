function metaData=parseMetadata(moviedir)
    % parseMetaData --- returns information on a timelapse acquisition derived from the acq and log text files
    %
    % Synopsis:  metaData = parseMetadata (moviedir)
    %                        
    % Input:     moviedir = string, full path of a folder containing a timelapse acquisition saved by the Swain lab microscope software
    % 
    % Output:   metaData = structure, carries the experiment information

    % Notes:  
    
    %Get the experiment name
    
    %get the experiment name
    k=strfind(moviedir,'/');
    if length(k<2)
        metaData.foldername=moviedir;
        
    else
        if strcmp(moviedir(end),'/')
        metaData.foldername=moviedir(k(end-1)+1:end-1);
        moviedir=moviedir(1:end-1);
    else
        metaData.foldername=moviedir(k(end)+1:end);
    end
    end
    
    metaData.moviedir=moviedir;
    
    %Parse the information in the Acq file.
    acqFile=dir(fullfile(moviedir,'*Acq*'));

    if length(acqFile)>1
        %determine which one is the real acq file and use that
        for n=1:length(acqFile)
            if ~isempty(strmatch(metaData.foldername(1:end-3),acqFile(n).name))
                acqFilename=[moviedir filesep acqFile(n).name];
            end
        end
    else
        if strcmp(moviedir(end),filesep)
            acqFilename=[moviedir acqFile.name];
        else
            acqFilename=[moviedir filesep acqFile.name];
        end
    end
   
    metaData.acqfilename=acqFilename;
  

    %get the experiment name
    k=strfind(acqFilename,'Acq');
    try
    name=acqFilename(1:k(end)-1);
    catch
        disp('debug in parseMetadata');
    end
    k=strfind(acqFilename,filesep);
    metaData.name=name(k(end)+1:end);
    
    acqFile=fopen(acqFilename);
    rawdataAcq=textscan(acqFile,'%s','BufSize',20000);
    rawdataAcq=rawdataAcq{:};
    %Now have access to the information in the Acq file
    
    %Find the positions of the category headings   
    a=strfind(rawdataAcq,'Channels:');
    chanHeading=find(not(cellfun('isempty', a)));%Index just before the channel list
    a=strfind(rawdataAcq,'Z_sectioning:');
    zHeading=find(not(cellfun('isempty', a)));%Index just beyond the channel list
    a=strfind(rawdataAcq,'Time_settings:');
    tHeading=find(not(cellfun('isempty', a)));%Index just beyond the channel list
    a=strfind(rawdataAcq,'Points:');
    pointHeading=find(not(cellfun('isempty', a)));%Index just beyond the channel list
    a=strfind(rawdataAcq,'Flow_control:');
    flowHeading=find(not(cellfun('isempty', a)));%Index just beyond the channel list

    
    %Loop through the channels getting their details.
    for ch=1:zHeading-chanHeading-1
        chPosition=chanHeading+ch;
        k=strfind(rawdataAcq(chPosition),',');
        k=k{:};
        thisChan=rawdataAcq(chPosition);
        thisChan=thisChan{:};
        metaData.channels(ch).name=thisChan(1:k(1)-1);
        metaData.channels(ch).exposure=str2double(thisChan(k(1)+1:k(2)-1));%Time in ms
        metaData.channels(ch).skip=str2double(thisChan(k(2)+1:k(3)-1));%Channel takes an image every nth timepoint
        metaData.channels(ch).zSectioning=logical(str2double(thisChan(k(3)+1:k(4)-1)));%true if this channel does z sectioning
        metaData.channels(ch).startingtimepoint=str2double(thisChan(k(4)+1:k(5)-1));%No images will be taken before this timepoint in this channel
        metaData.channels(ch).cameramode=str2double(thisChan(k(5)+1:k(6)-1));%1 if EM port with gain and exposure correction, 2 if CCD mode, 3 if EM with static gain and exposure 
        metaData.channels(ch).startgain=str2double(thisChan(k(6)+1:k(7)-1));%EM gain at the start of the experiment    
    end
    
    %Record the Z sectioning information
    z=rawdataAcq{zHeading+1};
    k=strfind(z,',');
    metaData.z.numSections=str2double((z(1:k-1)));
    metaData.z.sectionSpacing=str2double((z(k+1:end)));

    %Record the time information
    time=rawdataAcq{tHeading+1};
    k=strfind(time,',');
    metaData.time.istimelapse=logical(str2double((time(1:k(1)-1))));
    metaData.time.interval=str2double((time(k(1)+1:k(2)-1)));
    metaData.time.numTimepoints=str2double((time(k(2)+1:k(3)-1)));
    metaData.time.totalTime=str2double((time(k(3)+1:end)));
    
    %Record the position information
    for pos=1:flowHeading-pointHeading-1
       pointPosition=pointHeading+pos;
       k=strfind(rawdataAcq(pointPosition),',');
       k=k{:};
       thisPoint=rawdataAcq(pointPosition);
       thisPoint=thisPoint{:};
       metaData.points(pos).name=thisPoint(1:k(1)-1);
       metaData.points(pos).x=str2double(thisPoint(k(1)+1:k(2)-1));%stage x position (microns)
       metaData.points(pos).y=str2double(thisPoint(k(2)+1:k(3)-1));%stage y position (microns)
       metaData.points(pos).z=logical(str2double(thisPoint(k(3)+1:k(4)-1)));%z drive position (microns)
       metaData.points(pos).pfsoffset=str2double(thisPoint(k(4)+1:k(5)-1));%pfs offset
       metaData.points(pos).group=str2double(thisPoint(k(5)+1:end));%point group number
       %ADD MORE CODE HERE TO RECORD EXPOSURE TIMES FOR EACH CHANNEL IF
       %THEY HAVE BEEN RECORDED - FIRST CHECK THAT THIS INFORMATION IS
       %RECORDED IN THE ACQ FILE BY THE MICROSCOPE SOFTWARE      
    end

    
       %Record the flow information
       
       %THIS YET TO BE IMPLEMENTED
    
    %Close the Acq file:       
    fclose(acqFile);

    %Now get the information from the log file
    logFile=dir(fullfile(moviedir,'*log*'));

    if length(logFile)>1
        %determine which one is the real log file and use that
        for n=1:length(logFile)
            if ~isempty(strmatch(metaData.foldername(1:end-3),logFile(n).name))
                if strcmp(moviedir(end),filesep)
                    acqFilename=[moviedir logFile(n).name];
                else
                    logFilename=[moviedir filesep logFile(n).name];
                end
            end
        end
    else
        logFilename=[moviedir filesep logFile.name];
    end
    
    
    metaData.logfilename=logFilename;
    logFile=fopen(logFilename);
    try
    rawdataLog=textscan(logFile,'%s','delimiter','\n');
    catch
        disp('debug point in paseMetaData textscan');
    end
    rawdataLog=rawdataLog{:};
    %Now have access to the information in the log file
    metaData.date=rawdataLog{2};
    a=strfind(rawdataLog,'Experiment details:');
    descHeading=find(not(cellfun('isempty', a)));
    metaData.description=rawdataLog{descHeading+1};
    
    %Get the original full path to the acq file - this is unique to each
    %experiment
    a=strfind(rawdataLog,'Acquisition settings are saved in:');
    acqPathHeading=find(not(cellfun('isempty', a)));
    metaData.acqfilename=rawdataLog{acqPathHeading+1};

    %Get Omero project and Tag information if present
    a=strfind(rawdataLog,'Omero project:');
    projHeading=find(not(cellfun('isempty', a)));
    if ~isempty(projHeading)
        metaData.project=rawdataLog{projHeading+1};
    end
    a=strfind(rawdataLog,'Omero tags:');
    tagHeading=find(not(cellfun('isempty', a)));
    if ~isempty(tagHeading)
       tagString=rawdataLog{tagHeading+1};
       k=strfind(tagString,',');
       if ~isempty(k)
            for n=1:length(k)
                if n==1
                    metaData.tags{n}=tagString(1:k(1)-1);
                else
                    if n==length(k)
                        metaData.tags{n}=tagString(k(n-1)+1:end-1);
                    else
                        metaData.tags{n}=tagString(k(n-1)+1:k(n)-1);
                    end
                end

            end
       else
           %There is no comma, just one entry
           metaData.tags{1}=tagString;
       end
    end
    a=strfind(rawdataLog,'Omero tag descriptions:');
    tagDescrHeading=find(not(cellfun('isempty', a)));
    if ~isempty(tagDescrHeading)
        tagDescrString=rawdataLog{tagHeading+1};
        k=strfind(tagDescrString,',');
        for n=1:length(k)+1
            if n==1
                metaData.tagdescriptions{n}=tagString(1:k(1)-1);
            else
                if n==length(k)+1
                    metaData.tagdescriptions{n}=tagString(k(n-1)+1:end);
                else
                    metaData.tagdescriptions{n}=tagString(k(n-1)+1:k(n)-1);
                end
            end

        end
    end
    
    %Close the log file
    fclose(logFile);
    
    %Record the pos filename if there is one. No need to parse that
    %information because it's also in the acq file.
    
     
    posFile=dir(fullfile(moviedir,'*Pos*'));


    posFilename=[moviedir filesep posFile.name];
    
    if exist(posFilename)==2;
        metaData.posfilename=posFilename;
    else
        metaData.posfilename='No pos file';
    end
    
    %Set the experiment name - if it's a downloaded folder then this might
    %not be the same as the folder name
    k=strfind(metaData.logfilename,filesep);
    metaData.expname=metaData.logfilename(k(end)+1:end-7);
    %Set the user - person who ran the experiment
    k=strfind(metaData.acqfilename,'/');
    metaData.user=metaData.acqfilename(k(3)+1:k(4)-1);
    
end