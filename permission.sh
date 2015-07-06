#!bin/sh
WEBPATH="/var/www";
chown www-data:www-data -R $WEBPATH;

#The   format   of   a   symbolic   mode   is    ‘[ugoa...][[+-=][rwxXs-tugo...]...][,...]’.
#A combination of the letters ‘ugoa’ controls which users’ access to the file  will  be  changed:
#	g:  other users in the file’s group (g)

#The operator ‘+’ causes the permissions selected to  be  added  to  the existing  permissions  of each file; ‘-’ causes them to be removed; and ‘=’ causes them to be the only permissions that the file has.

#The letters ‘rwxXstugo’ select the new  permissions  for  the  affected users:
#	s: set user or group ID on execution (s)
chmod -R g+s $WEBPATH

find $WEBPATH -type d -exec chmod 775 {} \;
find $WEBPATH -type f -exec chmod 664 {} \;

