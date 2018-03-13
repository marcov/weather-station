#!/bin/sh
#
# pulls the webcam image from the http server
#

. ../../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

curl --max-time 10 --basic -u ${misma_webcam_login} ${misma_webcam_url}  -o ${ftp_upload_dir}/misma/${misma_pic_name}

exit $?

