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
# starts from here
#

updateEnvironmentDirectory

NODE_TYPE="`${UTILS_HOME}/retrieve_node_type.sh`"

OPTION_SANS="$1"
CRI_SOCKET="$2"

echo ""
echo "the current node type: ${NODE_TYPE}"

case ${NODE_TYPE} in
'NONE')

    echo ""
    echo "perform the first master setup now..."

    ${UTILS_HOME}/k8s_master_init_cli.sh "${OPTION_SANS}" "${CRI_SOCKET}"
    sleep 2
    echo ""

    #${UTILS_HOME}/wait_all_pods_normal.sh
    #sleep 2
    #echo ""
    ;;
esac

exit 0

