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
# starts from here
#

updateEnvironmentDirectory

ARCH=$(uname -m)

CNI_PLUGINS_HOME="${FLANNEL_HOME}/cni-plugins"

case $ARCH in
armv7*)
    exit 0
    ;;
aarch64) 
    ARCH="arm64"
    ;;
x86_64)
    ARCH="amd64"
    ;;
esac

if [ ! -d "/opt/cni/bin" ]
then
    sudo mkdir -p /opt/cni/bin
else
    CURRENT_TIME=`date '+%Y%m%d%H%M%S'`
    sudo mv /opt/cni/bin /opt/cni/bin_${CURRENT_TIME}
    sudo mkdir -p /opt/cni/bin
fi

CNI_PLUGINS_FILE="${CNI_PLUGINS_HOME}/cni-plugins-linux-$ARCH-v1.7.1.tgz"

if [ ! -f "${CNI_PLUGINS_FILE}" ]
then
    ${CNI_PLUGINS_HOME}/flannel_cni_plugin_downloads.sh "${ARCH}"
fi

if [ -f "${CNI_PLUGINS_HOME}/cni-plugins-linux-$ARCH-v1.7.1.tgz" ]
then
    sudo tar -C /opt/cni/bin -xzf ${CNI_PLUGINS_HOME}/cni-plugins-linux-$ARCH-v1.7.1.tgz
fi

exit 0

