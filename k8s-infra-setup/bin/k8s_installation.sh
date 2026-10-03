#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"

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
            break
        fi

        CURRENT_PWD=`dirname ${CURRENT_PWD}`
    done
}



#
# installs K8s packages
#
installK8sPackages()
{
    if [ -f "${K8S_INSTALL_SIGNATURE}" ]
    then
        echo ""
	echo "WARNING: the K8s install has been performed already, skip"
	echo 
	return
    fi
    
    echo ""
    echo "disable swap"
    sudo swapoff -a
    sudo sed -i '/swap/d' /etc/fstab

    echo ""
    echo "perform the k8s package installation"

    sudo apt-get update
    sudo apt-get install -y software-properties-common curl

    curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key \
        | gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" \
        | tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-mark unhold kubelet kubectl kubeadm > /dev/null 2>&1
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubectl kubeadm

    sudo apt list --installed | egrep "kubeadm|kubelet|kubectl"

    sudo tee -a ${K8S_INSTALL_SIGNATURE} <<EOL
EOL

    echo ""
    echo "the k8s package installation is completed"
    echo ""
}



#
# install infra packages
#
installInfraPackages()
{
    echo ""
    echo "perform the infra package installation"
    
    ${INFRA_HOME}/ubuntu_tuning.sh

    echo ""
    echo "the infra package installation is completed"
    echo ""
}



#
# start from here
#

updateEnvironmentDirectory

. ${ETC_HOME}/env_setting.sh
. ${UTILS_HOME}questionutils.sh ""

sudo echo "" > /dev/null

installInfraPackages

installK8sPackages

