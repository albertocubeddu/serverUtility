#!/bin/bash

DBUSER="eja"
DBPASSWORD="ajo"

DBOPTIONS="--single-transaction --quick --lock-tables=false"
BACKUPOPTIONS="NICE -n 15" 

#S3 bucket where to upload the things
S3BUCKET="s3://bucket"

#In order of importance
PRODUCT[0]="prod0"
DBNAME[0]="dbname0"
# PRODUCT[1]="prod1"
# DBNAME[1]="dbname1"
# PRODUCT[2]="prod2"
# DBNAME[2]="dbname2"

#Variable for the hours
HOURNOW=$((10#`date +"%H"`))
FOURHOURS=$(( $HOURNOW % 4))

#Directory
#HOUR[0]="hourly" #we don't use that because we want ALWAYS to have a backup hourly
HOURS[1]="4hours"
HOURS[2]="12hours"
HOURS[3]="24hours"

COUNT=${#PRODUCT[@]}
SIZE_ERROR=0;


function calculate_difference {
	if [ ! -z "$1" ]; then
		LAST_SIZE=$(s3cmd du $1 | awk {'print $1'} )
		if [ $(echo $2 | bc) -lt  $(echo $LAST_SIZE | bc) ]; then
			SIZE_ERROR=1;
		fi
	fi;
}

for (( i = 0 ; i < $COUNT ; i++ ))
do
	FILE1H=${PRODUCT[$i]}/"tables_"${PRODUCT[$i]}"_hourly.txt"
	COMMAND1H="cat "$FILE1H

	FILE4H=${PRODUCT[$i]}/"tables_"${PRODUCT[$i]}"_4hours.txt"
	COMMAND4H="cat "$FILE4H

	FILE12H=${PRODUCT[$i]}/"tables_"${PRODUCT[$i]}"_12hours.txt"
	COMMAND12H="cat "$FILE12H

	FILE24H=${PRODUCT[$i]}/"tables_"${PRODUCT[$i]}"_24hours.txt"
	COMMAND24H="cat "$FILE24H

	#Execute this every hour
	if [ -f "$FILE1H" ]; then
		#We don't know if exists.
		LAST_FILE=$(s3cmd ls $S3BUCKET/${PRODUCT[$i]}/hourly/ | tail -n 1 | awk {'print $4'} )
		$BACKUPOPTIONS mysqldump --user=$DBUSER --password=$DBPASSWORD $DBOPTIONS ${DBNAME[$i]} `$COMMAND1H` | gzip -9 -c | tee >(wc -c > size) | (s3cmd put - s $S3BUCKET/${PRODUCT[$i]}/hourly/`date +%Y%m%d`-${PRODUCT[$i]}_hour_`date +"%H"`.sql.gz >> logs/hourly/`date +%Y%m%d`_hour_`date +"%H"` 2>&1)
		CUR_SIZE=$(cat size)

		calculate_difference $LAST_FILE $CUR_SIZE
	fi

	# #execute this every 4 hours
	if [ -f "$FILE4H" ] && [ $FOURHOURS -eq 0 ]; then
		LAST_FILE=$(s3cmd ls $S3BUCKET/${PRODUCT[$i]}/4hours/ | tail -n 2 | head -n 1 | awk {'print $4'} )
		$BACKUPOPTIONS mysqldump --user=$DBUSER --password=$DBPASSWORD $DBOPTIONS ${DBNAME[$i]} `$COMMAND4H` | gzip -9 -c | s3cmd put - s $S3BUCKET/${PRODUCT[$i]}/4hours/`date +%Y%m%d`-${PRODUCT[$i]}_hour_`date +"%H"`.sql.gz >> logs/4hours/`date +%Y%m%d`_hour_`date +"%H"` 2>&1
		CUR_SIZE=$(cat size)
		
		calculate_difference $LAST_FILE $CUR_SIZE
	fi

	#execute at 6AM and 6PM
	if [ -f "$FILE12H" ] && ([ $HOURNOW -eq 12 ] || [ $HOURNOW -eq 18 ]); then
		LAST_FILE=$(s3cmd ls $S3BUCKET/${PRODUCT[$i]}/12hours/ | tail -n 2 | head -n 1 | awk {'print $4'} )
		$BACKUPOPTIONS mysqldump --user=$DBUSER --password=$DBPASSWORD $DBOPTIONS ${DBNAME[$i]} `$COMMAND12H` | gzip -9 -c | s3cmd put - s $S3BUCKET/${PRODUCT[$i]}/12hours/`date +%Y%m%d`-${PRODUCT[$i]}_hour_`date +"%H"`.sql.gz >> logs/12hours/`date +%Y%m%d`_hour_`date +"%H"` 2>&1
		CUR_SIZE=$(cat size)

		calculate_difference $LAST_FILE $CUR_SIZE
	fi

	# daily backup 9PM
	if [ -f "$FILE24H" ] && [ $HOURNOW -eq 21 ]; then
		LAST_FILE=$(s3cmd ls $S3BUCKET/${PRODUCT[$i]}/24hours/ | tail -n 2 | head -n 1 | awk {'print $4'} )
		$BACKUPOPTIONS mysqldump --user=$DBUSER --password=$DBPASSWORD $DBOPTIONS ${DBNAME[$i]} `$COMMAND24H` | gzip -9 -c | s3cmd put - s $S3BUCKET/${PRODUCT[$i]}/24hours/`date +%Y%m%d`-${PRODUCT[$i]}_hour_`date +"%H"`.sql.gz >> logs/24hours/`date +%Y%m%d`_hour_`date +"%H"` 2>&1
		CUR_SIZE=$(cat size)

		calculate_difference $LAST_FILE $CUR_SIZE
	fi
done


###########################
#	MONITORING SYSTEM
###########################

#email stuff 
ERRORTOLOOKFOR="error"

#Create and delete the file (if no one exist we avoid error message)
touch temp_error; touch temp_body
rm temp_error; rm temp_body

if [ "$SIZE_ERROR" -eq "1" ]; then
	echo "File size smaller than the previous file uploaded. Please check all backups." > temp_error
	mail -s "***** ERRORS FILE SIZE ON BACKUP *****" email@me.me < temp_error
fi

#This is always executed, we want to do hourly backup!
grep -i -l $ERRORTOLOOKFOR ./logs/hourly/`date +%Y%m%d`_hour_`date +"%H"` > temp_error
echo -e "\n *********** 1 HOUR LOG ************* \n" > temp_body
cat ./logs/hourly/`date +%Y%m%d`_hour_`date +"%H"` >> temp_body

for day in ${HOURS[@]}; do
	if [ -s "logs/$day/`date +%Y%m%d`_hour_`date +"%H"`" ]; then
		echo -e "\n *********** "$day" LOG ************* \n" >> temp_body

		grep -i -hn $ERRORTOLOOKFOR ./logs/$day/`date +%Y%m%d`_hour_`date +"%H"` >> temp_error 2>&1 
		cat ./logs/$day/`date +%Y%m%d`_hour_`date +"%H"` >> temp_body 2>&1 
	fi
done


if [ -s "temp_error" ]; then
	mail -s "***** ERRORS ON BACKUP *****" email@me.me < temp_error
else
	mail -s "[backup] Log Message" email@me.me < temp_body
fi
