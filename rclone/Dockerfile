FROM rclone/rclone

# --no-cache: index is updated and used on-the-fly and not cached locally
RUN \
    apk add --no-cache \
        bash \
        sqlite;

#
# NOTE: override the default entrypoint, that is the "rclone" command
#
ENTRYPOINT []
