#!/bin/bash

DBUSER="sqlUser"
DBPASSWORD="sqlPass"
OUTPUT="/srv/backups/lastBkp/"
OUTPUTTMP="/srv/backups/lastBkpTmp/"
OUTPUTMONTH="/srv/backups/monthBkp/"
#how many rotative backup you wanna save?
NUMBERBACKUPTOSAVE=7
#Date of the month to the FIXED month backup
DATETOSAVEOFTHEMONTH=15

#Where is you website?
PATHWEBSITE="/var/www/"

if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

#Create the direcory if not exist (first time probably..)
if [ ! -d "$OUTPUT" ]; then
	mkdir -p $OUTPUT
fi

if [ ! -d "$OUTPUTMONTH" ]; then
	mkdir -p $OUTPUTMONTH
fi

if [ ! -d "$OUTPUTTMP" ]; then
        mkdir -p $OUTPUTTMP
fi

	#call mysql and remove the Database string, so we have only the string of the db tables.
databases=`mysql --user=$DBUSER --password=$DBPASSWORD -e "SHOW DATABASES;" | grep -v Database` 

	#Dump single database.	
for db in $databases; do
    if [ "$db" != "information_schema" ] && [ "$db" != "mysql" ] && [ "$db" != "performance_schema" ]; then
        echo "Dumping database: $db"
        mysqldump --user=$DBUSER --password=$DBPASSWORD --databases $db > $OUTPUTTMP/`date +%Y%m%d`.$db.sql
        gzip $OUTPUTTMP/`date +%Y%m%d`.$db.sql
    fi
done
	# SAVE EACH WEBSITE SEPARATELY
for file in $PATHWEBSITE*/; do 
	tmp=$(echo "$file" | awk 'BEGIN { FS="/" } {print $4}')
	echo $tmp'.tar.gz'
	tar -czpf $OUTPUTTMP`date +%Y%m%d`.$tmp.tar.gz $file
done

	#SAVE ALL THE DATABASES AND ALL THE WEBSITE IN ONE FILE
mysqldump -A --user=$DBUSER --password=$DBPASSWORD --events > $OUTPUTTMP/`date +%Y%m%d`.'complete'.sql
gzip $OUTPUTTMP/`date +%Y%m%d`.'complete'.sql

DATESAVE=$(( $((10#`date +%d`))  % NUMBERBACKUPTOSAVE))
DATEDAY=$((10#`date +%d`))

if [ $DATEDAY -eq $DATETOSAVEOFTHEMONTH ]; then
	tar -cpf $OUTPUTMONTH`date +%Y%m%d`.'completeSqlAndWebsite'.tar.gz $OUTPUTTMP*
fi

# SAVE ALL THE DATABASE AND THE WEBSITE IN ONE FILE.
tar --remove-files -cpf $OUTPUT$DATESAVE.'completeSqlAndWebsite'.tar.gz $OUTPUTTMP*

