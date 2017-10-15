#!/bin/bash

dst_path=/var/lib/wview/img
#dst_path=.
params=(\
    "http://www.meteoguru.com/en/pro/ecmwf/?latlon=45.80,9.80 1000  ${dst_path}/mg_ecmwf.png  1280x1280  645x297x945x585" \
    "http://www.metradar.ch/2009/pc/index_mobile15.php 10000 ${dst_path}/radar_ch.png 1024x1024 500x150x710x680" \
    "http://www.zoomradar.ch/index.php?lon=9.866164648468462&lat=45.77935393888881 10000 ${dst_path}/radar_ch_detailed.png 1024x1024 500x150x710x680" \
    \
    "http://cml.to/radar 30000 ${dst_path}/radar_lom.png 1024x800 0x20x960x800"\
)

if which phantomjs
then 
    phantomjs_bin=phantomjs
else
    phantomjs_bin=/home/pi/bin/phantomjs-2.0.1-development-linux-armv6l/bin/phantomjs
fi

for p in "${params[@]}"
do
     ${phantomjs_bin} takeshot.js ${p} || exit $?
done 

