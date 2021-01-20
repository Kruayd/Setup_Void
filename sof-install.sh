#!/bin/bash

# Install
cd ~/Builds/sof-bin/
git checkout origin/stable-v1.6.1 -b stable-v1.6.1
sudo ./go.sh

# Uninstall
# test -n "${ROOT}" ||  \
#     ROOT=
# test -n "${INTEL_PATH}" || \
#     INTEL_PATH=lib/firmware/intel
# 
# sudo rm -rf ${ROOT}/${INTEL_PATH}/sof/*
# sudo rm -rf ${ROOT}/${INTEL_PATH}/sof-tplg-*
# sudo rm -rf ${ROOT}/${INTEL_PATH}/sof-tplg
