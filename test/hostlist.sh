#!/bin/sh
# Author : William Xhinar <acc4itc@gmail.com>
# Documentation Logs
# 2015-12-08 - WmX - Create this script
##
_MYDIR=$(dirname $(readlink -f $0))
_MYPARENTDIR=$(dirname "$_MYDIR")
_MYNAME=`basename $0`
LOGDIR=$_MYDIR/logs/$(date +"%Y/%m/%d")
$_MYDIR/utils/wi_mkdir.sh $LOGDIR
LOGFILE=$LOGDIR/"$_MYNAME"_`date +\%Y\%m\%d\%H\%M`_wi.trc
(
c_begin_time_sec=`date +%s`
echo -e "*init   \t $(date)"
#HOST_LIST="192.168.51.55 192.168.51.59 192.168.51.191 192.168.51.215"
HOST_LIST="192.168.51.55_22 192.168.51.59_22 192.168.51.191_22 192.168.51.215_1309"

df -Ph|grep -E '^[^/]*$|[4-9][0-9]%'|sed 's/^/'$HOSTNAME'  /'|sed '1 s/'$HOSTNAME'/Host/g'|awk '{printf "%15s%35s%5s%5s%6s%5s%15s\n",  $1,$2,$3,$4,$5,$6,$7}'

for host in $HOST_LIST
do
  ssh ${host%%_*} -p ${host##*_} -n "df -Ph|grep '[4-9][0-9]%'|sed 's/^/${host%%_*}  /'"|awk '{printf "%15s%35s%5s%5s%6s%5s%15s\n",$1,$2,$3,$4,$5,$6,$7}'
done
echo -e "*finish \t $(date)"
c_end_time_sec=`date +%s`
v_total_execution_time_sec=`expr ${c_end_time_sec} - ${c_begin_time_sec}`
echo "Script execution time is $v_total_execution_time_sec seconds / "$(date -u -d @$v_total_execution_time_sec +%H:%M:%S)
) | tee $LOGFILE


for host in $HOST_LIST; do
  #echo $host
  #echo ${host%%_*}
  #echo ${host##*_}
  echo "ip: "${host%%_*}" port: "${host##*_}
done

