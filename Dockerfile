# Monit docker instance.  Based off rawmind0/alpine-monit circa 201903.
#
# = Configuration: Mount persistent monit configuration directory at /opt/tools/monit/conf.d.
# = Log volume:    Optionally mount a persistent log volume on /opt/monit/log.
#
#  docker run  -v (pwd)/log:/opt/monit/log -v (pwd)/monit.d:/opt/tools/monit/conf.d \
# --publish 2812:2812 -e MONIT_ALLOW=172.0.0.0/8 \
# --name HomeMonit -d --restart=always confusedhacker/monit

# SERVICE_VOLUME -- /opt/tools
# MONIT_HOME  -- [/opt/monit] 
# MONIT_PORT  -- [2812] which port to listen on
# MONIT_ALLOW -- [localhost] which ip , 
# MONIT_ARGS  -- [-I] extra arguments 

FROM docker.io/alpine:latest
MAINTAINER Chan Wilson <docker@confusedhacker.com>

RUN apk add --update bash libressl curl fping libcap

# Compile and install monit and confd
ENV MONIT_VERSION=5.25.3 \
    MONIT_HOME=/opt/monit \
    MONIT_URL=https://mmonit.com/monit/dist \
    SERVICE_VOLUME=/opt/tools \
    PATH=$PATH:/opt/monit/bin

# Compile and install monit
RUN apk add --update gcc musl-dev make libressl-dev file zlib-dev && \
    mkdir -p /opt/src; cd /opt/src && \
    curl -sS ${MONIT_URL}/monit-${MONIT_VERSION}.tar.gz | gunzip -c - | tar -xf - && \
    cd /opt/src/monit-${MONIT_VERSION} && \
    ./configure  --prefix=${MONIT_HOME} --without-pam && \
    make && make install && \
    mkdir -p ${MONIT_HOME}/etc/conf.d ${MONIT_HOME}/log && \
    apk del gcc musl-dev make libressl-dev file zlib-dev &&\
    rm -rf /var/cache/apk/* /opt/src 
ADD root /
RUN chmod +x ${MONIT_HOME}/bin/monit-start.sh

ENTRYPOINT ["/bin/bash","-c","${MONIT_HOME}/bin/monit-start.sh"]
