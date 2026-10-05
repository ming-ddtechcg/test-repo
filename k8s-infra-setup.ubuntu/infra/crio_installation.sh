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

. ${UTILS_HOME}/questionutils.sh ""
. ${ETC_HOME}/cri-o_settings.sh

sudo echo "" > /dev/null

echo ""
echo "check the cri-o installation on the current system"
sudo apt-mark unhold cri-o > /dev/null 2>&1
sudo apt remove -y cri-o > /dev/null 2>&1
sudo apt autoremove -y > /dev/null 2>&1

#questionAndResponse "enter cri-o version (i.e. v1.36)" ""
#CRIO_PACKAGE_VERSION="${ANSWER_REQUESTION_RESPONSE}"

if [ "${CRIO_PACKAGE_VERSION}" = "" ]
then
    echo ""
    echo "ERROR: unknown Cri-o version, abort"
    echo ""

    exit 1
fi

echo ""
echo "install the cri-o package"

sudo apt-get update
sudo apt-get install -y software-properties-common curl

curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_PACKAGE_VERSION/deb/Release.key \
    | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_PACKAGE_VERSION/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/cri-o.list

sudo apt-get install -y cri-o

echo ""
echo "verify the cri-o package installation"
CRIO_INSTALLED=`apt list --installed 2> /dev/null | grep "cri-o"`
if [ "${CRIO_INSTALLED}" != "" ]
then 
    sudo apt-mark hold cri-o

    echo ""
    echo "enable and start the cri-o service"
    sudo systemctl enable crio
    sudo systemctl start crio

    echo ""
    echo "the cri-o installation is completed"
    echo ""

    exit 0
fi

echo ""
echo "the cri-o installation is incompleted"
echo ""

exit 2

