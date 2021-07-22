#!/bin/sh

# set script name for loggin purposes.
me=$(basename $0)

# setup runtime environment
mkdir -p /runtime/crond
cp -R -u /nullping/* /runtime/crond/.
chown -R unbound.unbound /runtime/crond

# set script to perform update
update_script="/runtime/crond/scripts/update-blackhole-list.sh"

# set threshold for file expired
threshold=1440

# file to check for expiry
file="/runtime/unbound/conf.d/blackhole.conf"

# get last update to file
if [ -e $file ]
then
  last_update=$(date -d "$(stat -c "%y" $file | cut -d. -f1)" '+%s')
else
  last_update=$(date -d "1999-12-31 23:59:59" '+%s')
fi

# get current date time
now=$(date '+%s')

# calculate how long since the file was updated
diff=$(((now - last_update)/60))

# determine if blocklist refresh is needed
if [ $diff -ge $threshold ]
then
  echo "$me: the blackhole list is stale ($diff minutes old)."
  $update_script
else
  echo "$me: the blackhole list was updated $diff minutes ago."
fi


# Start crond
#
#   BusyBox v1.33.1 () multi-call binary.
# 
#   Usage: crond [-fbS] [-l N] [-d N] [-L LOGFILE] [-c DIR]
#   
#      -f      Foreground
#      -b      Background (default)
#      -S      Log to syslog (default)
#      -l N    Set log level. Most verbose 0, default 8
#      -d N    Set log level, log to stderr
#      -L FILE Log to FILE
#      -c DIR  Cron dir. Default:/var/spool/cron/crontabs
#
echo "$me: starting crond..."
/usr/sbin/crond -f -S -c /etc/crontabs
