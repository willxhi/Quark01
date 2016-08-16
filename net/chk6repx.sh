#!/bin/sh
# Author : William Xhinar <acc4itc@gmail.com>
# Documentation Logs
# 2016-08-03 - WmX - Create this script
##
_MYNAME=`basename "$0"`
_MYDIR=$(dirname $(readlink -f $0))
_MYPARENTDIR=$(dirname "$_MYDIR")
LOGDIR=$_MYDIR/log/$(date +"%Y%m")
$_MYPARENTDIR/utils/wi_mkdir.sh $LOGDIR "$2"

for ip in {193..194}; do
  baseurl='http://192.168.51.'"$ip"':8888/reports/rwservlet/'
  if [ "$ip" = 194 ]; then
    repsvrname="gamma64"
  elif [ "$1" = 193 ]; then
    repsvrname="delta64"
  fi
  httpurl="$baseurl"'showjobs?server=rptsvr_'"$repsvrname"'_fr_inst&queuetype=current'
  echo $httpurl
  #check how many job
  curl -s $httpurl > tokill.html
  cntjob=`cat tokill.html | awk 'NR > 1 {print $1}' RS='<OPTION startrow=1&amp;size=5  selected>' FS='</OPTION>' | awk '{print $5}'` 
  if [[ -z "$cntjob" ]]; then cntjob=0; fi
  infojob="$ip"' : total job = '"$cntjob"
  echo $infojob
  curl -s $httpurl | awk '/(OraTableCellText|OraTableCellTextBand)/,/\/TR/' > csv.html
  
  #replace or remove unwanted character(s)
  sed -i '/style=\"/d' csv.html
  sed -i -e 's/ class=OraTableCellText\(Band\|\)/>/g' csv.html
  sed -i -e 's/ class=OraInstructionText//g' csv.html
  sed -i -e 's/^<SPAN[^>]*>\|<\/\?SPAN[^>]*>$//Ig' csv.html
  #remove any Whitespace at the beginning of the line
  sed -i -e 's/^[\ \t]*//g' csv.html
  #remove linefeed
  sed -i -e ':a;N;$!ba;s/\n//g' csv.html
  #replace </TR><TR> with newline
  sed -i -e 's/<\/TR><TR>/\n/g' csv.html
  #remove every thing behind "table cell"
  sed -i -e 's/table cell.*//g' csv.html
  #remove unwanted line contain "CELL_VALUE"
  sed -i '/CELL_VALUE/d' csv.html
  #remove html tag "A HREF" & "img"
  sed -i -e 's/\(<A HREF="\|"><img src.*<\/A>\)//g' csv.html
  #replace with ";"
  sed -i -e 's/<\/TD[^>]*><TD[^>]*>/;/Ig' csv.html
  sed -i -e 's/^<TD[^>]*>\|<\/\?TD[^>]*>$/;/Ig' csv.html
  sed -i -e 's/; /;/g' csv.html
  
  cntline=0
  while read p; do
    d0=`echo "$p" | awk '{split($0,a,";"); print a[11]}'`
    #check is valid date 
    date "+%d/%m/%Y" -d "$d0" > /dev/null  2>&1
    is_valid_date=$?
    if [ "$is_valid_date" = 1 ]; then break; fi
    #continue if date is valid
    d1=$(date -d "$d0" +%s)
    d2=$(date +%s)
    d3=$(( (d2 - d1) / 60 ))
    d4=$(( (d2 - d1) / 360 ))
    d5=$(( (d2 - d1) / 1440))
    d6=$(( (d2 - d1) / 8640 ))
    #echo 'd0>'$d0' | d1>'$d1' | d2>'$(date)' - '$d2' | d3>'$d3' | d4>'$d4' | d5>'$d5' | d6>'
    if [ "$d3" > 300 ]; then
      jobid=`echo "$p" | awk '{split($0,a,";"); print a[2]}'`
      echo "$p" | awk '{split($0,a,";"); print a[2], a[5], a[10]}' | while read var1 var2 var3; 
      do
        kill300url="$baseurl"'killjobid'"$var1"'?server='"$var3"'&jobname='"$var2"'&queuetype=current'
        #remark dulu sementara masih popup saja
        #echo $kill300url
        #wget $kill300url 2>/dev/null &
      done
    fi

    #if cntjob less than $maxjob then do not continue
    maxjob=5
    echo $maxjob
    if [ "$cntjob" -lt "$maxjob" ]; then 
  		break;
  	else
  		ALLDOWN=$infojob
  	fi
  
    echo "$cntjob"'/'"$cntline"' '"$p"
    if [ $cntline -le $cntjob ]; then
      if [ $cntline -gt $((cntjob-2)) ]; then
        echo "$p" | awk '{split($0,a,";"); print a[2], a[5], a[10]}' | while read var1 var2 var3;
        do
          echo 'var1='$var1;
          kill2url="$baseurl"'killjobid'"$var1"'?server='"$var3"'&jobname='"$var2"'&queuetype=current'
          #remark dulu sementara masih popup saja
          #echo $kill2url
          #wget $kill2url 2>/dev/null &
        done
      fi
      ((cntline++))
    fi
  done < csv.html
done

if ! [ -z "$ALLDOWN" ]; then
  echo $ALLDOWN
  echo -e ${1#*_}${_MYNAME%.*}"\t"$(date)"\t#"$ALLDOWN >> $LOGDIR$(date +"/%d.%H")
else
  echo "$2""All OK"
fi

# "$1" = "desktop" then use notify on desktop
#if [ -n "$1" ] && [ "$1" = "desktop" ] ; then
if [ -n "$1" ] && [ "${1%_*}" = "desktop" ] ; then
  export DISPLAY=:0.0
  export $(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -o i3)/environ )

  if ! [ -z "$ALLDOWN" ]; then 
    notify-send -t 1000 --icon=dialog-warning "$2" "$ALLDOWN"
  else
    notify-send -t 1000 --icon=dialog-information "$2" "All OK"
  fi
fi

#send mail if down
if [ -n "$ALLDOWN" ]; then $_MYDIR/sendmail ${1#*_}${_MYNAME%.*}; fi
