#!/bin/bash
#
#
set -euo pipefail

declare -r wviewImage="pullme/wview:5.21.7"
declare -r nginxImage="docker.io/library/nginx:latest"
declare -r podName="wview-pod"
declare -r wviewImgVolume="wview-img"
declare -r ctrEngine="${CONTAINER_ENGINE:-podman}"

build_images() {
	${ctrEngine} build -t "${wviewImage}" -f Dockerfile.wview .
}

build_pod() {
	echo "Delete old pod"
	podman pod rm \
		-i -f "${podName}"

	echo "Pod create"
	podman pod create \
		--publish 8000:80 \
		--name="${podName}"

	echo "Rm old volume"
	podman volume rm \
		-f  \
		"${wviewImgVolume}" || echo "Volume ${wviewImgVolume} not found"

	echo "Create volume"
	podman volume create \
		"${wviewImgVolume}"

	echo "Provision volume"
	podman run \
		--rm \
		-t \
		--volume "${wviewImgVolume}":/mnt \
		"${wviewImage}" \
		find /usr/local/var/wview/img/ -mindepth 1 -exec cp -a '{}' '/mnt/' ';'

	echo "Create wview container"
	podman create \
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
	podman create \
		--name=nginx \
		--pod="${podName}" \
		--volume "${wviewImgVolume}":/usr/share/nginx/html \
		"${nginxImage}"
}

usage() {
	printf "
Usage   : %s COMMAND

Commands:
    images    :   Build container images
    pod-build :   Create the wview pod
    pod-build :   Create start the wview pod

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
		pod-build)
			echo "INFO: building pod"
			build_pod
			;;
		pod-start)
			echo "INFO: starting pod"
			podman pod start ${podName}
			;;
		*)
			usage
			;;
	esac
	shift
done
