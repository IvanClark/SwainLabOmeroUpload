function obj=getPwd(obj)
%Replace ultimately with some encrypted method
    switch obj.User
            case 'Ivan'
                obj.Uname='v1iclar2';
                obj.pwd='ic+wad02';
            case 'Elco'
                obj.Uname='s1135844';
                obj.pwd='Rutherford4769';
            case 'Chris'
                obj.Uname='s1038014';
                obj.pwd='Darwin0720';
            case 'Matt'
                obj.Uname='mcrane2';
                obj.pwd='Darwin1983';
            case 'Luis'
                obj.Uname='s1259407';
                obj.pwd='Swann8954';
            case 'Derek'
                obj.Uname='s1256902';
                obj.pwd='4693Ashworth';
            case 'Bruno'
                obj.Uname='BMartins';
                obj.pwd='5389Waddington';
            case 'Catie'
                obj.Uname='clichten';
                obj.pwd='8609Darwin';
            case 'Swain Lab'
                obj.Uname='Swain lab';
                obj.pwd='JCMB7467';
            case 'root'
                obj.Uname='root';
                obj.pwd='omero';
        case 'upload'
            obj.Uname='upload'
            obj.pwd='johannesburg';
               
    end
end