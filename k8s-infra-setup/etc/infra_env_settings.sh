#!/bin/sh

#
# the path of the signatues for updates or changes
#
SIGNATURE_PATH="/etc/k8s_infra"

#
# limits.conf updates
#
UPDATE_SIGNATURE_LIMITS_CONF="/etc/k8s_infra/1.limits_conf"

#
# sysctl.conf updates
#
UPDATE_SIGNATURE_SYSCTL_CONF="/etc/k8s_infra/1.sysctl_conf"

#
# modules.conf updates
#
UPDATE_SIGNATURE_MODULES_CONF="/etc/k8s_infra/1.modules_conf"

#
# Kubernetes package installation
#
K8S_INSTALL_SIGNATURE="/etc/k8s_infra/1.k8s_install_signature"

