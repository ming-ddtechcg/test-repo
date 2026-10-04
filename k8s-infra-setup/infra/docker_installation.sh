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

sudo echo "" > /dev/null

echo ""
echo "check the docker installation on the current system"
sudo apt-mark unhold docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
sudo apt remove -y $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc 2> /dev/null | cut -f1) > /dev/null 2>&1
sudo apt remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
sudo apt autoremove -y > /dev/null 2>&1

echo ""
echo "install the docker package"
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ""
echo "verify the docker package installation"
DOCKER_INSTALLED=`apt list --installed 2> /dev/null | egrep "docker-ce|docker-ce-cli|containerd.io|docker-buildx-plugin|docker-compose-plugin"`

if [ "${DOCKER_INSTALLED}" != "" ]
then
    echo ""
    echo "enable and start the docker service"
    sudo systemctl enable docker
    sudo systemctl start docker

    sudo apt-mark hold docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
    echo "Kubernetes 1.23+ is no longer to support dockershim, therefore,"
    echo "cri-dockerd installation is must."
    echo ""

    exit 0
fi

echo ""
echo "the docker installation is incompleted"
echo ""

exit 1

