#!/bin/sh

# set script name for loggin purposes.
me=$(basename $0)

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

echo "$me: the blackhole list was updated $diff minutes ago."
