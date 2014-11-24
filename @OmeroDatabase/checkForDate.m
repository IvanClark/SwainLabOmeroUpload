function isDate=checkForDate(text)
    %Returns true if the input text is a date string as recorded by
    %MultiDGUI. False if not

    monthCell={'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
    isDate=true;
    if length(text)==11
        if isempty(str2num(text(1:2)))
            isDate=false;
        else
            if str2num(text(1:2))>31 || str2num(text(1:2))<1
                isDate=false;
            end
        end
        if ~strcmp(text(3),'-') || ~strcmp(text(7),'-')
            isDate=false;
        end
        if ~(any(strcmp(text(4:6),monthCell)))
            isDate=false;
        end
        if isempty(str2num(text(8:end)))
            isDate=false;
        else
            if str2num(text(8:end))>2020 || str2num(text(8:end))<2012
                isDate=false;
            end
        end



    else
        isDate=false;
    end


end