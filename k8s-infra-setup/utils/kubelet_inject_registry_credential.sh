#!/bin/sh

#
# This is a initial config file.
#
# kubelet configuration/credential file with one or more credentials:
# 
#{
#  "auths": {
#    "<secret_name_1>": {
#      "auth": "<credential_base64_encoded_1>"
#    },
#    "<secret_name_2>": {
#      "auth": "<credential_base64_encoded_2>"
#    }
#  }
#}
#
# hence:
# <secret_name>:                        
# the name of the secret in Kubernetes where kubelete pulls images with login
# <credential_base64_encoded>
# the user and passwd with the base64 encode with the following format:
#   <username>:<password>
#
# For example:
#   a login user: "user" and its password: "123456", then the encoded command:
#   `echo -n "user:123456" | base64` => "dXNlcjoxMjM0NTY="
#   the secret name is "user_sec", 
#
# ---
#{
#  "auths": {
#    "user_sec": {
#      "auth": "dXNlcjoxMjM0NTY="
#    }
#  }
#}
# ---
#
# and, save it into a file, called config.json and encode it with base64 for the following command:
# `cat config.json | base64 --wrap=0`
#
# the contents of the output is the value of CREDENTIAL_BASE64_ENCODED
#

#
# starts from here
#
# NOTES:
# 1. sudo is accessible
# 2. jq is required
#

CREDENTIAL_BASE64_ENCODED="$1"

if [ "${CREDENTIAL_BASE64_ENCODED}" = "" ]
then
    echo ""
    echo "ERROR: missing the registry auth base64 encoded, abort"
    echo ""

    exit 1
fi

sudo echo "" > /dev/null
echo "prepare the registry credentials"

echo "${CREDENTIAL_BASE64_ENCODED}" \
    | base64 -d > /tmp/config.json

if [ ! -s "/var/lib/kubelet/config.json" ]
then
    # /var/lib/kubelet/config.json does not exist
    sudo mv /tmp/config.json /var/lib/kubelet/config.json
    sudo chown root:root /var/lib/kubelet/config.json

    echo "install the registry credentials"
else
    # /var/lib/kubelet/config.json does exist and merge is required
    ADDED_ON=`cat /tmp/config.json | jq -r '.auths' | tr -d '\n '`
    sudo cat /var/lib/kubelet/config.json \
        | jq -r '.auths +='"${ADDED_ON}" \
        > /var/lib/kubelet/config.json.1
    sudo mv /var/lib/kubelet/config.json.1 /var/lib/kubelet/config.json

    echo "merge the registry credentials"
fi

sudo systemctl restart kubelet.service

echo "completed the registry credentials setup"

exit 0

