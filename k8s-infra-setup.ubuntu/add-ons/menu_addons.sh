#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"
ADD_ONS_HOME="${K8S_INFRA_HOME}/add-ons"
CNI_HOME="${ADD_ONS_HOME}/cni"
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
            CNI_HOME="${ADD_ONS_HOME}/cni"
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
    echo "Select one of the following add-ons"
    echo "============================================================="
    echo "1. Container Network Interface (CNI)"
    echo "2. AutoScale"
    echo "3. Visualization & Control"
    echo ""
    echo "9. exit"
    echo ""
    questionAndResponse "select (1/2/3/9)" "1 2 3 9"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        ${CNI_HOME}/cni_install.sh
        continue
        ;;
    '2')
        echo ""
        echo "Pending..."
        echo ""
        continue
        ;;
    '3')
        ${VAC_HOME}/vac_install.sh
        continue
        ;;
    '9')
        break
        ;;
    esac
done


exit 0

