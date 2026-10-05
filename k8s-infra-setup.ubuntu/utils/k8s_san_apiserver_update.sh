#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"

EXECUTION_DIR=`dirname $0`

PRG="$0"

NODE_TYPE=""



#
# updates environment directory setup
#
updateEnvironmentDirectory()
{
    if [ "${EXECUTION_DIR}" = "." ]
    then
        EXECUTION_DIR=`pwd`
    fi

    CURRENT_PWD="${EXECUTION_DIR}"
    while true
    do
        if [ -s "${CURRENT_PWD}/.k8s-infra-setup.txt" ]
        then
            K8S_INFRA_HOME="${CURRENT_PWD}"
            BIN_HOME="${K8S_INFRA_HOME}/bin"
            ETC_HOME="${K8S_INFRA_HOME}/etc"
            INFRA_HOME="${K8S_INFRA_HOME}/infra"
            UTILS_HOME="${K8S_INFRA_HOME}/utils"
            break
        fi

        CURRENT_PWD=`dirname ${CURRENT_PWD}`
    done
}



#
# start from here
#

updateEnvironmentDirectory

. ${UTILS_HOME}/questionutils.sh ""

NODE_TYPE="`${UTILS_HOME}/retrieve_node_type.sh`"

case ${NODE_TYPE} in
'NONE')
    echo ""
    echo "ERROR: this script is applied for the node in either master or work node, abort"
    echo ""
    exit 1
    ;;
esac

echo ""
echo "Update Subjcet Alernative Name (SAN) for the api-server with:"
echo "- master node:     the changes will be admin.conf and the kubelet configuration"
echo "- non master node: the change will be only the kubelet configuration"
echo ""
echo "It is recommended to provide FQDN possible first, and IP address is second (if FQDN is unavailable)."
echo ""
echo "*** one entry only ***"
questionAndResponse "Enter SAN (press enter to ignore)\n" "skip"

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

