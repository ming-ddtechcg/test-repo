#!/bin/sh

FILTER_STRING="master|control-plane|worker"



#
# start from here
#

sudo echo "" > /dev/null

for node_name in `kubectl get nodes --show-labels --no-headers | egrep -v ${FILTER_STRING} | awk '{ print$1 }'`
do
    sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf label node ${node_name} node-role.kubernetes.io/worker=''
done

exit 0

