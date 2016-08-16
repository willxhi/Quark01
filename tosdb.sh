#!/bin/sh
# Author : William Xhinar <acc4itc@gmail.com>
# Documentation Logs
# 2016-07-27 - WmX - Create this script	/w01/script/tosdb.sh
##
_MYDIR=$(dirname $(readlink -f $0))
_MYPARENTDIR=$(dirname "$_MYDIR")
_MYNAME=`basename $0`
LOGDIR=$_MYDIR/logs/$(date +"%Y/%m/%d")
$_MYDIR/utils/wi_mkdir.sh $LOGDIR
LOGFILE=$LOGDIR/"$_MYNAME"_`date +\%Y\%m\%d\%H\%M`_wi.trc
(
#echo $_MYDIR
$_MYDIR/utils/wi_headlog.sh $LOGDIR
#date
c_begin_time_sec=`date +%s`
echo -e "*init \t $(date)"
LASTMONTHDIR=$(date +%Y/%m -d "2 month ago")
SDBDIR=/mnt/monthly/bck
POOLDIR=/w01/backup/all/$LASTMONTHDIR
SDBKVNDIR=$SDBDIR/db/55/$LASTMONTHDIR
SDBSYRDIR=$SDBDIR/db/59/$LASTMONTHDIR
SDBRECDIR=$SDBDIR/db/198/$LASTMONTHDIR
SDBIMGDIR=$SDBDIR/img/$LASTMONTHDIR
SDBACTDIR=$SDBDIR/act/$LASTMONTHDIR
SDBHRDIR=$SDBDIR/hr/$LASTMONTHDIR

$_MYDIR/utils/wi_headlog.sh $BCKDIR'55/'$THISMONTH

rsync -avhPpW -stats $POOLDIR/KVN/ $SDBKVNDIR
rsync -avhPpW -stats $POOLDIR/SYR/ $SDBSYRDIR
rsync -avhPpW -stats $POOLDIR/REC/ $SDBRECDIR
rsync -avhPpW -stats $POOLDIR/IMG/ $SDBIMGDIR
rsync -avhPpW -stats $POOLDIR/ACT/ $SDBACTDIR
rsync -avhPpW -stats $POOLDIR/HR/  $SDBHRDIR

echo -e "*finish \t $(date)"
c_end_time_sec=`date +%s`
v_total_execution_time_sec=`expr ${c_end_time_sec} - ${c_begin_time_sec}`
echo "Script execution time is $v_total_execution_time_sec seconds / "$(date -u -d @$v_total_execution_time_sec +%H:%M:%S)
) | tee $LOGFILE
