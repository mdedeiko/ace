FROM balenalib/raspberry-pi-debian

RUN apt update -y && apt upgrade -y

ADD engine_3.1.61_armv7.tar.gz /tmp

RUN cd /tmp/acestream.engine && \
    mv androidfs/system / && \
    mv androidfs/acestream.engine / && \
    mkdir -p /storage && \
    mkdir -p /system/etc && \
    ln -s /etc/resolv.conf /system/etc/resolv.conf && \
    ln -s /etc/hosts /system/etc/hosts && \
    chown -R root:root /system && \
    find /system -type d -exec chmod 755 {} \; && \
    find /system -type f -exec chmod 644 {} \; && \
    chmod 755 /system/bin/* /acestream.engine/python/bin/python

RUN apt-get update && apt-get install -y \
    python3.4 \
    python3-pip \
    libxslt-dev \
    lighttpd \
    lighttpd-mod-deflate && \
    cd /usr/share/lighttpd && \
    mv create-mime.conf.pl create-mime.assign.pl	
    

RUN pip install acestream-search

COPY start.sh .
RUN chmod +x start.sh
COPY etc/lighttpd/* /etc/lighttpd/
# If you want build image with custom configuration, uncomment next line
# ADD acestream.conf  /acestream.engine/

EXPOSE 8621 6878 80

VOLUME /var/www/html

VOLUME /etc/lighttpd

CMD "/system/bin/acestream.sh"
#ENTRYPOINT [ "/start.sh" ]
