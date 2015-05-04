#!/bin/sh
#

. ./common_variables.sh

webcam_watermark_text="Fiobbio di Albino, `date +\"%d-%m-%Y  %T (%Z)\"`"

#
#
#
convert -pointsize 16 \
        -fill white \
        -undercolor black \
        -gravity northwest \
        -draw "$webcam_watermark_text" \
        ${wview_html_dir}/${wview_webcam_px_nowm_name} \
        ${wview_html_dir}/${wview_webcam_px_name} 

