#!/bin/sh

XCLOUD_K8S_INFRA_HOME="/home/bda-master/xcloud-k8s-infra"
UTILS_HOME="${XCLOUD_K8S_INFRA_HOME}/utils"

. ${UTILS_HOME}/questionutils.sh ""



#
# start from here
#

sudo echo "" > /dev/null
echo "print the worker join command"

questionAndResponse "Is this the master node and the cluster is running (y/n)" "y n"

case ${ANSWER_REQUESTION_RESPONSE} in
'n')
    echo ""
    echo "WARNING: this command must be executed on the master node with the running cluster. abort"
    echo ""
    exit 1
    ;;
esac

WORKER_JOIN_COMMAND="`sudo kubeadm token create --print-join-command --kubeconfig=/etc/kubernetes/admin.conf`"

echo ""
echo "the worker node join command: "
echo ""
echo ${WORKER_JOIN_COMMAND}
echo ""
echo "please copy the above kubernetes worker join command to the desired node and execute it."
echo ""

echo "completed the worker join print command"

exit 0

