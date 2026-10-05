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
. ${ETC_HOME}/containerd_settings.sh

sudo echo "" > /dev/null

echo ""
echo "check the containerd installation on the current system"

echo ""
echo "install the containerd package"
DOWNLOAD_URL=`echo ${CONTAINERD_DOWNLOAD_RELEASE_DOWNLOAD_URL_TEMPLATE} \
    | sed -e 's|##CONTAINERD_PACKAGE_VERSION##|'${CONTAINERD_PACKAGE_VERSION}'|g'`
curl -Ls ${DOWNLOAD_URL} -o /tmp/download.tgz
cd /tmp
gzip -dc /tmp/download.tgz | tar xvf - > /dev/null 2>&1
sudo install -o root -g root -m 0755 /tmp/bin/* /usr/local/bin/
curl -Ls ${CONTAINERD_SYSTEMD_SERVICE_DOWNLOAD_URL} -o /tmp/bin/containerd.service
sudo install /tmp/bin/containerd.service /lib/systemd/system/containerd.service
sudo rm -fr /tmp/bin /tmp/download.tgz > /dev/null 2>&1

if [ -s "/etc/containerd/config.toml" ]
then
    touch /tmp/containerd_config.toml

    while IFS= read -r line
    do
        IS_DISABLED_PLUGINS=`echo ${line} | grep "^disabled_plugins"`

        if [ "${IS_DISABLED_PLUGINS}" != "" ]
        then
            echo "#${line}" >> /tmp/containerd_config.toml
            continue
        fi

        echo "${line}" >> /tmp/containerd_config.toml

    done < /etc/containerd/config.toml

    if [ -s "/tmp/containerd_config.toml" ]
    then
        sudo mv /tmp/containerd_config.toml /etc/containerd/config.toml
    fi
fi

echo ""
echo "verify the containerd package installation"
if [ -f "/usr/local/bin/containerd" ]
then
    echo ""
    echo "enable and start the containerd service"
    sudo systemctl daemon-reload
    sudo systemctl enable containerd
    sudo systemctl start containerd

    echo ""
    echo "the containerd installation is completed"
    echo ""

    exit 0
fi

echo ""
echo "the containerd installation is incompleted"
echo ""

exit 1

