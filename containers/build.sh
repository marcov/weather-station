#!/bin/bash
#
#
set -euo pipefail

#declare -r rsyslogImage="rsyslog:wview"
declare -r wviewImage="wview:5.21.7"
declare -r nginxImage="docker.io/library/nginx:latest"
declare -r podName="wview-pod"
declare -r wviewImgVolume="wview-img"
declare -r ctrEngine="podman"

build_images() {
	#${ctrEngine} build -t "${rsyslogImage}" -f Dockerfile.rsyslog .
	${ctrEngine} build -t "${wviewImage}" -f Dockerfile.wview .
}

build_pod() {
	echo "Delete old pod"
	${ctrEngine} pod rm \
		-i -f "${podName}"

	echo "Pod create"
	${ctrEngine} pod create \
		--publish 8000:80 \
		--name="${podName}"

	echo "Rm old volume"
	${ctrEngine} volume rm \
		-f  \
		"${wviewImgVolume}" || echo "Volume ${wviewImgVolume} not found"

	echo "Create volume"
	${ctrEngine} volume create \
		"${wviewImgVolume}"

	echo "Provision volume"
	${ctrEngine} run \
		--rm \
		-t \
		--volume "${wviewImgVolume}":/mnt \
		"${wviewImage}" \
		find /usr/local/var/wview/img/ -mindepth 1 -exec cp -a '{}' '/mnt/' ';'

	#echo "Create rsyslog container"
	#${ctrEngine} create \
	#	--name=rsyslog \
	#	--pod="${podName}" \
	#	--volume /dev \
	#	"${rsyslogImage}" \
	#	/usr/sbin/rsyslogd -n

	echo "Create wview container"
	#--volumes-from "rsyslog"
	${ctrEngine} create \
		--name=wview  \
		--pod="${podName}" \
		--volume $PWD/wview-conf.sdb:/usr/local/etc/wview/wview-conf.sdb \
		--volume $PWD/wview-archive:/usr/local/var/wview/archive \
		--volume "${wviewImgVolume}":/usr/local/var/wview/img \
		"${wviewImage}" \
		/bin/sh -c "/etc/init.d/rsyslog restart \
					&& /etc/init.d/wview restart \
					&& tail -f /var/log/syslog"

	echo "Create nginx container"
	${ctrEngine} create \
		--name=nginx \
		--pod="${podName}" \
		--volume "${wviewImgVolume}":/usr/share/nginx/html \
		"${nginxImage}"
}

usage() {
	printf "
Usage   : %s COMMAND

Commands:
    images :   Build container images
    pod    :   Create and start the pod

" $0
	exit 2
}

[ $# -gt 0 ] || usage

while [ $# -gt 0 ]
do
	case $1 in
		images)
			echo "INFO: building images"
			build_images
			;;
		pod)
			echo "INFO: building pod"
			build_pod
			echo "INFO: starting pod"
			#${ctrEngine} pod start wview-pod
			;;
		*)
			usage
			;;
	esac
	shift
done
