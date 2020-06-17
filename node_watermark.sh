#!/bin/bash
#
# Author phchi
# Date : 2019-03-12
# Phone : 14502
# Descript : Node script for control node
# Sample configuration 
# Memory : 4194304 Bytes
# CPU : 2, 4, 6, 8
# Release Note :
#  0117
#    Add NFS support
#  1031
#    Add Log support
#  1005
#    Add XML file control
#    Fix undefine feature 
#  0903
#    Refactor module implement
#    Add define user data image feature
#    Add suspend and resume feature
#    Add brahma host parameter
#  0830
#    Add tenant support
#    Modify define, undefine
#    Add Redefine feature

ABSPATH=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$ABSPATH")
cd $SCRIPTPATH
A=
R=
G=
B=
FONTDPI=
MODE=
HOST_IP=
USERNAME=
IMAGE_DIR="/opt/VM_Storage/Image"
DATA_DIR="/opt/VM_Storage/DATA"
SAVE_DIR="/opt/VM_Storage/SAVE"
XML_DIR="$DATA_DIR/XML"
VMLIST="/tmp/VM_LIST.txt"
TARGET_IMAGE_DIR="/srv/VM_Storage/Image"
DEBUG_FILE="/tmp/DEBUG"
BRAHMA_LOG="/opt/VM_Storage/DATA/LOG/brahma.log"
#WaterMark=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 1)
#FONTDPI=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 2)
#WMCOLOR=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 6)
while getopts ":A:R:G:B:D:M:H:U:" opt
do
    case $opt in
        A)
        A=$OPTARG
        ;;
        R)
        R=$OPTARG
        ;;
        G)
        G=$OPTARG
        ;;
        B)
        B=$OPTARG
        ;;
        D)
        FONTDPI=$OPTARG
        ;;
        M)
        MODE=$OPTARG
        ;;
	H)
        HOST=$OPTARG
        ;;
	U)
	USERNAME=$OPTARG
        ;;
	?)
        USAGE="TRUE"
        ;;
    esac
done
function show_usage(){
  echo "
Usage: $0 [OPTION]... 

Mandatory arguments to long options are mandatory for short options too.
  -A alpha	00-FF                           
  -R red	00-FF                         
  -G green	00-FF                        
  -B Blue	00-FF       
  -D FONTDPI 60-180                      
  -M FONTDPI,WMCOLOR,BOTH,DEFINE
"
}

