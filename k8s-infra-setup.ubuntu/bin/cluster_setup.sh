#!/bin/sh

K8S_INFRA_HOME=""
BIN_HOME="${K8S_INFRA_HOME}/bin"
ETC_HOME="${K8S_INFRA_HOME}/etc"
INFRA_HOME="${K8S_INFRA_HOME}/infra"
UTILS_HOME="${K8S_INFRA_HOME}/utils"

EXECUTION_DIR=`dirname $0`

PRG="$0"

NODE_TYPE=""
CRI_SOCKET=""



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

. ${UTILS_HOME}/questionutils.sh ""

NODE_TYPE="`${UTILS_HOME}/retrieve_node_type.sh`"

questionAndResponse "Is this the first master node (y/n)" "y n"
ANS="${ANSWER_REQUESTION_RESPONSE}"

case ${ANS} in
'y')
    while true
    do
        echo "Select Container Runtime Interface (CRI) runs on this node"
        echo "=========================================================="
        echo "1. CRI-O"
        echo "2. containerd"
        echo "3. cri-docker/docker"
        echo ""
        echo "9. terminate the cluster setup"
        echo ""
        questionAndResponse "select (1/2/3/9)" "1 2 3 9"

        case ${ANSWER_REQUESTION_RESPONSE} in
        '1')
            CRI_SOCKET=`${UTILS_HOME}/retrieve_cri_socket_string_cli.sh "crio"`
            break
            ;;
        '2')
            CRI_SOCKET=`${UTILS_HOME}/retrieve_cri_socket_string_cli.sh "containerd"`
            break
            ;;
        '3')
            CRI_SOCKET=`${UTILS_HOME}/retrieve_cri_socket_string_cli.sh "cri-dockerd"`
            break
            ;;
        '9')
            exit 0
            ;;
        esac
    done

    case ${NODE_TYPE} in
    'NONE')
        questionAndResponse "Enter extra subjcet alernative name(s) for certifcats to access the api-server\n(press enter to ignore, use comma between each SAN)\n" "skip"

        if [ "${ANSWER_REQUESTION_RESPONSE}" != "" ]
        then
	    ${BIN_HOME}/first_master_setup_cli.sh "${ANSWER_REQUESTION_RESPONSE}" "${CRI_SOCKET}"
        else
	    ${BIN_HOME}/first_master_setup_cli.sh "" "${CRI_SOCKET}"
	fi

        echo ""
        questionAndResponse "allow the local user (`whoami`) to access the k8s cluster (y/n)" "y n"
        case ${ANSWER_REQUESTION_RESPONSE} in
        'y')
	    ${UTILS_HOME}/k8s_allow_local_user_access.sh
            ;;
        esac

        echo ""
        questionAndResponse "Will this master node schedule the user pods (y/n)" "y n"
        case ${ANSWER_REQUESTION_RESPONSE} in
        'y')
            ${UTILS_HOME}/adjust_master_node_for_user_pods.sh
	    ;;
        esac

	echo ""

	;;
    *)
        echo ""
        echo "WARNING: the current node type is running as: ${NODE_TYPE}"
        echo ""
        echo "It can not be proceeded, unless the node is required to \"kubeadm init\""
        echo ""
        ;;
    esac

    echo ""
    ;;
*)
    if [ "${NODE_TYPE}" = "NONE" ]
    then
        IS_WAITING="true"

	echo ""
	echo "For master join, run \"print_master_join_command.sh\" at the first master node"
        echo ""
	echo "For worker join, run \"print_worker_join_command.sh\" at the first master node"

	while [ "${IS_WAITING}" = "true" ]
	do
            questionAndResponse "Waiting this node to be joined\npaste kubeadm join here"
            ANS="${ANSWER_REQUESTION_RESPONSE}"

	    IS_KUBEADM_JOIN=`echo ${ANS} | egrep "kubeadm|join"`

	    if [ "${IS_KUBEADM_JOIN}" = "" ]
            then
	        echo ""
		echo "WARNING: the input is seem not a kubeadm join, please try again"
		echo ""
		continue
	    fi

            ${UTILS_HOME}/k8s_node_join.sh "${ANS}"

            NODE_TYPE="`${UTILS_HOME}/retrieve_node_type.sh`"

	    if [ "${NODE_TYPE}" = "NONE" ]
            then
	        echo ""
		echo "WARNING: this node is not ready to joined clsuter yet"
		echo ""
		continue
	    fi		

	    IS_WAITING="false"
	done
    fi

    case ${NODE_TYPE} in
    'MASTER')
        echo ""
        questionAndResponse "Will this master node schedule the user pods (y/n)" "y n"
        case ${ANSWER_REQUESTION_RESPONSE} in
        'y')
            ${UTILS_HOME}/adjust_master_node_for_user_pods.sh
            ;;
        esac

        echo ""
        questionAndResponse "allow the local user (`whoami`) to access the k8s cluster (y/n)" "y n"
        case ${ANSWER_REQUESTION_RESPONSE} in
        'y')
	    ${UTILS_HOME}/k8s_allow_local_user_access.sh
            ;;
        esac
	;;
    'WORKER')
        echo ""
        echo "The node has been setup as: ${NODE_TYPE}"
	;;
    *)
        echo ""
        echo "WARNING: unable to determine the node type after the node configuration, check log."
        echo ""
        ;;
    esac

    echo ""
    ;;
esac

exit 0

