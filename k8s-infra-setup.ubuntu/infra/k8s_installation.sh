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

	return 1
    fi

    #questionAndResponse "enter Kubernetes version (i.e. v1.36)" ""
    #KUBERNETS_PACKAGE_VERSION="${ANSWER_REQUESTION_RESPONSE}"
    KUBERNETS_PACKAGE_VERSION="${KUBERNETS_PACKAGE_VERSION}"

    if [ "${KUBERNETS_PACKAGE_VERSION}" = "" ]
    then
        echo ""
        echo "ERROR: unknown Kubernetes package version, abort"
        echo ""

        return 2
    fi

    echo ""
    echo "check and disable swap"
    SWAP_INFO=`sudo cat /proc/swaps | grep -v "^Filename"`
    if [ "${SWAP_INFO}" != "" ]
    then
        sudo swapoff -a
        sudo sed -i '/swap/d' /etc/fstab
    fi

    echo ""
    echo "perform the k8s package installation"

    sudo apt-get update
    sudo apt-get install -y software-properties-common curl

    curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key \
        | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETS_PACKAGE_VERSION/deb/ /" \
        | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-mark unhold kubelet kubectl kubeadm > /dev/null 2>&1
    sudo apt-get install -y kubelet kubeadm kubectl

    K8S_INSTALLED=`apt list --installed 2> /dev/null | egrep "kubeadm|kubelet|kubectl"`

    if [ "${K8S_INSTALLED}" != "" ]
    then
        sudo apt-mark hold kubelet kubectl kubeadm
        sudo tee -a ${K8S_INSTALL_SIGNATURE} <<EOL
EOL

        echo ""
        echo "the k8s package installation is completed"
        echo ""

        return 0
    fi

    sudo rm -f ${K8S_INSTALL_SIGNATURE} > /dev/null 2>&1

    echo ""
    echo "the k8s package installation is incompleted"
    echo ""

    return 3
}



#
# start from here
#

updateEnvironmentDirectory

. ${ETC_HOME}/infra_env_settings.sh
. ${ETC_HOME}/k8s_settings.sh
. ${UTILS_HOME}/questionutils.sh ""

sudo echo "" > /dev/null

if [ ! -d "${SIGNATURE_PATH}" ]
then
    sudo mkdir -p ${SIGNATURE_PATH} > /dev/null 2>&1
fi

installK8sPackages
STATUS=$?

exit ${STATUS}

