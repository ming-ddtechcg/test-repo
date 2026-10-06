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
# Subject Alertnative Names (SANs)
#
# Notes:
# 1. use for the API Server serving certificate and be both/mixed IP addresses or/and DNS names.
# 2. comma to separate each SAN
#    for example:
#        EXTRA_SANS="apiserver.example.com,1.2.3.4"
#
# suggestions:
# 1. have a SAN for the apiserver access 
# 2. have a general SAN for accessing all workers to serve the business purpose
#
EXTRA_SANS=""

#
# a control plane endpoint for a Virtual IP (VIP) or a Load Balancer (LB)
#
# Notes:
# 1. it is a single entry 
# 2. an IP address or a DNS name (FQDN and preferred)
# 3. the format is an IP address or a DNS name (FQDN) with the port of apiserver listens (6443 as default)
#    For example:
#    CONTROL_PLANE_ENDPOINT="apiserver.example.com:6443"
#    CONTROL_PLANE_ENDPOINT="1.2.3.4:6443"
# 4. an IP address or a DNS name (FQDN) should be in the entry of "EXTRA_SANS"
#
CONTROL_PLANE_ENDPOINT=""

#
# container registry to pull control plane images from
#
# Notes:
# For example:
#   REGISTRY_URL="registry.k8s.io"
# or
#   REGISTRY_URL="harbor.ddtechcg.com:5001"
#
REGISTRY_URL=""

#
# an alternative domain for services
#
# Notes:
# 1. default service domain is "cluster.local"
#
SERVICE_DNS_DOMAIN=""

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
