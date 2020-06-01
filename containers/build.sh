#!/bin/bash
#
#
set -euo pipefail

#declare -r rsyslogImage="rsyslog:wview"
declare -r wviewImage="wview:5.21.7"
declare -r nginxImage="docker.io/library/nginx:latest"
declare -r podName="wview-pod"
declare -r wviewImgVolume="wview-img"

build() {
	#podman build -t "${rsyslogImage}" -f Dockerfile.rsyslog .
	podman build -t "${wviewImage}" -f Dockerfile.wview .
}

create() {
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

#	echo "Provision volume"
#	podman run \
#		--rm \
#		--volume "${wviewImgVolume}":/mnt \
#		"${wviewImage}" \
#		find /usr/local/var/wview/img/ -exec cp -a '{}' '/mnt/' ';'

	#echo "Create rsyslog container"
	#podman create \
	#	--name=rsyslog \
	#	--pod="${podName}" \
	#	--volume /dev \
	#	"${rsyslogImage}" \
	#	/usr/sbin/rsyslogd -n

	echo "Create wview container"
	#--volumes-from "rsyslog"
	podman create \
		--name=wview  \
		--pod="${podName}" \
		--volume $PWD/wview-conf.sdb:/usr/local/etc/wview/wview-conf.sdb \
		--volume $PWD/wview-archive.sdb:/usr/local/var/wview/archive/wview-archive.sdb \
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

build
create
