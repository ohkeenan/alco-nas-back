#!/bin/sh

opkg update
opkg install rsync \
            rsnapshot \
            vim \
            curl \
            ca-certificates \
            screen \
            coreutils-kill \
            coreutils-nohup \
            autossh
