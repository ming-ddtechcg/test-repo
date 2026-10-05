#!/bin/sh

MAX_LOOP_COUNT="1000"

#
# start from here
#

_MAX_LOOP_COUNT="$1"

if [ "${_MAX_LOOP_COUNT}" != "" ]
then
    MAX_LOOP_COUNT="${_MAX_LOOP_COUNT}"
fi

sudo echo "" > /dev/null

KEEP_LOOP="true"
counter="0"
while [ "${KEEP_LOOP}" = "true" ]
do
    if [ "${counter}" -gt "${MAX_LOOP_COUNT}" ]
    then
        KEEP_LOOP="false"
	continue
    fi

    STATUS=`sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -A --no-headers | awk '{ print $4 }'`

    for status in ${STATUS}
    do
        if [ "${status}" != "Running" ] &&
	   [ "${status}" != "Completed" ]
	then
	    continue
	fi
    done

    KEEP_LOOP="false"
done

exit 0

