# Dockerfile to build dump1090:alpine image
#
# A stand alone dump1090 which reads ADS-B signals from an RTL-D USB stick.
# nginx provides a web display of planes on a map.
# This project is set up to work with piaware but there is no advantage
# in size or performance by running split, so I usually combine
# everything into one image.
#
# D.G. Adams 2024-Sep-13

FROM debian:bookworm-slim  AS builder

RUN <<EOF
    apt-get -yq update
    apt-get -yq install \
        build-essential \
        debhelper \
        fakeroot \
        git \
        libncurses-dev \
        librtlsdr-dev \
        pkg-config 
    git clone https://github.com/flightaware/dump1090.git /dump1090
    cd /dump1090
    dpkg-buildpackage -b --no-sign --build-profiles=custom,rtlsdr 
EOF
#####################################################################

FROM alpine AS install
#FROM rtlsdr4:alpine AS install 

WORKDIR /dump1090

COPY --from=builder /dump1090/dump1090 /usr/bin/dump1090
COPY --from=builder /dump1090/public_html/ /dump1090/public_html/
COPY files/* ./
COPY libs/* /lib/

RUN <<EOF
    apk add --no-cache nginx rtl-sdr gcompat bash
    adduser -D dump1090
    adduser dump1090 dump1090
    mkdir /run/dump1090
    chown dump1090 /run/dump1090
    chmod 755 /run/dump1090
    chown -R dump1090 /var/log/nginx
    chown -R dump1090 /var/lib/nginx
    rm -rf /etc/nginx
    ln -s /lib/libncurses.so.6.4 /lib/libncurses.so.6
    ln -s /lib/libtinfo.so.6.4 /lib/libtinfo.so.6
    mkdir /run/piaware
    touch /run/piaware/status.json
    chmod 755 /run/piaware/status.json
EOF

# only port 8080 is needed if running stand alone
EXPOSE 8080 30001 30002 30003 30004 30005 30104
USER dump1090
CMD ["/dump1090/dump1090.sh"]
