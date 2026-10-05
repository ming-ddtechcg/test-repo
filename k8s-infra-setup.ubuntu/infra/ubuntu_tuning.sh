#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"

EXECUTION_DIR=`dirname $0`

PRG="$0"

CURRENT_TIME=`date '+%Y%m%d%H%M%S'`

LIMITS_CONF="/etc/security/limits.conf"
BACKUP_LIMITS_CONF="/etc/security/limits.conf_${CURRENT_TIME}"

SYSCTL_CONF="/etc/sysctl.conf"
BACKUP_SYSCTL_CONF="/etc/sysctl.conf_${CURRENT_TIME}"

MODULES_CONF="/etc/modules.conf"
BACKUP_MODULES_CONF="/etc/modules.conf_${CURRENT_TIME}"

NEED_REBOOT="false"



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
            BIN_HOME="${BIN_HOME}/bin"
            ETC_HOME="${K8S_INFRA_HOME}/etc"
            INFRA_HOME="${K8S_INFRA_HOME}/infra"
            UTILS_HOME="${K8S_INFRA_HOME}/utils"
            break
        fi

        CURRENT_PWD=`dirname ${CURRENT_PWD}`
    done
}



#
# apply the change for limits.conf
#
tuningLimitsConf()
{
    if [ -f "${UPDATE_SIGNATURE_LIMITS_CONF}" ]
    then
        echo ""
	echo "/etc/security/limits.conf has the update-to-date tuning"
	echo ""
	return
    fi

    echo "backup ${LIMITS_CONF} to ${BACKUP_LIMITS_CONF}"
    sudo cp ${LIMITS_CONF} ${BACKUP_LIMITS_CONF}

    sudo tee -a ${LIMITS_CONF} <<EOL
root soft nproc 100000
root hard nproc 100000
root soft nofile 100000
root hard nofile 100000
EOL

    sudo tee -a ${UPDATE_SIGNATURE_LIMITS_CONF} <<EOL
EOL

    NEED_REBOOT="true"
}



#
# apply the changes for sysctl.conf
#
tuningSysctlConf()
{
    if [ -f "${UPDATE_SIGNATURE_SYSCTL_CONF}" ]
    then
        echo ""
	echo "/etc/sysctl.conf has the update-to-date tuning"
	echo ""
	return
    fi

    echo "backup ${SYSCTL_CONF} to ${BACKUP_SYSCTL_CONF}"
    sudo cp ${SYSCTL_CONF} ${BACKUP_SYSCTL_CONF}

    sudo tee -a ${SYSCTL_CONF} <<EOL
fs.file-max = 1000000
fs.inotify.max_user_watches=100000
fs.inotify.max_user_instances=100000
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOL

    sudo tee -a ${UPDATE_SIGNATURE_SYSCTL_CONF} <<EOL
EOL

    NEED_REBOOT="true"
}



#
# apply the changes for modules_conf
#
tuningModulesConf()
{
    if [ -f "${UPDATE_SIGNATURE_MODULES_CONF}" ]
    then
        echo ""
	echo "modules.conf has the update-to-date tuning"
	echo ""
	return
    fi

    echo "backup ${MODULES_CONF} to ${BACKUP_MODULES_CONF}"
    sudo cp ${MODULES_CONF} ${BACKUP_MODULES_CONF}

    sudo tee -a  ${MODULES_CONF} <<EOL
br_netfilter
EOL

    sudo tee -a ${UPDATE_SIGNATURE_MODULES_CONF} <<EOL
EOL

    NEED_REBOOT="true"
}



#
# starts from here
#

updateEnvironmentDirectory

. ${ETC_HOME}/infra_env_settings.sh
. ${UTILS_HOME}/questionutils.sh ""

sudo echo "" > /dev/null

if [ ! -d "${SIGNATURE_PATH}" ]
then
    sudo mkdir -p ${SIGNATURE_PATH} > /dev/null 2>&1
fi

tuningLimitsConf
tuningSysctlConf
tuningModulesConf

if [ "${NEED_REBOOT}" = "true" ]
then
    echo ""
    echo "WRANING: one of configurations is changed and the reboot is required."
    echo ""

    questionAndResponse "Please enter (y)es to reboot or (n)o for the delay of the reboot (y/n)" "y n"

    case ${ANSWER_REQUESTION_RESPONSE} in
    'y')
	sudo sync
        sudo reboot
	;;
    *)
        echo ""
	echo "please perform the manual reboot later."
	echo ""
	;;
    esac
fi

exit 0

