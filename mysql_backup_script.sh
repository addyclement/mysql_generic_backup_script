#!/bin/bash

# Generic Multi DB Backup Script 
# Author(s) : Addy Clement
# Created   : September 11, 2018, Lagos
# Last Revision Date : 
# Revision Notes : 

DATE=$(date +%Y-%m-%d-%H_%M_%S)
FOLD_DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/home/backups/salesdb"
MYSQL_USER=$backup_suer
MYSQL_PASSWORD=$backup_pwd
MYSQL_HOST=$mysql_host


#define connection details for inventory server

STO_USER="$nventory_usr
STO_PASSWORD=$inventory_pwd
STO_HOST=$inventory_host

# create a new directory into backup directory location
mkdir -p $BACKUP_DIR/$FOLD_DATE


#BackUp dbs in the list, excluding DEFINERS
#Min Estimated time : 20mins
echo "dump started : $(date)"

# enter all databases to be backed up in a list

DB_LIST='db1 db2 db3'

cd $BACKUP_DIR

for DB in $DB_LIST;

do

START_TIME=$( date +%H:%M:%S)

DUMP_FILE=$DB-$DATE.sql.gz

#backup the databases in a loop, and pass to gzip compression
#turn on non blocking repeatable read isolation level

mysqldump  -u$MYSQL_USER --single-transaction -h$MYSQL_HOST -p$MYSQL_PASSWORD $DB | gzip -9  > "$BACKUP_DIR/$FOLD_DATE/$DUMP_FILE"

END_TIME=$( date +%H:%M:%S)

#get file size in MB
#FILESIZE=$(stat -c%s "$DUMP_FILE")

FILESIZE=$(stat -c%s "$BACKUP_DIR/$FOLD_DATE/$DUMP_FILE")

#Log dump details to remote server

#designate db_id per dbs to be backed up

mysql -u$STO_USER -h$STO_HOST -p$STO_PASSWORD -e "INSERT INTO inventory_db.backup_logs_table(db_id, db_name, start_time, end_time, dump_size_c, env) VALUES(102, '$DB', '$START_TIME', '$END_TIME' , '$FILESIZE', 'Production'); "

echo Dump Completed for $DB

done

#if backup completes then move to S3
$ was s3 cp s3://path/to/backup

# cd $BACKUP_DIR


 if [ -d $BACKUP_DIR/$FOLD_DATE ];
 then


# echo "Sales Databases Dumps Completed and Copied to Storage" | mutt -s "Sales Database BackUp" "recepient1@example.com"

echo "Sales Databases Dumps Completed and Copied to S3" | mutt -s 


echo "Backup of Sales DB Completed Successfully" | mailx -v -r "notification@example.com" -s "Sales DB Backup Status" -S smtp="10.x.x.x:25" -S smtp-auth=login -S smtp-auth-user="smtp_user@example.com" -S smtp-auth-password=$smtp_password -S ssl-verify=ignore recepient1@example.com


 else

 echo Dump Not Completed
 
echo "Error Occured : Backup of Sales DB Failed" | mailx -v -r "notification@example.com" -s "Error - Sales DB Backup Status" -S smtp="10.x.x.x:25" -S smtp-auth=login -S smtp-auth-user="smtp_user@example.com" -S smtp-auth-password=$smtp_password -S ssl-verify=ignore recepient1@example.com

 fi

# Delete files older than 15 days
find $BACKUP_DIR/* -mtime +15 -exec rm {} \;
