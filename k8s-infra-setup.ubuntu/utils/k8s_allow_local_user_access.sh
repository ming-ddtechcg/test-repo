#!/bin/sh



#
# starts from here
#

sudo echo "" > /dev/null
echo "setting up .bashrc for kuebconfig"

mkdir -p ${HOME}/.kube
sudo cp /etc/kubernetes/admin.conf ${HOME}/.kube/config
sudo chown `whoami`:`whoami` ${HOME}/.kube/config

sudo tee -a ${HOME}/.bashrc <<EOL

KUBECONFIG=${HOME}/.kube/config
export KUBECONFIG
EOL

echo ""
echo "the k8s cluster access is available for the next login"
echo ""

echo "completed .bashrc setup for kuebconfig"

exit 0

