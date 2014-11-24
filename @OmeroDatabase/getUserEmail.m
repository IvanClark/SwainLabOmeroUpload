function emailAddress=getUserEmail(obj)
%Returns the email address of the current user - for sending progress
%reports on uploads
switch obj.User
    case 'Ivan'
        emailAddress='ivan.clark@ed.ac.uk';
    case 'Chris'
        emailAddress='s1038014@staffmail.ed.ac.uk';
    case 'Matt'
        emailAddress='mcrane2@staffmail.ed.ac.uk';
    case 'Elco'
        emailAddress='E.Bakker@sms.ed.ac.uk';
    case 'Luis'
        emailAddress='nando.mgu@gmail.com';
    case 'Derek'
        emailAddress='s1256902@sms.ed.ac.uk';
    case 'Alejandro'        
        emailAddress='alejandro.granados.c@gmail.com';
    case 'Bruno'        
        emailAddress='ivan.clark@ed.ac.uk';
end

swain={'Ivan' 'Chris' 'Matt' 'Elco' 'Luis' 'Derek' 'Bruno' 'Alejandro'};
