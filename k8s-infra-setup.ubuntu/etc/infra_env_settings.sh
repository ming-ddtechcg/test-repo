#!/bin/sh

#
# the path of the signatues for updates or changes
#
SIGNATURE_PATH="/etc/k8s_infra"

#
# limits.conf updates
#
UPDATE_SIGNATURE_LIMITS_CONF="${SIGNATURE_PATH}/1.limits_conf"

#
# sysctl.conf updates
#
UPDATE_SIGNATURE_SYSCTL_CONF="${SIGNATURE_PATH}/1.sysctl_conf"

#
# modules.conf updates
#
UPDATE_SIGNATURE_MODULES_CONF="${SIGNATURE_PATH}/1.modules_conf"

