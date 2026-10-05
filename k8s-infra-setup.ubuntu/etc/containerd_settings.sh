#!/bin/sh

#
# the containerd package version
#
# For example to install the containerd package version 2.4.1:
#   CONTAINERD_PACKAGE_VERSION="2.4.1" 
#
CONTAINERD_PACKAGE_VERSION="2.4.1"

#
# the containerd release download URL with the version template
#
CONTAINERD_DOWNLOAD_RELEASE_DOWNLOAD_URL_TEMPLATE="https://github.com/containerd/containerd/releases/download/v##CONTAINERD_PACKAGE_VERSION##/containerd-##CONTAINERD_PACKAGE_VERSION##-linux-amd64.tar.gz"

#
# the cri-dockerd systemd service download URL
#
CONTAINERD_SYSTEMD_SERVICE_DOWNLOAD_URL="https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"

