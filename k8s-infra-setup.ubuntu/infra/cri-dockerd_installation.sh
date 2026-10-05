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
. ${ETC_HOME}/cri-dockerd_settings.sh

sudo echo "" > /dev/null

echo ""
echo "check the cri-dockerd installation on the current system"

echo ""
echo "install the cri-dockred package"
DOWNLOAD_URL=`echo ${CRI_DOCKERD_DOWNLOAD_RELEASE_DOWNLOAD_URL_TEMPLATE} \
    | sed -e 's|##CRI_DOCKERD_PACKAGE_VERSION##|'${CRI_DOCKERD_PACKAGE_VERSION}'|g'`
curl -Ls ${DOWNLOAD_URL} -o /tmp/download.tgz
cd /tmp
gzip -dc /tmp/download.tgz | tar xvf - > /dev/null 2>&1
sudo install -o root -g root -m 0755 /tmp/cri-dockerd/cri-dockerd /usr/local/bin/cri-dockerd
curl -Ls ${CRI_DOCKERD_SYSTEMD_SERVICE_DOWNLOAD_URL} -o /tmp/cri-dockerd/cri-docker.service
curl -Ls ${CRI_DOCKERD_SYSTEMD_SOCKET_DOWNLOAD_URL} -o /tmp/cri-dockerd/cri-docker.socket
sudo install /tmp/cri-dockerd/cri-docker.service /lib/systemd/system/cri-docker.service
sudo install /tmp/cri-dockerd/cri-docker.socket /lib/systemd/system/cri-docker.socket
sudo sed -i -e 's|/usr/bin/cri-dockerd|/usr/local/bin/cri-dockerd|g' /lib/systemd/system/cri-docker.service
sudo rm -fr /tmp/cri-dockerd /tmp/download.tgz > /dev/null 2>&1

echo ""
echo "verify the cri-dockerd package installation"
if [ -f "/usr/local/bin/cri-dockerd" ]
then
    echo ""
    echo "enable and start the cri-dockerd service"
    sudo systemctl daemon-reload
    sudo systemctl enable cri-docker
    sudo systemctl start cri-docker

    echo ""
    echo "the cri-dockerd installation is completed"
    echo ""

    exit 0
fi

echo ""
echo "the cri-dockerd installation is incompleted"
echo ""

exit 1

