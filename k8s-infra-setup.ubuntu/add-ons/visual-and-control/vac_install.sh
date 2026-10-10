#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"
ADD_ONS_HOME="${K8S_INFRA_HOME}/add-ons"
VAC_HOME="${ADD_ONS_HOME}/visual-and-control"

EXECUTION_DIR=`dirname $0`

PRG="$0"



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
            ADD_ONS_HOME="${K8S_INFRA_HOME}/add-ons"
            VAC_HOME="${ADD_ONS_HOME}/visual-and-control"
            break
        fi

        CURRENT_PWD=`dirname ${CURRENT_PWD}`
    done
}



#
# starts from here
#

updateEnvironmentDirectory

. ${UTILS_HOME}/questionutils.sh ""

while true
do
    echo ""
    echo "Select one of the following Visualization & Control"
    echo "============================================================="
    echo "1. dashboard"
    echo ""
    echo "9. return"
    echo ""
    questionAndResponse "select (1/9)" "1 9"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        ${VAC_HOME}/dashboard/dashboard_install.sh
        continue
        ;;
    '9')
        break
        ;;
    esac
done

exit 0

