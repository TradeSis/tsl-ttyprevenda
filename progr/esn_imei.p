def input parameter p-s as char.
def output parameter p-ok as log.

p-ok = yes.

if length(p-s) <> 8  and
   length(p-s) <> 11 and
   length(p-s) <> 15 and
   length(p-s) <> 17 and
   length(p-s) <> 18 and
   length(p-s) <> 19 and
   length(p-s) <> 20 
then p-ok = no.
else  
    if  substr(p-s,1,1) <> "0" and
        substr(p-s,1,1) <> "1" and
        substr(p-s,1,1) <> "2" and
        substr(p-s,1,1) <> "3" and
        substr(p-s,1,1) <> "4" and
        substr(p-s,1,1) <> "5" and
        substr(p-s,1,1) <> "6" and
        substr(p-s,1,1) <> "7" and
        substr(p-s,1,1) <> "8" and
        substr(p-s,1,1) <> "9" 
    then p-ok = no.
    else 
        if  substr(p-s,2,1) <> "0" and
            substr(p-s,2,1) <> "1" and
            substr(p-s,2,1) <> "2" and
            substr(p-s,2,1) <> "3" and
            substr(p-s,2,1) <> "4" and
            substr(p-s,2,1) <> "5" and
            substr(p-s,2,1) <> "6" and
            substr(p-s,2,1) <> "7" and
            substr(p-s,2,1) <> "8" and
            substr(p-s,2,1) <> "9" 
        then p-ok = no.

if length(p-s) = 16  
then do:
    p-ok = yes.
    if  substr(p-s,1,1) = "0" or
        substr(p-s,1,1) = "1" or
        substr(p-s,1,1) = "2" or
        substr(p-s,1,1) = "3" or
        substr(p-s,1,1) = "4" or
        substr(p-s,1,1) = "5" or
        substr(p-s,1,1) = "6" or
        substr(p-s,1,1) = "7" or
        substr(p-s,1,1) = "8" or
        substr(p-s,1,1) = "9" 
    then p-ok = no.
    else 
        if  substr(p-s,3,1) <> "0" and
            substr(p-s,3,1) <> "1" and
            substr(p-s,3,1) <> "2" and
            substr(p-s,3,1) <> "3" and
            substr(p-s,3,1) <> "4" and
            substr(p-s,3,1) <> "5" and
            substr(p-s,3,1) <> "6" and
            substr(p-s,3,1) <> "7" and
            substr(p-s,3,1) <> "8" and
            substr(p-s,3,1) <> "9" 
        then p-ok = no.
        else if  substr(p-s,4,1) = "0" or
        substr(p-s,4,1) = "1" or
        substr(p-s,4,1) = "2" or
        substr(p-s,4,1) = "3" or
        substr(p-s,4,1) = "4" or
        substr(p-s,4,1) = "5" or
        substr(p-s,4,1) = "6" or
        substr(p-s,4,1) = "7" or
        substr(p-s,4,1) = "8" or
        substr(p-s,4,1) = "9" 
    then p-ok = no.
    else 
        if  substr(p-s,7,1) <> "0" and
            substr(p-s,7,1) <> "1" and
            substr(p-s,7,1) <> "2" and
            substr(p-s,7,1) <> "3" and
            substr(p-s,7,1) <> "4" and
            substr(p-s,7,1) <> "5" and
            substr(p-s,7,1) <> "6" and
            substr(p-s,7,1) <> "7" and
            substr(p-s,7,1) <> "8" and
            substr(p-s,7,1) <> "9" 
        then p-ok = no.

end.
if  length(p-s) = 8  and p-ok = no
then do:
    p-ok = yes.
    if  substr(p-s,1,1) <> "0" and
        substr(p-s,1,1) <> "1" and
        substr(p-s,1,1) <> "2" and
        substr(p-s,1,1) <> "3" and
        substr(p-s,1,1) <> "4" and
        substr(p-s,1,1) <> "5" and
        substr(p-s,1,1) <> "6" and
        substr(p-s,1,1) <> "7" and
        substr(p-s,1,1) <> "8" and
        substr(p-s,1,1) <> "9" 
    then p-ok = no.
    /**
    else 
        if  substr(p-s,3,1) <> "0" and
            substr(p-s,3,1) <> "1" and
            substr(p-s,3,1) <> "2" and
            substr(p-s,3,1) <> "3" and
            substr(p-s,3,1) <> "4" and
            substr(p-s,3,1) <> "5" and
            substr(p-s,3,1) <> "6" and
            substr(p-s,3,1) <> "7" and
            substr(p-s,3,1) <> "8" and
            substr(p-s,3,1) <> "9" 
        then p-ok = no.
        else if  substr(p-s,5,1) = "0" or
        substr(p-s,5,1) = "1" or
        substr(p-s,5,1) = "2" or
        substr(p-s,5,1) = "3" or
        substr(p-s,5,1) = "4" or
        substr(p-s,5,1) = "5" or
        substr(p-s,5,1) = "6" or
        substr(p-s,5,1) = "7" or
        substr(p-s,5,1) = "8" or
        substr(p-s,5,1) = "9" 
    then p-ok = no.
    else 
        if  substr(p-s,6,1) <> "0" and
            substr(p-s,6,1) <> "1" and
            substr(p-s,6,1) <> "2" and
            substr(p-s,6,1) <> "3" and
            substr(p-s,6,1) <> "4" and
            substr(p-s,6,1) <> "5" and
            substr(p-s,6,1) <> "6" and
            substr(p-s,6,1) <> "7" and
            substr(p-s,6,1) <> "8" and
            substr(p-s,6,1) <> "9" 
        then p-ok = no.
    **/
end.
   


   

