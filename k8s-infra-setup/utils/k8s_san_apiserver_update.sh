#!/bin/sh

XCLOUD_K8S_INFRA_HOME="/home/bda-master/xcloud-k8s-infra"
UTILS_HOME="${XCLOUD_K8S_INFRA_HOME}/utils"

. ${UTILS_HOME}/questionutils.sh ""

NODE_TYPE="`${UTILS_HOME}/retrieve_node_type.sh`"


#
# start from here
#

case ${NODE_TYPE} in
'NONE')
    echo ""
    echo "ERROR: this script is applied for the node in either master or work node, abort"
    echo ""
    exit 1
    ;;
esac

questionAndResponse "Enter subjcet alernative name for api-server (press enter to ignore)\n" "skip"

if [ "${ANSWER_REQUESTION_RESPONSE}" = "" ]
then
    echo ""
    echo "WARNING: no SAN input, abort"
    echo ""
    exit 2
fi

case ${NODE_TYPE} in
'MASTER')
    ENTRY=`sudo grep "    server:" /etc/kubernetes/admin.conf`

    NEW_ENTRY="    server: https://${ANSWER_REQUESTION_RESPONSE}:6443"

    sudo sed -i 's|'"${ENTRY}"'|'"${NEW_ENTRY}"'|' /etc/kubernetes/admin.conf
    ;;
esac

ENTRY=`sudo grep "    server:" /etc/kubernetes/kubelet.conf`

NEW_ENTRY="    server: https://${ANSWER_REQUESTION_RESPONSE}:6443"

sudo sed -i 's|'"${ENTRY}"'|'"${NEW_ENTRY}"'|' /etc/kubernetes/kubelet.conf

exit 0

