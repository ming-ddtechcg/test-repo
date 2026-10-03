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
            BIN_HOME="${BIN_HOME}/bin"
            ETC_HOME="${K8S_INFRA_HOME}/etc"
            INFRA_HOME="${K8S_INFRA_HOME}/infra"
            UTILS_HOME="${K8S_INFRA_HOME}/utils"
            break
        fi

        CURRENT_PWD=`dirname ${CURRENT_PWD}`
    done
}



#
# starts from here
#

updateEnvironmentDirectory

. ${UTILS_HOME}questionutils.sh ""

sudo echo "" > /dev/null

echo ""
echo "check the docker installation on the current system"
sudo apt-get remove -y docker docker-engine docker.io containerd runc > /dev/null 2>&1
sudo apt autoremove -y > /dev/null 2>&1

echo ""
echo "install the docker package"
sudo apt-get install -y docker.io=20.10.12-0ubuntu2~20.04.1 > /dev/null 2>&1

echo ""
echo "verify the docker package installation"
sudo apt list --installed | grep docker

echo ""
echo "enable and start the docker service"
sudo systemctl enable docker
sudo systemctl start docker

questionAndResponse "Grant `whoami` to perform all docker CLI tasks (y/n)" "y n"
case ${ANSWER_REQUESTION_RESPONSE} in
'y')
    sudo usermod -aG docker `whoami`
    echo ""
    echo "WARNING: it is required `whoami` to log out and log in again"
    echo ""
    ;;
esac

echo ""
echo "the docker installation is completed"
echo ""

exit 0

