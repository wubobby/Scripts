#!/bin/bash
#將db資訊先寫入/etc/.my.cnf
##vim /etc/.my.cnf
#host =
#port = 
#user = 
#password =


REMOTESERVER=
REMOTEPATH=
LOCALPATH=
ssh $REMOTESERVER "mysqldump --defaults-file=/etc/.my.cnf --all-databases > $REMOTEPATH/Backup-$(date '+%Y%m%d').sql"
ssh $REMOTESERVER "tar -cvf $REMOTEPATH/WordpressHtml-$(date '+%Y%m%d').tar /var/www/html"
ssh $REMOTESERVER  "tar -cvf $REMOTEPATH/apache2-$(date '+%Y%m%d').tar /etc/apache2"
ssh $REMOTESERVER "rm -f $REMOTEPATH/*-$(date --date='8 days ago' "+%Y%m%d").*"
scp $REMOTESERVER:$REMOTEPATH/*-$(date '+%Y%m%d').* $LOCALPATH
rm -f $LOCALPATH/*-$(date --date='8 days ago' "+%Y%m%d").*
