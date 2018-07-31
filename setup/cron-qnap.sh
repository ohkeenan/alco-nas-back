#!/bin/bash

vim /etc/config/crontab

crontab /etc/config/crontab && /etc/init.d/crond.sh restart
