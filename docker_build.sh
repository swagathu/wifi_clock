#!/bin/bash

WORK_DIR="/wifi_clock"
IMAGE_NAME="wifi_clock"

docker build --tag "$IMAGE_NAME" . --build-arg "USERID=$(id -u)" --build-arg "GROUPID=$(id -u)" 

docker run -it --rm  -v "$(pwd):$WORK_DIR" --entrypoint "$WORK_DIR/build.sh" "$IMAGE_NAME" "$@"