FROM alpine:latest
LABEL maintainer="Jason Mitchell <jason@nullping.net>"
LABEL description="unbound dns server"

# create necessary user and group first
RUN addgroup -g 10000 -S unbound
RUN adduser -G unbound -H -D -S -u 10000 unbound

# update image and install required packages
RUN apk update && apk add unbound ca-certificates openssl wget

# update ca certs
RUN update-ca-certificates

# setup unbound directories and files
RUN mkdir -p /nullping/conf.d /nullping/remote-control-certs
COPY ./config /nullping
COPY ./entrypoint.sh /entrypoint.sh

# get root anchor bundle
RUN wget --quiet -O /nullping/icannbundle.pem https://data.iana.org/root-anchors/icannbundle.pem 

# create root anchor key
RUN /usr/sbin/unbound-anchor -4 -a /nullping/root.key -c /nullping/icannbundle.pem || echo "root anchor key installed" 

# setup remote control certs
RUN /usr/sbin/unbound-control-setup -d /nullping/remote-control-certs -r

# expose necesssary ports
EXPOSE 53/udp
EXPOSE 53/tcp
EXPOSE 853/tcp
EXPOSE 8953/tcp

# final steps and clean up
RUN rm -rf /var/cache/apk/*
RUN chown -R unbound.unbound /nullping
RUN chown unbound.unbound ./entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
