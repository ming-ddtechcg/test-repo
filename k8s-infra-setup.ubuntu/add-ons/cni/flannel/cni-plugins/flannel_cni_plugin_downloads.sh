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

ARCH=""



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
# flannel cni-plugins downloads
#
downloadFlannelCniPlugins()
{
    for arch in arm64 amd64
    do
        curl -O -L -s https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-$arch-v1.7.1.tgz
    done
}



#
# starts from here
#

updateEnvironmentDirectory

ARCH="$1"

curl -L -s \
    https://github.com/ming-ddtechcg/k8s-utils/releases/download/flannel-v1.7.1/cni-plugins-linux-${ARCH}-v1.7.1.tgz  \
    -o ${CNI_PLUGINS_HOME}/cni-plugins-linux-${ARCH}-v1.7.1.tgz

exit 0

