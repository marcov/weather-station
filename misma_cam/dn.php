#!/usr/bin/php
<?php
$lat=45.8;
$long=9.8;
date_default_timezone_set('Europe/Rome');
$uT=time();
$sun_info = date_sun_info($uT, $lat,$long);
$sunrise = $sun_info['civil_twilight_begin'];
$sunset = $sun_info['civil_twilight_end'];
$alba = $sunrise+200;
$tramonto = $sunset-200;
if ($uT>$alba && $uT<$tramonto) echo "1";
else
echo "2";
?>
