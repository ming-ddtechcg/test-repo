#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"

EXECUTION_DIR=`dirname $0`

PRG="$0"

CRI_SOCKET=""



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
# starts from here
#

NODE_JOIN_COMMAND="$1"

if [ "${NODE_JOIN_COMMAND}" = "" ]
then
    echo ""
    echo "ERROR: no node join command available, abort"
    echo ""

    exit 1
fi

updateEnvironmentDirectory

. ${ETC_HOME}/k8s_settings.sh
. ${UTILS_HOME}/questionutils.sh ""

sudo echo "" > /dev/null
sudo ${NODE_JOIN_COMMAND} 2>&1 | sudo tee ${KUBERNETS_SETUP_LOG}

echo ""
echo "The Kubernetes join log file is at:"
echo "${KUBERNETS_SETUP_LOG}"
echo ""

exit 0

