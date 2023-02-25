#!/bin/bash
sh ./system/bin/acestream.sh > /dev/null 2>&1 & 

chmod a+w /dev/pts/0
exec lighttpd -D -f /etc/lighttpd/lighttpd.conf > /dev/null 2>&1 &

acestream_search --query hd --target $1:$2 > /var/www/html/ace_search.m3u

while true; do

       sleep 1800
#        rm -rf /tmp/fs/.acestream_cache/*
 #               rm -rf /tmp/fs/collected_torrent_files/*
                       acestream_search --query hd --target $1:$2 > /var/www/html/ace_search.m3u
done

