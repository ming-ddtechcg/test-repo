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

OPTION="$1"

case ${OPTION} in
'cluster'|'standalone')
    echo "" > /dev/null 2>&1
    ;;
*)
    echo ""
    echo "OPTION is in either \"cluster\"|\"standalone\""
    echo ""
    exit 1
    ;;
esac

updateEnvironmentDirectory

. ${UTILS_HOME}/questionutils.sh ""

while true
do
    echo "Select Container Runtime Interface"
    echo "=================================="
    echo "1. CRI-O"
    echo "2. containerd"
    echo "3. cri-docker/docker"
    echo ""

    case ${OPTION} in
    'cluster')
        echo "9. exit and terminate the cluster setup"
        ;;
    'standalone')
        echo "9. exit"
        ;;
    esac

    echo ""
    questionAndResponse "select (1/2/3/9)" "1 2 3 9"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        echo "/var/run/crio/crio.sock"
        exit 0
        ;;
    '2')
        echo "/run/containerd/containerd.sock"
        exit 0
        ;;
    '3')
        echo "/run/cri-dockerd.sock"
        exit 0
        ;;
    '9')
        exit 0
        ;;
    esac
done

