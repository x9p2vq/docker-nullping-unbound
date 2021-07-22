#!/bin/sh

# set script name for loggin purposes.
me=$(basename $0)

# setup runtime environment
mkdir -p /runtime/unbound
cp -R -u /nullping/* /runtime/unbound/.

# create root anchor key
echo "$me: updating root anchor key if needed."
wget --quiet -O /runtime/unbound/icannbundle.pem https://data.iana.org/root-anchors/icannbundle.pem
/usr/sbin/unbound-anchor -4 -a /runtime/unbound/root.key -c /runtime/unbound/icannbundle.pem 

# ensure runtime permissions are correct.
chown -R unbound.unbound /runtime/unbound

echo "$me: checking unbound configuration before starting up..."
/usr/sbin/unbound-checkconf > /dev/null
status=$?

if [ $status -gt 0 ]; then
  echo "$me: unbound configuration failure reported, sleeping to keep container active for 3600s then exiting."
  sleep 3600s
  return 1
else
  echo "$me: unbound configuration looks good!"
fi


# Start Unbound
#
echo "$me: starting unbound $(/usr/sbin/unbound -V | grep Version | awk '{print tolower($0)}')..."
/usr/sbin/unbound -c /runtime/unbound/unbound.conf -d
