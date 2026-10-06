#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"

EXECUTION_DIR=`dirname $0`

PRG="$0"



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

. ${ETC_HOME}/k8s_settings.sh

OPTION_CONTROL_PLANE_ENDPOINT="$1"
OPTION_SANS="$2"
CRI_SOCKET="$3"

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

if [ ! -f "${K8S_INSTALL_SIGNATURE}" ]
then
    echo ""
    echo "ERROR: Kubernetes package installation is pending, abort"
    echo ""
    exit 3
fi

CONTROL_PLANE_ENDPOINT_OPTION=""
if [ "${CONTROL_PLANE_ENDPOINT}" = "" ]
then
    if [ "${OPTION_CONTROL_PLANE_ENDPOINT}" != "" ]
    then
	THE_CONTROL_PLANE_ENDPOINT=`echo ${OPTION_CONTROL_PLANE_ENDPOINT} | sed -s 's| ||g'`
        CONTROL_PLANE_ENDPOINT_OPTION="--control-plane-endpoint ${THE_CONTROL_PLANE_ENDPOINT}"
    fi
else
    THE_CONTROL_PLANE_ENDPOINT=`echo ${CONTROL_PLANE_ENDPOINT} | sed -s 's| ||g'`
    CONTROL_PLANE_ENDPOINT_OPTION="--control-plane-endpoint ${THE_CONTROL_PLANE_ENDPOINT}"
fi

if [ "${CONTROL_PLANE_ENDPOINT_OPTION}" = "" ]
then
    CONTROL_PLANE_ENDPOINT_OPTION="--control-plane-endpoint ${IP_ADDRESS}"
fi

EXTRA_SANS_OPTION=""
if [ "${EXTRA_SANS}" = "" ]
then
    if [ "${OPTION_SANS}" != "" ]
    then
	SANS=`echo ${OPTION_SANS} | sed -s 's| ||g'`
        EXTRA_SANS_OPTION="--apiserver-cert-extra-sans ${SANS}"
    fi
else
    SANS=`echo ${EXTRA_SANS} | sed -s 's| ||g'`
    EXTRA_SANS_OPTION="--apiserver-cert-extra-sans ${SANS}"
fi

REGISTRY_URL_OPTION=""
if [ "${REGISTRY_URL}" = "" ]
then
    if [ "${OPTION_REGISTRY_URL}" != "" ]
    then
        THE_REGISTRY_URL=`echo ${OPTION_REGISTRY_URL} | sed -s 's| ||g'`
        REGISTRY_URL_OPTION="--image-repository ${THE_REGISTRY_URL}"
    fi
else
    THE_REGISTRY_URL=`echo ${REGISTRY_URL} | sed -s 's| ||g'`
    REGISTRY_URL_OPTION="--image-repository ${THE_REGISTRY_URL}"
fi

SERVICE_DNS_DOMAIN_OPTION=""
if [ "${SERVICE_DNS_DOMAIN}" = "" ]
then
    if [ "${OPTION_SERVICE_DNS_DOMAIN}" != "" ]
    then
        THE_SERVICE_DNS_DOMAIN=`echo ${OPTION_SERVICE_DNS_DOMAIN} | sed -s 's| ||g'`
        SERVICE_DNS_DOMAIN_OPTION="--service-dns-domain ${THE_SERVICE_DNS_DOMAIN}"
    fi
else
    THE_SERVICE_DNS_DOMAIN=`echo ${SERVICE_DNS_DOMAIN} | sed -s 's| ||g'`
    SERVICE_DNS_DOMAIN_OPTION="--service-dns-domain ${THE_SERVICE_DNS_DOMAIN}"
fi

echo ""

sudo kubeadm init \
    --pod-network-cidr "${POD_NETWORK_CIDR}" \
    --service-cidr "${SERVICE_NETWORK_CIDR}" \
    --kubernetes-version "${KUBERNETS_VERSON}" \
    --upload-certs \
    --cri-socket unix://${CRI_SOCKET} \
    ${SERVICE_DNS_DOMAIN_OPTION} \
    ${REGISTRY_URL_OPTION} \
    ${CONTROL_PLANE_ENDPOINT_OPTION} \
    ${EXTRA_SANS_OPTION} 2>&1 | sudo tee ${KUBERNETS_SETUP_LOG}
STATUS=$?

if [ "${STATUS}" -ne "0" ]
then
    echo ""
    echo "WARNING: Kubernetes initialization has been terminated with issues, abort"
    echo ""

    exit ${STATUS}
fi

echo ""
echo "Container Runtime Interface (CRI) option:"
echo "--cri-socket unix://${CRI_SOCKET}"
echo ""

echo ""
echo "The Kubernetes init log file is at:"
echo "${KUBERNETS_SETUP_LOG}"
echo ""

echo ""
echo "*** ignore the above kubeadm join commands"
echo ""

exit 0

