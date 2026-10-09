#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"
ADD_ONS_HOME="${K8S_INFRA_HOME}/add-ons"
CNI_HOME="${ADD_ONS_HOME}/cni"
CILIUM_HOME="${CNI_HOME}/cilium"
CHARTS_HOME="${CILIUM_HOME}/charts"

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
            CILIUM_HOME="${CNI_HOME}/cilium"
            CHARTS_HOME="${CILIUM_HOME}/charts"
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
    echo "1. 1.20.2"
    echo ""
    echo "9. return"
    echo ""
    questionAndResponse "select (1/9)" "1 9"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        DEPLOYMENT_VERSION="1.20.2"
        break
        ;;
    '9')
        exit 0
        ;;
    esac
done

#DEPLOYMENT_FILE="${CILIUM_HOME}/charts/cilium-${DEPLOYMENT_VERSION}.tgz"

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

HELM=`which helm`

if [ "${HELM}" = "" ]
then
    echo ""
    echo "WARNING: helm is unavialable in the path for the cilium installation, abort"
    echo ""

    exit 1
fi

echo ""
echo "start the CNI (cilium) installation"

case ${DEPLOYMENT_MODE} in
'root_on_master')
    sudo helm install cilium oci://quay.io/cilium/charts/cilium \
        --version ${DEPLOYMENT_VERSION} \
        --kubeconfig=/etc/kubernetes/admin.conf \
        --namespace kube-system
    ;;
'user_with_kubeconfig')
    helm install cilium oci://quay.io/cilium/charts/cilium \
        --version ${DEPLOYMENT_VERSION} \
        --namespace kube-system
    ;;
esac

echo ""
echo "completed the CNI (cilium) installation"
echo ""
echo "to remove the CNI (calico) installation with the following:"
echo "helm uninstall cilium --namespace kube-system"

exit 0

