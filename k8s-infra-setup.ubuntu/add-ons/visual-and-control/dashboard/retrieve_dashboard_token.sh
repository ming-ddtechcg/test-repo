#!/bin/sh

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

NAMESPACE="kubernetes-dashboard"



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
# start from here
#

updateEnvironmentDirectory

. ${UTILS_HOME}/questionutils.sh ""

questionAndResponse "Ensure KUBECONFIG has been set. Press enter to continue or Control-C to exit" "skip"

SECRET_NAME=`kubectl get secrets -n ${NAMESPACE} -o json \
    | jq -r '.items[] | select( .metadata.annotations != null and .metadata.annotations."kubernetes.io/service-account.name" != null and .metadata.annotations."kubernetes.io/service-account.name" == "kubernetes-dashboard" ) | .metadata.name'`

if [ "${SECRET_NAME}" != "" ]
then
    echo ""
    echo "token:"
    echo ""

    kubectl get secret/${SECRET_NAME} -n ${NAMESPACE} -o jsonpath='{.data.token}' | base64 -d
else
    echo ""
    echo "ERROR: unable to locate the token secret, abort"
    echo ""

    exit 1
fi

echo ""
 
exit 0

