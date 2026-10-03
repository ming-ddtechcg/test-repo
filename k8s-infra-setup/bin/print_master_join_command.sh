#!/bin/sh

XCLOUD_K8S_INFRA_HOME="/home/bda-master/xcloud-k8s-infra"
UTILS_HOME="${XCLOUD_K8S_INFRA_HOME}/utils"

. ${UTILS_HOME}/questionutils.sh ""



#
# start from here
#

sudo echo "" > /dev/null
echo "print the master join command"

questionAndResponse "Is this the first master node and the cluster is running (y/n)" "y n"

case ${ANSWER_REQUESTION_RESPONSE} in
'n')
    echo ""
    echo "WARNING: this command must be executed on the first master node with the running cluster. abort"
    echo ""
    exit 1
    ;;
esac

CERT_KEY=`sudo kubeadm init phase upload-certs --kubeconfig=/etc/kubernetes/admin.conf --upload-certs 2> /dev/null | tail -1`

MASTER_JOIN_COMMAND="`sudo kubeadm token create --print-join-command --kubeconfig=/etc/kubernetes/admin.conf` --certificate-key ${CERT_KEY} --control-plane"

echo ""
echo "the master node join command: "
echo ""
echo ${MASTER_JOIN_COMMAND}
echo ""
echo "please copy the above kubernetes master join command to the desired node and execute it."
echo ""

echo "completed the master join print command"

exit 0

