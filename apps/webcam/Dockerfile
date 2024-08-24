################################################################################
#
# webcam container
#
FROM ubuntu:18.04

RUN apt-get -y update; \
    \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
      bash \
      curl \
      ftp \
      imagemagick \
      jq \
      tzdata \
      ; \
    \
    apt-get clean; \
    \
    rm -rf /var/lib/apt/lists
