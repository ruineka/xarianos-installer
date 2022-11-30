#!/bin/bash

if [ $EUID -ne 0 ]; then
	echo "$(basename $0) must be run as root"
	exit 1
fi

# get the directory of this script
work_dir="$(realpath $0|rev|cut -d '/' -f2-|rev)"

# configuration variables for the iso
output_dir="${work_dir}/output"
script_dir="${work_dir}/xarianos"
temp_dir="${work_dir}/temp"

# create output directory if it doesn't exist yet
rm -rf "${output_dir}"
mkdir -p "${output_dir}"

rm -rf "${temp_dir}"
mkdir -p "${temp_dir}"

# make the container build the iso
mkarchiso -v -w "${temp_dir}" -o "${output_dir}" "${script_dir}"

# allow git command to work
git config --global --add safe.directory "${work_dir}"

ISO_FILE_PATH=`ls ${output_dir}/*.iso`
ISO_FILE_NAME=`basename "${ISO_FILE_PATH}"`
VERSION=`echo "${ISO_FILE_NAME}" | cut -c11-20 | sed 's/\./-/g'`
ID=`git rev-parse --short HEAD`

pushd ${output_dir}
sha256sum ${ISO_FILE_NAME} > sha256sum.txt
cat sha256sum.txt
popd

if [ -f "${GITHUB_OUTPUT}" ]; then
	echo "iso_file_name=${ISO_FILE_NAME}" >> "${GITHUB_OUTPUT}"
	echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
	echo "id=${ID}" >> "${GITHUB_OUTPUT}"
else
	echo "No github output file set"
fi
