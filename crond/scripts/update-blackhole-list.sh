#!/bin/sh

# set script name for loggin purposes.
me=$(basename $0)

# blackhole list file
file="/runtime/unbound/conf.d/blackhole.conf"

# backup existing blackhole list
if [ -f $file ]; then
  cp $file /tmp/blackhole.conf.bak
fi

# get block lists and append to a master list (if concatenating more than 1 list, do it here)
echo "$me: downloading public blocklists."
wget --quiet -O /tmp/blocklist https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts

# post processing or blocklist 
echo "$me: filter, merge, sort, and removing duplicates from blocklist"
cat /tmp/blocklist | grep '^0\.0\.0\.0' | awk '{print $2}' | sort | uniq > /tmp/blocklist-filtered

echo "$me: formatting blocklist for local-zone redirect."
cat /tmp/blocklist-filtered | awk '{ print "local-zone: \""$1"\" always_null"}' > $file

# clean-up and correct ownership/permissions
echo "$me: cleaning up temporary files."
rm /tmp/blocklist
rm /tmp/blocklist-filtered
chown unbound.unbound $file
chmod 644 $file

echo "$me: blackhole list has been updated, checking unbound config..."
/usr/sbin/unbound-checkconf > /dev/null
status=$?

if [ $status -gt 0 ]; then
  echo "$me: unbound configuration failure reported, reverting changes."
  mv /tmp/blackhole.conf.bak $file 
  return 1
fi

echo "$me: reloading unbound configuration in 60 seconds."
sleep 60s
response=$(/usr/sbin/unbound-control -c /runtime/unbound/unbound.conf -s 172.102.0.2@8953 reload)

if [ "$response" == "ok" ]
then
  echo "$me: unbound-control reloaded successfully." 
else
  echo "$me: unbound-control error encountered."
  echo $response
fi
