#!/bin/bash

# get the directory of this script
work_dir="$(realpath $0|rev|cut -d '/' -f2-|rev)"

# configuration variables for the iso
dockerfile="${work_dir}/docker/Dockerfile"

# fetch latest base docker image
docker pull archlinux:base-devel

# build the docker container
docker build --no-cache -f "${dockerfile}" -t xarian-install-builder ${work_dir}

# make the container build the iso
exec docker run --privileged --rm -v ${work_dir}:/root/xarianos -v $GITHUB_OUTPUT:$GITHUB_OUTPUT -e "GITHUB_OUTPUT=$GITHUB_OUTPUT" -h xarian-install-builder xarian-install-builder ./build-iso.sh
