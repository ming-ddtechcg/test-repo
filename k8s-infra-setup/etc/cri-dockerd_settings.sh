#!/bin/sh

#
# the cri-dockerd package version
#
# For example to install the cri-dockerd package version 1.36:
#   CRI_DOCKERD_PACKAGE_VERSION="0.4.7" 
#
CRI_DOCKERD_PACKAGE_VERSION="0.4.7"

#
# the cri-dockerd release download URL with the version template
#
CRI_DOCKERD_DOWNLOAD_RELEASE_DOWNLOAD_URL_TEMPLATE="https://github.com/Mirantis/cri-dockerd/releases/download/v##CRI_DOCKERD_PACKAGE_VERSION##/cri-dockerd-##CRI_DOCKERD_PACKAGE_VERSION##.amd64.tgz"

#
# the cri-dockerd systemd service download URL
#
CRI_DOCKERD_SYSTEMD_SERVICE_DOWNLOAD_URL="https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service"

#
# the cri-dockerd systemd socket download URL
#
CRI_DOCKERD_SYSTEMD_SOCKET_DOWNLOAD_URL="https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket"

