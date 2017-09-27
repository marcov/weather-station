#!/bin/sh

if which phantomjs
then 
    phantomjs_bin=phantomjs
else
    phantomjs_bin=/home/pi/bin/phantomjs-2.0.1-development-linux-armv6l/bin/phantomjs
fi

${phantomjs_bin} takeshot.js \
    http://www.metradar.ch/2009/pc/index_mobile15.php \
    10000 \
    /var/lib/wview/img/radar_ch.png \
    1024x1024 \
    500x150x710x680 || exit $?

${phantomjs_bin} takeshot.js \
    http://cml.to/radar \
    30000 \
    /var/lib/wview/img/radar_lom.png \
    1024x800 \
    0x20x960x800
