#!/bin/bash

LIST=$(mysql -u$USER -p$PWD $HOST -e "select user_id from pairs where role_id=3;" | grep -v user > /tmp/A )


filename="/tmp/A"
exec < $filename

while read line
do
   NAME=$(mysql -u$USER -p$PWD $HOST -e "select user_name from users where user_id=$line;" | grep -v user_name)
   TIMES=$(mysql -u$USER -p$PWD $HOST -e "select count(*) from userLogs where level='info' and action='login' and action_time> 'between current_date()-7 and sysdate()' and user_id=$line;" | grep -v count)
   echo "NAME=$NAME  TIMES=$TIMES"
 
done



