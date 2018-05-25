#!/bin/bash
# build a new container in current directory, using host mysql and apache UID and GUID
docker build -t docked_lamp --build-arg mysql_gid=`cut -d: -f3 < <(getent group mysql)` --build-arg mysql_uid=`id -u mysql` --build-arg apache_gid=`cut -d: -f3 < <(getent group www-data)` --build-arg apache_uid=`id -u www-data` .