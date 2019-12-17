#!/bin/bash

LIST=$(mysql -u$USER -p$PWD $HOST -e "select user_id from pairs where role_id=3;" | grep -v user > /tmp/A )
DATES=$(date '+%Y%m%d')
DATEE=$(date --date='8 days ago' "+%Y%m%d")

filename="/tmp/A"
exec < $filename

while read line
do
   NAME=$(mysql -u$USER -p$PWD $HOST -e "select user_name from users where user_id=$line;" | grep -v user_name)
   TIMES=$(mysql -u$USER -p$PWD $HOST -e "select count(*) from userLogs where level='info' and action='login' and action_time> 'between current_date()-7 and sysdate()' and user_id=$line;" | grep -v count)
   echo "NAME=$NAME  TIMES=$TIMES" >> /tmp/B
done
sort -r -n  -t, -k2 /tmp/B > /LogFile-$(date '+%Y%m%d').csv
rm -f /tmp/B
sed -i "1iuser logins per week" /LogFile-$(date '+%Y%m%d').csv
sed -i "2iHostName:'$(hostname)'" /LogFile-$(date '+%Y%m%d').csv
sed -i "3iDate range:$DATEE <-> $DATES"  /LogFile-$(date '+%Y%m%d').csv
sed -i "4iAccount,Count" /LogFile-$(date '+%Y%m%d').csv
