#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"

EXECUTION_DIR=`dirname $0`

PRG="$0"

NODE_TYPE=""



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
# starts from here
#

updateEnvironmentDirectory

. ${UTILS_HOME}/questionutils.sh ""

NODE_TYPE="`${UTILS_HOME}/retrieve_node_type.sh`"

sudo echo "" > /dev/null

case ${NODE_TYPE} in
'MASTER')

    echo ""
    echo "starting the multi-master finalize setting"

    echo ""
    echo "collecting master information"

    MASTER_NODES=`sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes --no-headers -o wide | egrep "control-plane|master" | awk '{ print $1":"$6 }'`

    MASTER_NAME_IP=""
    MASTER_IP=""

    for master_node in ${MASTER_NODES}
    do
        NAME=`echo ${master_node} | cut -d":" -f1`
	IP=`echo ${master_node} | cut -d":" -f2`

        if [ "${MASTER_NAME_IP}" != "" ]
	then
	    MASTER_NAME_IP="${MASTER_NAME_IP} "
	fi

	MASTER_NAME_IP="${MASTER_NAME_IP}${master_node}"

        if [ "${MASTER_NAME_IP}" != "" ]
	then
	    MASTER_IP="${MASTER_IP} "
	fi

	MASTER_IP="${MASTER_IP}${IP}"
    done

    sudo rm -f /tmp/kube-apiserver.yaml.new /tmp/etcd.yaml.new > /dev/null 2>&1

    echo ""
    echo "working on kube-apiserver.yaml"
    sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | \
        ${UTILS_HOME}/update_kube_api_server_etcd.py "${MASTER_IP}" > /tmp/kube-apiserver.yaml.new

    if [ -s "/tmp/kube-apiserver.yaml.new" ]
    then
        sudo mv /tmp/kube-apiserver.yaml.new /etc/kubernetes/manifests/kube-apiserver.yaml
	sudo chown root:root /etc/kubernetes/manifests/kube-apiserver.yaml
	sudo chmod 600 /etc/kubernetes/manifests/kube-apiserver.yaml
    fi

    echo ""
    echo "working on etcd.yaml"
    sudo cat /etc/kubernetes/manifests/etcd.yaml | \
	${UTILS_HOME}/update_kube_etcd_etcd.py "${MASTER_NAME_IP}" > /tmp/etcd.yaml.new
    sudo cat /tmp/etcd.yaml.new | \
	${UTILS_HOME}/update_kube_etcd_cluster_state.py > /tmp/etcd.yaml.new.1

    if [ -s "/tmp/etcd.yaml.new.1" ]
    then
        sudo mv /tmp/etcd.yaml.new.1 /etc/kubernetes/manifests/etcd.yaml
	sudo chown root:root /etc/kubernetes/manifests/etcd.yaml
	sudo chmod 600 /etc/kubernetes/manifests/etcd.yaml
        sudo rm -f /tmp/etcd.yaml.new > /dev/null 2>&1
    fi

    echo ""
    echo "working on configurations for the apiserver"
    ${UTILS_HOME}/k8s_san_apiserver_update.sh

    echo ""
    echo "completed the multi-master finalize settings"
    echo ""
    ;;
'WORKER')

    echo ""
    echo "starting the multi-master finalize setting"

    echo ""
    echo "working on configurations for the apiserver"
    ${UTILS_HOME}/k8s_san_apiserver_update.sh

    echo ""
    echo "completed the multi-master finalize settings"
    echo ""
    ;;
*)
    echo ""
    echo "INFO: this script is only performed on the master node, abort"
    echo ""
    exit 1
    ;;
esac

exit 0

