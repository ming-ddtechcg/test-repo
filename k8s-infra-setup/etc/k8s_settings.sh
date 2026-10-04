#!/bin/sh

#
# pod network CIDR
#
POD_NETWORK_CIDR="10.244.0.0/16"

#
# the service network CIDR
#
SERVICE_NETWORK_CIDR="10.96.0.0/12"

#
# the extra Subject Alertnative Names (SANs)
#
# with comma to separate each SAN
#
# suggestions:
# 1. have a SAN for the apiserver access 
# 2. have a general SAN for accessing all workers to serve the business purpose
#
EXTRA_SANS=""

#
# the Kubernetes package version
#
# For example to install the Kubernetes package version 1.36:
#
#   KUBERNETS_PACKAGE_VERSION="v1.36" 
#
# Note:
# 1. the patch is not required and will be used the lates patch version from the repository.
#
KUBERNETS_PACKAGE_VERSION="v1.36"

#
# the Kubernetes version
#
# the Kubernetes container version (apart from the binary version)
#
# For example:
#
#    KUBERNETS_VERSON="1.36.5"
#
KUBERNETS_VERSON="1.36.5"

#
# the path of the signatues for updates or changes
#
SIGNATURE_PATH="/etc/k8s_infra"

#
# Kubernetes package installation
#
K8S_INSTALL_SIGNATURE="${SIGNATURE_PATH}/1.k8s_install_signature"

#
# Kubernetes kueadm installation log
#
KUBERNETS_SETUP_LOG="${SIGNATURE_PATH}/kubeadm.log"
