#!/bin/sh


#
# start from here
#

sudo echo "" > /dev/null

HAS_ADMIN_CONFIG="`sudo ls /etc/kubernetes/admin.conf 2> /dev/null`"

if [ "${HAS_ADMIN_CONFIG}" != "" ]
then
    echo "MASTER"
    exit 0
fi

HAS_KUBELET_CONFIG_ONLY="`sudo ls /etc/kubernetes/kubelet.conf 2> /dev/null`"

if [ "${HAS_KUBELET_CONFIG_ONLY}" != "" ]
then
    echo "WORKER"
    exit 0
fi

echo "NONE"

exit 0

