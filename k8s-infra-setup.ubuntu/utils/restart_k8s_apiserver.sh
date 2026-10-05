#!/bin/sh

MAX_WAIT_APISERVER_COUNT="1000"



#
# returns the apiserver pid
#
getApiServerPid()
{
    ps -ef | grep kube-apiserver | grep "authorization-mode" | grep -v grep | awk '{ print $2 }'
}



#
# starts from here
#

kill -9 `getApiServerPid` > /dev/null 2>&1

IS_EXCEEDED="false"
WAIT_APISERVER_COUNT="0"

while true
do
    APISERVER_PID=`getApiServerPid`

    if [ "${APISERVER_PID}" = "" ]
    then
        WAIT_APISERVER_COUNT=`expr ${WAIT_APISERVER_COUNT} + 1`
        sleep 2
    else
        if [ "${WAIT_APISERVER_COUNT}" -gt "${MAX_WAIT_APISERVER_COUNT}" ]
        then
            IS_EXCEEDED="true"
        fi

        break
    fi
done

if [ "${IS_EXCEEDED}" = "true" ]
then
    echo ""
    echo "ERROR: exceeded the wait count for apiserver, abort"
    echo ""
 
    exit 1
fi

echo ""
echo "INFO: apiserver is up and running now."
echo ""

exit 0

