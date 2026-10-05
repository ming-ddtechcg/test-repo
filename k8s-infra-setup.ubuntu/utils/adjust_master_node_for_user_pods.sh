#!/bin/sh


#
# starts from here
#

sudo echo "" > /dev/null
echo "adjust the master node for taint"

for node_name in `sudo kubectl get nodes --kubeconfig=/etc/kubernetes/admin.conf --no-headers | egrep "control-plane|master" | awk '{ print $1}'`
do
    sudo kubectl taint node ${node_name} \
        --kubeconfig=/etc/kubernetes/admin.conf \
	--overwrite=true \
	node-role.kubernetes.io/master=:NoSchedule- 2> /dev/null

    sudo kubectl taint node ${node_name} \
        --kubeconfig=/etc/kubernetes/admin.conf \
	--overwrite=true \
	node-role.kubernetes.io/control-plane=:NoSchedule- 2> /dev/null
done

echo "completed the the master node adjustment"

exit 0

