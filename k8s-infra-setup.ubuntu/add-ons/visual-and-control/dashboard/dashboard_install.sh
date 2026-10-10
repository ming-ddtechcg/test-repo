#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"
ADD_ONS_HOME="${K8S_INFRA_HOME}/add-ons"
VISUAL_AND_CONTROL_HOME="${ADD_ONS_HOME}/visual-and-control"
DASHBOARD_HOME="${VISUAL_AND_CONTROL_HOME}/dashboard"

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
            VISUAL_AND_CONTROL_HOME="${ADD_ONS_HOME}/visual-and-control"
            DASHBOARD_HOME="${VISUAL_AND_CONTROL_HOME}/dashboard"
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

questionAndResponse "Proceed the Kubernetes Dashboard installation (y/n)" "y n"

case ${ANSWER_REQUESTION_RESPONSE} in
'y')
    echo "" > /dev/null 2>&1
    ;;
'n')
    echo ""
    echo "exit..."
    echo ""
    exit 0
    ;;
esac

UNINSTALL_PROCEDURE=""

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
        sudo kubectl apply \
            --kubeconfig=/etc/kubernetes/admin.conf \
            -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard.yaml

        UNINSTALL_PROCEDURE="sudo kubectl delete --kubeconfig=/etc/kubernetes/admin.conf -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard.yaml"
        break
        ;;
    '2')
        DEPLOYMENT_MODE="user_with_kubeconfig"
        kubectl apply \
            -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard.yaml 

        UNINSTALL_PROCEDURE="kubectl delete -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard.yaml"
        break
        ;;
    '3')
        exit 0
        ;;
    esac
done

questionAndResponse "Allow the Kubernetes Dashboard access with the cluster admin role (y/n)" "y n"

case ${ANSWER_REQUESTION_RESPONSE} in
'y')
    case ${DEPLOYMENT_MODE} in
    'root_on_master')
        sudo kubectl delete \
            --kubeconfig=/etc/kubernetes/admin.conf \
            -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard-cluster-admin-role.yaml \
            > /dev/null 2>&1
        sudo kubectl apply \
            --kubeconfig=/etc/kubernetes/admin.conf \
            -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard-cluster-admin-role.yaml
        ;;
    'user_with_kubeconfig')
        kubectl delete \
            -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard-cluster-admin-role.yaml \
            > /dev/null 2>&1
        kubectl apply \
            -f ${DASHBOARD_HOME}/deployments/kubernetes-dashboard-cluster-admin-role.yaml
        ;;
    esac
    ;;
'n')
    echo "skip the cluster admin role setup"
    ;;
esac


echo ""
echo "completed the dashboard installation"

if [ "${UNINSTALL_PROCEDURE}" != "" ]
then
    echo ""
    echo "to remove the dashboard installation with the following:"
    echo "${UNINSTALL_PROCEDURE}"
fi

exit 0

