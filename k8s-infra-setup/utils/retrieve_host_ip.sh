#!/bin/sh

SEE_SCOPE="false"
SEE_LINK="false"
SEE_SRC="false"



#
# start from here
#

#ip r | grep "/24" | awk '{ print $NF }'

for each_element in `ip r | grep "/24"`
do
    if [ "${each_element}" = "" ]
    then
        continue
    fi

    if [ "${each_element}" = "scope" ] &&
       [ "${SEE_SCOPE}" = "false" ]
    then
        SEE_SCOPE="true"
        continue
    fi

    if [ "${each_element}" = "link" ] &&
       [ "${SEE_SCOPE}" = "true" ] && 
       [ "${SEE_LINK}" = "false" ]
    then
        SEE_LINK="true"
        continue
    fi

    if [ "${each_element}" = "src" ] &&
       [ "${SEE_SCOPE}" = "true" ] &&
       [ "${SEE_LINK}" = "true" ] &&
       [ "${SEE_SRC}" = "false" ]
    then
        SEE_SRC="true"
        continue
    fi

    if [ "${SEE_SCOPE}" = "true" ] &&
       [ "${SEE_LINK}" = "true" ] &&
       [ "${SEE_SRC}" = "true" ]
    then
        echo "${each_element}"
        exit 0
    fi
done

exit 1