function MODIFY_NODEXML(){
     sed -i "s/%80%/%FONTDPI%/g" $XML_DIR/* 
     sed -i "s/%-2004318072%/%WMCOLOR%/g" $XML_DIR/*
}
     
function GETLOCALVMLIST(){
	echo $USERNAME , $HOST
        virsh -c qemu+ssh://"$USERNAME"@"$HOST"/system list --all > /tmp/a.txt
#	virsh list --all > /tmp/a.txt
	 cat /tmp/a.txt |grep node >/tmp/b.txt
	awk '{print$2}' /tmp/b.txt > /tmp/VM_LIST.txt
          exec < $VMLIST
  	while read VM_NAME
  	do
        grep  WaterMark "$XML_DIR/$VM_NAME.xml"
         if [[ "$?" == 1 ]];then
	sed -i "/$VM_NAME/d" $VMLIST
	 fi
        done
}

function SETWMCOLOR(){
ARGB=$A$R$G$B
WMCOLOR=$(($((16#$ARGB)) -4294967296))
}

function MODIFY_TMP_XML(){
    sed -i '11d' $DATA_DIR/TEMPLATE/config/template_node.xml
    sed -i "11i<cmdline>root=/dev/ram0 androidboot.selinux=permissive buildvariant=eng console=ttyS0 RAMDISK=vdb DATA=vdc -append video=720x1280 DPI=320 Brahma_Server=BRAHMA_HOST NFS=NFSSERVER:/home/VM_Storage WaterMark=WATERMARK%FONTDPI%%%%WMCOLOR%0%0%0</cmdline>" $DATA_DIR/TEMPLATE/config/template_node.xml
}

function MODIFY_NODE_FONTDPIXML(){
  exec < /tmp/VM_LIST.txt
  while read VM_NAME
  do
   echo "$XML_DIR/$VM_NAME.xml"
   WATERMARK=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 1)
   WMCOLOR=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 6)
   BRAHMA_HOST=$(grep Brahma_Server $XML_DIR/$VM_NAME.xml|awk '{print$10}'|cut -d = -f2)
   NFSSERVER=$(grep nfs $XML_DIR/$VM_NAME.xml|awk '{print$11}'|cut -d = -f2|cut -d : -f1)
   echo "$VM_NAME WATERMARK=$WATERMARK,FONTDPI=$FONTDPI,WMCOLOR=$WMCOLOR"
   sed -i '11d' $XML_DIR/$VM_NAME.xml
   sed -i "11i<cmdline>root=/dev/ram0 androidboot.selinux=permissive buildvariant=eng console=ttyS0 RAMDISK=vdb DATA=vdc -append video=720x1280 DPI=320 Brahma_Server=BRAHMA_HOST NFS=NFSSERVER:/home/VM_Storage WaterMark=WATERMARK%FONTDPI%%%%WMCOLOR%0%0%0</cmdline>" $XML_DIR/$VM_NAME.xml
   sed -i "s/WATERMARK/$WATERMARK/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/BRAHMA_HOST/$BRAHMA_HOST/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/NFSSERVER/$NFSSERVER/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/FONTDPI/$FONTDPI/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/WMCOLOR/$WMCOLOR/g" $XML_DIR/$VM_NAME.xml
  done
}

function MODIFY_NODE_WMCOLORXML(){
  exec < /tmp/VM_LIST.txt
  while read VM_NAME
  do
    WATERMARK=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 1)
    FONTDPI=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 2)
    BRAHMA_HOST=$(grep Brahma_Server $XML_DIR/$VM_NAME.xml|awk '{print$10}'|cut -d = -f2)
    NFSSERVER=$(grep nfs $XML_DIR/$VM_NAME.xml|awk '{print$11}'|cut -d = -f2|cut -d : -f1)
    echo "$VM_NAME WATERMARK=$WATERMARK,FONTDPI=$FONTDPI,WMCOLOR=$WMCOLOR"
    sed -i '11d' $XML_DIR/$VM_NAME.xml
    sed -i "11i<cmdline>root=/dev/ram0 androidboot.selinux=permissive buildvariant=eng console=ttyS0 RAMDISK=vdb DATA=vdc -append video=720x1280 DPI=320 Brahma_Server=BRAHMA_HOST NFS=NFSSERVER:/home/VM_Storage WaterMark=WATERMARK%FONTDPI%%%%WMCOLOR%0%0%0</cmdline>" $XML_DIR/$VM_NAME.xml
   sed -i "s/WATERMARK/$WATERMARK/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/BRAHMA_HOST/$BRAHMA_HOST/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/NFSSERVER/$NFSSERVER/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/FONTDPI/$FONTDPI/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/WMCOLOR/$WMCOLOR/g" $XML_DIR/$VM_NAME.xml
  done
}

function MODIFY_NODE_WMFONTXML(){
  exec < /tmp/VM_LIST.txt
  while read VM_NAME
  do
   echo "$XML_DIR/$VM_NAME.xml"
   WATERMARK=$(grep cmdline $XML_DIR/$VM_NAME.xml |awk '{print$12}'|awk -F = '{print$2}'|cut -d % -f 1)
   BRAHMA_HOST=$(grep Brahma_Server $XML_DIR/$VM_NAME.xml|awk '{print$10}'|cut -d = -f2)
   NFSSERVER=$(grep nfs $XML_DIR/$VM_NAME.xml|awk '{print$11}'|cut -d = -f2|cut -d : -f1)
   echo "$VM_NAME WATERMARK=$WATERMARK,FONTDPI=$FONTDPI,WMCOLOR=$WMCOLOR"
   sed -i '11d' $XML_DIR/$VM_NAME.xml
   sed -i "11i<cmdline>root=/dev/ram0 androidboot.selinux=permissive buildvariant=eng console=ttyS0 RAMDISK=vdb DATA=vdc -append video=720x1280 DPI=320 Brahma_Server=BRAHMA_HOST NFS=NFSSERVER:/home/VM_Storage WaterMark=WATERMARK%FONTDPI%%%%WMCOLOR%0%0%0</cmdline>" $XML_DIR/$VM_NAME.xml
   sed -i "s/WATERMARK/$WATERMARK/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/BRAHMA_HOST/$BRAHMA_HOST/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/NFSSERVER/$NFSSERVER/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/FONTDPI/$FONTDPI/g" $XML_DIR/$VM_NAME.xml
   sed -i "s/WMCOLOR/$WMCOLOR/g" $XML_DIR/$VM_NAME.xml
  done
}
function BACKUP_NODE_XML(){
echo "$XML_DIR"
cp -r "$XML_DIR" "$XML_DIR-$(date +'%Y-%m-%d-%H-%M')"
}


function DEFINEXML(){
  GETLOCALVMLIST
  exec < /tmp/VM_LIST.txt
  while read VM_NAME
  do
    echo "define xml $VM_NAME"
    virsh define $XML_DIR/$VM_NAME.xml
  done
}
function MODIFY_NODE_FONTDPI(){
  BACKUP_NODE_XML
  GETLOCALVMLIST
  MODIFY_NODE_FONTDPIXML
  DEFINEXML
}
function MODIFY_NODE_WMCOLOR(){
  BACKUP_NODE_XML
  GETLOCALVMLIST
  SETWMCOLOR
  MODIFY_NODE_WMCOLORXML
  DEFINEXML
}
function MODIFY_NODE_BOTH(){
  BACKUP_NODE_XML
  GETLOCALVMLIST
  SETWMCOLOR
  MODIFY_NODE_WMFONTXML
  DEFINEXML
}
function Check_action() {

  case $MODE in
    FONTDPI) MODIFY_NODE_FONTDPI;;
    WMCOLOR) MODIFY_NODE_WMCOLOR;;
    BOTH) MODIFY_NODE_BOTH;;
    DEFINE) DEFINEXML;;
  esac

}


#============EXEC=========================
#GETLOCALVMLIST
#SETWMCOLOR
#Check_action
GETLOCALVMLIST
#BACKUP_NODE_XML
#DEFINEXML

#A=$2
#R=$3
#G=$4
#B=$5
#ARGB=$A$R$G$B
#WMCOLOR=$(($((16#$ARGB)) -4294967296))
#if [[ -z "$2" ]]; then
#  WMCOLOR="-2004318072"
#  echo "color-A is null,ARGB by default" 
#fi
#if [[ -z "$3" ]]; then
#  WMCOLOR="-2004318072"
#  echo "color-R is null,ARGB by default" 
#fi
#if [[ -z "$4" ]]; then
#  WMCOLOR="-2004318072"
#  echo "color-G is null,ARGB by default" 
#fi
#if [[ -z "$5" ]]; then
#  WMCOLOR="-2004318072"
#  echo "color-B is null,ARGB by default" 
#fi
#
#if [ "$1" -gt 0 ] 2>/dev/null ;then 
#  echo "Font DPI = $1" 
#else
#  echo "Font DPI must be a number"  
#  exit 1
#fi 
#if [[ -z "$1" ]]; then
#  FONTDPI="80"
#fi
#
#if [[ "$1" -lt 60 ]]; then
#  echo "Font DPI  Recommended range 60-150"
#  echo "Script exit!" 
#  exit 1
#fi
#
#if [[ "$1" -gt 150 ]]; then
#echo "Font DPI  Recommended range 60-150"
#echo "script exit!"
#  exit
#fi
#
#mkdir /tmp/VM_XML
#exec < $VMLIST
#while read VM_NAME
#do
#
#    echo "dump xml $VM_NAME "
#	virsh dumpxml $VM_NAME > /tmp/VM_XML/$VM_NAME.xml
#    echo "modify $VM_NAME water mark font dpi= $FONTDPI ARGB=$ARGB "
#	sed -i "s/%80%/%"$FONTDPI"%/g" /tmp/VM_XML/$VM_NAME.xml
#	sed -i "s/%-2004318072%/%"$WMCOLOR"%/g" /tmp/VM_XML/$VM_NAME.xml
#done
#
