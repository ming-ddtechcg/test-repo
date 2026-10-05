#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"
ADD_ONS_HOME="${K8S_INFRA_HOME}/add-ons"
CNI_HOME="${ADD_ONS_HOME}/cni"
CALICO_HOME="${CNI_HOME}/calico"

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
            CALICO_HOME="${CNI_HOME}/calico"
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

DEPLOYMENT_MODE=""
DEPLOYMENT_VERSION=""
DEPLOYMENT_FILE=""

while true
do
    echo ""
    echo "Select Calico version from the following"
    echo "=============================================="
    echo "1. 3.29"
    echo "2. 3.33"
    echo ""
    echo "9. return"
    echo ""
    questionAndResponse "select (1/2/9)" "1 2 9"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        DEPLOYMENT_VERSION="3.29"
        break
        ;;
    '2')
        DEPLOYMENT_VERSION="3.33"
        break
        ;;
    '9')
        break
        ;;
    esac
done

while true
do
    echo ""
    echo "Select Calico one of the following deployments"
    echo "=============================================="
    echo "1. 50 nodes or less"
    echo "2. more than 50 nodes"
    echo ""
    echo "9. return"
    echo ""
    questionAndResponse "select (1/2/9)" "1 2 9"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        DEPLOYMENT_FILE="${CALICO_HOME}/deployments/calico-${DEPLOYMENT_VERSION}.yaml"
        break
        ;;
    '2')
        DEPLOYMENT_FILE="${CALICO_HOME}/deployments/calico-typha-${DEPLOYMENT_VERSION}.yaml"
        ;;
    '9')
        break
        ;;
    esac
done

while true
do
    echo ""
    echo "Deployment privillege"
    echo "=============================================="
    echo "1. as root at the master node"
    echo "2. as user with the KUBECONFIG setup"
    echo ""
    echo "3. return"
    echo ""
    questionAndResponse "select (1/2)" "1 2"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        DEPLOYMENT_MODE="root_on_master"
        break
        ;;
    '2')
        DEPLOYMENT_MODE="user_with_kubeconfig"
        break
        ;;
    '3')
        exit 0
        ;;
    esac
done

echo ""
echo "start the CNI (calico) installation"

case ${DEPLOYMENT_MODE} in
'root_on_master')
    sudo kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f ${DEPLOYMENT_FILE}
    ;;
'user_with_kubeconfig')
    kubectl apply -f ${DEPLOYMENT_FILE}
    ;;
esac

echo ""
echo "completed the CNI (calico) installation"
echo ""
echo "to remove the CNI (calico) installation with the following:"
case ${DEPLOYMENT_MODE} in
'root_on_master')
    echo "sudo kubectl delete --kubeconfig=/etc/kubernetes/admin.conf -f ${DEPLOYMENT_FILE}"
    ;;
'user_with_kubeconfig')
    echo "kubectl delete -f ${DEPLOYMENT_FILE}"
    ;;
esac

exit 0

