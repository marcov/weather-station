#!/bin/sh
#

. ../common_variables.sh

for pix in ${wview_webcam_px_nowm_name} ${misma_webcam_px_nowm_name}
do
	pix_wm=$(echo $pix | sed "s/_nowm//g")
	pix_small=$(echo $pix_wm | sed "s/\.jpg/_small.jpg/g")

	if [ "${pix}" == "${misma_webcam_px_nowm_name}" ] 
	then
		webcam_watermark_text="Fiobbio di Albino"
	else
		webcam_watermark_text="Monte Misma (Fiobbio)"
	fi

	webcam_watermark_text="${webcam_watermark_text}, `date +\"%d-%m-%Y  %T (%Z)\"`"
	
	echo "Start pix is: $pix"
	echo "  With watermark: ${pix_wm}"
	echo "  Resized: ${pix_small}"
	echo "  Watermark: ${webcam_watermark_text}"
	#
	#
	#
	echo "Adding watermark..."

	convert -pointsize 16 \
		-fill white \
		-undercolor black \
		-gravity northwest \
		-draw "text 0,0 \"${webcam_watermark_text}\"" \
		${wview_html_dir}/${pix} \
		${wview_html_dir}/${pix_wm}  || exit $?
	echo "Done"

	echo "Creating resized image for faster loading..."

	convert ${wview_html_dir}/${pix_wm}    \
	 	-resize 800x600                \
		${wview_html_dir}/${pix_small}
	echo "Done"
done

exit 0

