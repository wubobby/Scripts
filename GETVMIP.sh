#!/bin/bash
#====將DHCP SERVER IP 與金鑰複製到本機====
DHCPSERVERKEY=''
DHCPIP=
echo "$DHCPIP ecdsa-sha2-nistp256 $DHCPSERVERKEY" >> ~/.ssh/known_hosts

#====取得主機名稱,網卡,MAC====

hostname > hostname.txt
HOSTNAME=$(cat hostname.txt)
NETCARD=$(ip a |grep "state UP" |awk '{print $2}'|cut -d':' -f 1 )
MACADDR=$(ifconfig $NETCARD |grep ether  |awk '{print $2}')
IPADDR=$(ifconfig $NETCARD |grep  inet |awk '{print $2}'|sed  '$d')
echo "host $HOSTNAME {
                 hardware ethernet $MACADDR; 
                   fixed-address $IPADDR;
                   }" > ~/LOCALGETIP$IPADDR.txt

#====將產生的文字檔傳至DHCP SERVER====

scp  ~/LOCALGETIP$IPADDR.txt $DHCPIP:/root/
ssh $DHCPIP "cat /root/LOCALGETIP$IPADDR.txt >> /root/dhcpd.txt"
ssh $DHCPIP "rm -f /root/LOCALGETIP$IPADDR.txt"
rm -f /root/LOCALGETIP$IPADDR.txt


#====比對主機名稱,如果主機名稱是帶有KVM套件,則將br0設定為該網卡橋接====

if [ $HOSTNAME = "" ];
then
        echo BRIDGE="br0" >> /etc/sysconfig/network-scripts/ifcfg-$NETCARD
        ifdown $NETCARD
        ifdown br0
        ifup $NETCARD
        ifup br0
        rm -f  hostname.txt
        rm -f  GETVMIP.sh
else
        rm -f  hostname.txt
        rm -f  GETVMIP.sh
fi


