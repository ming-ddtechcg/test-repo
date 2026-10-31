#!/bin/sh

EXIT_FILE="/.exit"


#
# starts from here
#

while true
do
    if [ -f "${EXIT_FILE}" ]
    then
        break
    fi

    sleep 30
done

exit 0
