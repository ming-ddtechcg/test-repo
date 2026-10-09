#!/bin/sh



#
# starts from here
#

sudo echo "" > /dev/null
echo "setting up .bashrc for kuebconfig"

mkdir -p ${HOME}/.kube > /dev/null 2>&1
sudo cp /etc/kubernetes/admin.conf ${HOME}/.kube/config
sudo chown `whoami`:`whoami` ${HOME}/.kube/config

HAS_KUBECONFIG=`grep KUBECONFIG ${HOME}/.bashrc | egrep "/.kube/config|export KUBECONFIG"`
if [ "${HAS_KUBECONFIG}" = "" ]
then
    sudo tee -a ${HOME}/.bashrc <<EOL

KUBECONFIG=${HOME}/.kube/config
export KUBECONFIG
EOL
fi

echo ""
echo "the k8s cluster access is available for the next login"
echo ""

echo "completed .bashrc setup for kuebconfig"

exit 0

