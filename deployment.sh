#!/bin/sh
# Create a set of symbolic links...

repoRoot=/home/pi/weather_station
wviewVar=/var/lib/wview

#TODO dont run it twice!...
exit 0

sudo chown -R pi ${wviewVar}/img

cd /var/lib/wview/img
ln -s ${repoRoot}/wview/html/fiobbio/index.html index.html
ln -s ${repoRoot}/wview/html/fiobbio/html html
ln -s ${repoRoot}/wview/html/fiobbio/css css
ln -s ${repoRoot}/wview/html/fiobbio/js js

cd /etc/
ln -s ${repoRoot}/wview/etc_wview wview

cd /etc/wview/html
ln -s ${repoRoot}/wview/html/fiobbio/html/currweather.htx currweather.htx
ln -s ${repoRoot}/wview/html/fiobbio/html/index.htx index.htx

# Note: moved wview-conf.sdb in ${wviewVar}/conf ! So it needs to be 
# linked back to /etc/wview
cd /etc/wview
ln -s ${wviewVar}/conf/wview-conf.sdb wview-conf.sdb

# Install crontab
crontab -u root ${repoRoot}/webcam/cron/crontab 
# See crontab
crontab -u root -l

cd /etc/cron.daily
cp ${repoRoot}/webcam/cron/daily webcam
chmod +x webcam

