#!/bin/sh
#from /opt/VM_Storage/Image/TEMPLATE/data.img change all image
DATAIMG="/opt/VM_Storage/Image/TEMPLATE/data.img"
ls -v TEMPLATE /opt/VM_Storage/Image/ > /tmp/VM_Dataimage_dir.txt
filename='/tmp/VM_Dataimage_dir.txt'
exec < $filename
while read line
do
    ls /opt/VM_Storage/Image/$line | while read -r filename ; do \cp -f $DATAIMG /tmp/opt/VM_Storage/Image/$line/$filename; done
    #ls /opt/VM_Storage/Image/$line | while read -r filename ; do /bin/cp  $DATAIMG /tmp/opt/VM_Storage/Image/$line/$filename; done
done
rm -rf /tmp/VM_Dataimage_*.txt

