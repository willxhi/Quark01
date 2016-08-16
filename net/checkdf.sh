#!/bin/sh
# Author : William Xhinar <acc4itc@gmail.com>
# Documentation Logs
# 2015-12-08 - WmX - Create this script
# 2016-01-18 - WmX - Add HOST_LIST with port number
# 2016-07-14 - WmX - Add check local IP Address
##
_MYDIR=$(dirname $(readlink -f $0))
_MYPARENTDIR=$(dirname "$_MYDIR")
_MYNAME=`basename $0`
LOGDIR=$_MYDIR/log/$(date +"%Y/%m/%d")
$_MYPARENTDIR/utils/wi_mkdir.sh $LOGDIR
LOGFILE=$LOGDIR/"$_MYNAME"_`date +\%Y\%m\%d\%H\%M`_wi.trc
(
c_begin_time_sec=`date +%s`

/sbin/ifconfig eth0 &>/dev/null
if [ $? -eq 1 ]; then
  _MYIPADDR=`/sbin/ifconfig enp0s8 | grep 'inet ' | awk '{ print $2}'`
else
  _MYIPADDR=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
fi

echo -e "*init   \t $(date)" on this IP: $_MYIPADDR

HOST_LIST="192.168.0.3_22 192.168.51.9_1309 192.168.51.18_4422 192.168.51.24_1324 192.168.51.29_1308 192.168.51.55_1355 192.168.51.56_1356 192.168.51.59_1359 192.168.51.191_5191 192.168.51.198_22 192.168.51.215_1309"
arg=${1:-"4"}
[ "${1:-"4"}" -eq "0" ] && args="*" || args=""

df -Ph|grep -E '^[^/]*$|['$arg'-9][0-9]%'|sed 's/^/'$HOSTNAME'  /'|sed '1 s/'$HOSTNAME'/Host/g'|awk '{printf "%15s%35s%5s%5s%6s%5s%35s\n",$1,$2,$3,$4,$5,$6,$7}'

for host in $HOST_LIST
do
  [ "${host%%_*}" = "$_MYIPADDR" ] && continue
  printf '%106s\n' | tr ' ' -
  if [ "${host%%_*}" = "192.168.0.3" ]; then sshp="ssh venus"; else sshp=""; fi
  $sshp ssh -x ${host%%_*} -p ${host##*_} -n "df -Ph|grep '[0-9]*[$arg-9]$args[0-9]%'|sed 's/^/${host%%_*}  /'"|awk '{printf "%15s%35s%5s%5s%6s%5s%35s\n",$1,$2,$3,$4,$5,$6,$7}'
done
echo -e "*finish \t $(date)"
c_end_time_sec=`date +%s`
v_total_execution_time_sec=`expr ${c_end_time_sec} - ${c_begin_time_sec}`
echo "Script execution time is $v_total_execution_time_sec seconds / "$(date -u -d @$v_total_execution_time_sec +%H:%M:%S)
) | tee $LOGFILE
