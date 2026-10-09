#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"
ADD_ONS_HOME="${K8S_INFRA_HOME}/add-ons"
CNI_HOME="${ADD_ONS_HOME}/cni"
FLANNEL_HOME="${CNI_HOME}/flannel"
CNI_PLUGINS_HOME="${FLANNEL_HOME}/cni-plugins"

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
            FLANNEL_HOME="${CNI_HOME}/flannel"
            CNI_PLUGINS_HOME="${FLANNEL_HOME}/cni-plugins"
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
DEPLOYMENT_FILE="${FLANNEL_HOME}/deployments/kube-flannel.yml"

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
echo "start the CNI (flannel) installation"

echo ""
echo "install the flannel cni-plugins"
${CNI_PLUGINS_HOME}/flannel_cni_plugin_install.sh

case ${DEPLOYMENT_MODE} in
'root_on_master')
    sudo kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f ${DEPLOYMENT_FILE}
    ;;
'user_with_kubeconfig')
    kubectl apply -f ${DEPLOYMENT_FILE}
    ;;
esac

echo ""
echo "completed the CNI (flannel) installation"
echo ""
echo "to remove the CNI (flannel) installation with the following:"
case ${DEPLOYMENT_MODE} in
'root_on_master')
    echo "sudo kubectl delete --kubeconfig=/etc/kubernetes/admin.conf -f ${DEPLOYMENT_FILE}"
    ;;
'user_with_kubeconfig')
    echo "kubectl delete -f ${DEPLOYMENT_FILE}"
    ;;
esac

exit 0

