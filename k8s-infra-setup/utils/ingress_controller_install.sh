#!/bin/sh

XCLOUD_K8S_INFRA_HOME="/home/bda-master/xcloud-k8s-infra"
ETC_HOME="${XCLOUD_K8S_INFRA_HOME}/etc"


#
# start from here
#

sudo echo "" > /dev/null
echo "install Nginx ingress controller "

sudo kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f ${ETC_HOME}/defaultbackend.yaml > /dev/null 2>&1

sudo kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f ${ETC_HOME}/ingress.yaml > /dev/null 2>&1

echo "completed the Nginx ingress controller installation"

exit 0

