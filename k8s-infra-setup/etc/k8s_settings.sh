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
# the k8s container version (apart from the binary version
#
K8S_VERSION="1.21.4"

