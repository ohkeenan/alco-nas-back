#!/bin/sh

case $1 in
    start)
    mkdir -p /opt
    mount -o bind /volume1/@Entware/opt /opt
    /opt/etc/init.d/rc.unslung start
    ;;
    stop)
    ;;
esac

