#!/bin/bash
# bobby
# 2020-06-17
# 
#mysql -uroot brahma_overseer -e "sql <  '"$(date --date='6 month ago' "+%Y-%m-%d")"';"
mysql -uroot brahma_overseer -e "delete from nodePerformances where createdAt < '"$(date --date='8 days ago' "+%Y-%m-%d")"';"
mysql -uroot brahma_overseer -e "delete from userPerformances where createdAt < '"$(date --date='8 days ago' "+%Y-%m-%d")"';"
mysql -uroot brahma_overseer -e "delete from userLogs where action_time < '"$(date --date='6 month ago' "+%Y-%m-%d")"';"
mysql -uroot brahma_overseer -e "delete from nodeLogs where createdAt <  '"$(date --date='6 month ago' "+%Y-%m-%d")"';"
mysql -uroot brahma_overseer -e "delete from chatmsgs where createdAt <  '"$(date --date='6 month ago' "+%Y-%m-%d")"';"
mysql -uroot brahma_overseer -e "delete from notifications where createdAt <  '"$(date --date='6 month ago' "+%Y-%m-%d")"';"
mysql -uroot brahma_overseer -e "delete from eLogs where createdAt <  '"$(date --date="6 month ago" "+%Y-%m-%d")"';"
#echo $(date) >> /root/clean_log_mysql.log

