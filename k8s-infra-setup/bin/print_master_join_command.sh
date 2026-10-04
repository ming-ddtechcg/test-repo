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
# start from here
#

updateEnvironmentDirectory

. ${UTILS_HOME}/questionutils.sh ""

sudo echo "" > /dev/null
echo "print the master join command"

questionAndResponse "Is this the first master node (y/n)" "y n"

case ${ANSWER_REQUESTION_RESPONSE} in
'n')
    echo ""
    echo "WARNING: this command must be executed on the first master node with the running cluster. abort"
    echo ""
    exit 1
    ;;
esac

CRI_SOCKET=""

while true
do
    echo "Select Container Runtime Interface (CRI) runs on the targetd node"
    echo "================================================================="
    echo "1. CRI-O"
    echo "2. containerd"
    echo "3. cri-docker/docker"
    echo ""
    echo "9. exit"
    echo ""
    questionAndResponse "select (1/2/3/9)" "1 2 3 9"

    case ${ANSWER_REQUESTION_RESPONSE} in
    '1')
        CRI_SOCKET=`${UTILS_HOME}/retrieve_cri_socket_string_cli.sh "crio"`
        break
        ;;
    '2')
        CRI_SOCKET=`${UTILS_HOME}/retrieve_cri_socket_string_cli.sh "containerd"`
        break
        ;;
    '3')
        CRI_SOCKET=`${UTILS_HOME}/retrieve_cri_socket_string_cli.sh "cri-dockerd"`
        break
        ;;
    '9')
        exit 0
        ;;
    esac
done

CERT_KEY=`sudo kubeadm init phase upload-certs \
    --upload-certs 2> /dev/null \
    | tail -1`

MASTER_JOIN_COMMAND="`sudo kubeadm token create --print-join-command \
    --kubeconfig=/etc/kubernetes/admin.conf` \
    --certificate-key ${CERT_KEY} --control-plane --cri-socket unix://${CRI_SOCKET}"

echo ""
echo "the master node join command: "
echo ""
echo ${MASTER_JOIN_COMMAND}
echo ""
echo "please copy the above kubernetes master join command to the desired node and execute it."
echo ""

echo "completed the master join print command"

exit 0

