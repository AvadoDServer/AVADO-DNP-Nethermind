#!/bin/sh
while true; do
    date > /tmp/reload-certs.txt

    #wait a bit before loading the certificates
    sleep 15

    echo "Check for updated certificates"

    md5sumbefore=$(md5sum "/etc/nginx/certs/my.ava.do.crt")
    wget -q -O /etc/nginx/certs/my.ava.do.crt "http://dappmanager.my.ava.do/my.ava.do.crt"
    wget -q -O /etc/nginx/certs/my.ava.do.key "http://dappmanager.my.ava.do/my.ava.do.key"
    md5sumafter=$(md5sum "/etc/nginx/certs/my.ava.do.crt")

    if [ "$md5sumbefore" != "$md5sumafter" ]; then
        if [ -e /var/run/nginx.pid ]; then # in this image the pid is in /var/run/nginx.pid
            echo "Reload nginx"
            nginx -s reload
        fi
    fi

    #sleep one day
    sleep 86400
done
