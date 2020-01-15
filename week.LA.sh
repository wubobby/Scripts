#!/bin/bash

ENDTIME=$(date +%s)
STARTTIME=$(date -d "-7 day" +%s)
PNGPATH=/root/librenmsReport/
#PNGDATE=now
PNG_NAME="LoadAverages"
PNGDATE=$(date "+%Y%m%d")
SERVERIP=$(awk 'BEGIN {FS="@"}; {print $1$3$2}' /root/librenmsReport/LIST)
FILE="/tmp/generator_graphic.sh"
DIR="/opt/librenms/rrd"
count=0
mkdir $PNGPATH/$PNGDATE
    for i in $SERVERIP
	do
	j=$(echo "$i" | cut -d"/" -f 1)
	echo "#!/bin/bash" > $FILE
    	echo -n "rrdtool graph $PNGPATH/$PNGDATE/$PNGDATE-$j-${PNG_NAME}.png  -l 0 -E --start $STARTTIME --end $ENDTIME --width 1512 --height 300 -c BACK\#EEEEEEFF -c SHADEA#EEEEEE00 -c SHADEB#EEEEEE00 -c FONT#000000 -c CANVAS#FFFFFF00 -c GRID#a5a5a5 -c MGRID#FF9999 -c FRAME#5e5e5e -c ARROW#5e5e5e -R normal -c FONT#000000 --font LEGEND:8:DejaVuSansMono --font AXIS:7:DejaVuSansMono --font-render-mode normal " >> $FILE
    	echo -n "DEF:1min=$DIR/$j/ucd_load.rrd:1min:AVERAGE " >> $FILE
	echo -n "DEF:5min=$DIR/$j/ucd_load.rrd:5min:AVERAGE " >> $FILE
	echo -n "DEF:15min=$DIR/$j/ucd_load.rrd:15min:AVERAGE " >> $FILE
	echo -n "CDEF:a=1min,100,/ CDEF:b=5min,100,/ CDEF:c=15min,100,/ CDEF:cdefd=a,b,c,+,+ COMMENT:'Load Average  Current    Average    Maximum\n' AREA:a#ffeeaa:'1 Min' LINE1:a#c5aa00: GPRINT:a:LAST:'    %7.2lf' GPRINT:a:AVERAGE:'  %7.2lf' GPRINT:a:MAX:'  %7.2lf\n' LINE1.25:b#ea8f00:'5 Min' GPRINT:b:LAST:'    %7.2lf' GPRINT:b:AVERAGE:'  %7.2lf' GPRINT:b:MAX:'  %7.2lf\n' LINE1.25:c#cc0000:'15 Min' GPRINT:c:LAST:'   %7.2lf' GPRINT:c:AVERAGE:'  %7.2lf' GPRINT:c:MAX:'  %7.2lf\n' " >> $FILE
   	chmod +x $FILE
   	bash $FILE
done
#chmod +x $FILE
#bash $FILE

