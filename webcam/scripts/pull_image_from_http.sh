#!/bin/sh
#
# pulls the webcam image from the http server
#

. ../../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

curl --max-time 10 --basic -u ${misma_webcam_login} ${misma_webcam_url}  -o ${misma_ftp_upload_dir}/${_file_pattern}

exit $?

