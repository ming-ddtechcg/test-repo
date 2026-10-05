#!/bin/sh


#
# starts from here
#

OPTION="$1"

case ${OPTION} in
'allow'|'disallow')
    echo "" > /dev/null 2>&1
    ;;
*)
    echo ""
    echo "option: allow|disallow"
    echo ""
    echo "allow:    to allow the user pods to be scheduled on the master/control-plan node"
    echo "disallow: to disallow the user pods to be scheduled on the master/control-plan node"
    ;;
esac

sudo echo "" > /dev/null
echo "adjust the master node for taint"

for node_name in `sudo kubectl get nodes --kubeconfig=/etc/kubernetes/admin.conf --no-headers | egrep "control-plane|master" | awk '{ print $1}'`
do
    case ${OPTION} in
    'allow' )
        sudo kubectl taint node ${node_name} \
            --kubeconfig=/etc/kubernetes/admin.conf \
	    --overwrite=true \
	    node-role.kubernetes.io/master=:NoSchedule- 2> /dev/null

        sudo kubectl taint node ${node_name} \
            --kubeconfig=/etc/kubernetes/admin.conf \
	    --overwrite=true \
	    node-role.kubernetes.io/control-plane=:NoSchedule- 2> /dev/null
        ;;
    'disallow')
        sudo kubectl taint node ${node_name} \
            --kubeconfig=/etc/kubernetes/admin.conf \
	    --overwrite=true \
	    node-role.kubernetes.io/control-plane=:NoSchedule 2> /dev/null
        ;;
    esac
done

echo "completed the the master node adjustment"

exit 0

