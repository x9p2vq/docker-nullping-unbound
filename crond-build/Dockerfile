FROM alpine:latest
LABEL maintainer="Jason Mitchell <jason@nullping.net>"
LABEL description="crond scheduling"

# create necessary user and group first
RUN addgroup -g 10000 -S unbound
RUN adduser -G unbound -H -D -S -u 10000 unbound

# install updates and required packages
RUN apk update && apk add unbound wget

# setup unbound-crond directories and files 
RUN mkdir -p /nullping
COPY ./scripts /nullping/scripts
COPY ./entrypoint.sh /entrypoint.sh
COPY ./crontab /etc/crontabs/root

# clean up
RUN rm -rf /var/cache/apk/*
RUN chown -R unbound.unbound /nullping

ENTRYPOINT ["/entrypoint.sh"]

