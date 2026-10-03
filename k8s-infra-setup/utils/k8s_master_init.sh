#!/bin/sh

XCLOUD_K8S_INFRA_HOME="/home/bda-master/xcloud-k8s-infra"
ETC_HOME="${XCLOUD_K8S_INFRA_HOME}/etc"
UTILS_HOME="${XCLOUD_K8S_INFRA_HOME}/utils"

. ${ETC_HOME}/k8s_settings.sh
. ${UTILS_HOME}/questionutils.sh ""



#
# start from here
#

sudo echo "" > /dev/null
echo "setup the first master node"

ADMIN_SETUP=`sudo ls /etc/kubernetes/admin.conf 2> /dev/null`

if [ "${ADMIN_SETUP}" != "" ]
then
    echo ""
    echo "ERROR: this cluster is running, abort"
    echo ""
    exit 1
fi

IP_ADDRESS=`${UTILS_HOME}/retrieve_host_ip.sh`

if [ "${IP_ADDRESS}" = "" ]
then
    echo ""
    echo "ERROR: unable to retrieve the host IP addresss, abort"
    echo ""
    exit 2
fi

EXTRA_SANS_OPTION=""
if [ "${EXTRA_SANS}" = "" ]
then
    questionAndResponse "Enter extra subjcet alernative name(s) for certifcats to access the api-server\n(press enter to ignore, use comma between each SAN)\n" "skip"

    if [ "${ANSWER_REQUESTION_RESPONSE}" != "" ]
    then
	SANS=`echo ${ANSWER_REQUESTION_RESPONSE} | sed -s 's| ||g'`
        EXTRA_SANS_OPTION="--apiserver-cert-extra-sans ${SANS}"
    fi
else
    SANS=`echo ${EXTRA_SANS} | sed -s 's| ||g'`
    EXTRA_SANS_OPTION="--apiserver-cert-extra-sans ${SANS}"
fi

echo ""

sudo kubeadm init \
    --image-repository="${REGISTRY_URL}" \
    --pod-network-cidr="${POD_NETWORK_CIDR}" \
    --service-cidr="${SERVICE_NETWORK_CIDR}" \
    --control-plane-endpoint="${IP_ADDRESS}" \
    ${EXTRA_SANS_OPTION} \
    --kubernetes-version="${K8S_VERSION}"

echo "** ignore the above kubeadm join commands"
echo ""

exit 0

