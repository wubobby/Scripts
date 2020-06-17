#!/bin/bash
LIST=`cat LIST`
for i in $LIST
do
/opt/platform-tools/adb disconnect $i &> /dev/null
     /opt/platform-tools/adb connect $i:5555 &> /dev/null
      /opt/platform-tools/adb -s $i:5555 install -g -r /home/CpuMonitor.apk
      /opt/platform-tools/adb disconnect $i &> /dev/null
done
