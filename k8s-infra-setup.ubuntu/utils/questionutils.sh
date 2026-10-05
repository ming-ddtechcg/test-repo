#!/bin/sh

ANSWER_REQUESTION_RESPONSE=""



#
# returns the status of is Linux.
#
# @return   "true" if is Linux.  "false", otherwises.
#
isLinux()
{
    RESULT=`operation_system`

    if [ "${RESULT}" = "Linux" ]
    then
        echo "true"
        return
    fi

    echo "false"
}



#
# returns the status of is SunOS
#
# @return   "true" if is SunOS.  "false", otherwises.
#
isSunOS()
{
    RESULT=`operation_system`

    if [ "${RESULT}" = "SunOS" ]
    then
        echo "true"
        return
    fi

    echo "false"
}



#
# returns the operation system name
#
operation_system()
{
    echo "`uname -s`"
}



#
# questions and responses
#
questionAndResponse()
{
    QUESTION="$1"
    ANSWER_CONDITION="$2"

    while [ "true" ]
    do
        ANSWER_REQUESTION_RESPONSE=""

        echo ""

        if [ "`isSunOS`" = "true" ]
        then
            echo "${QUESTION}: \c"
        elif [ "`isLinux`" = "true" ]
        then
            echo -n "${QUESTION}: \c"
        else
            echo "${QUESTION}: "
        fi

        read ANSWER_REQUESTION_RESPONSE

        ANSWER_REQUESTION_RESPONSE="`echo ${ANSWER_REQUESTION_RESPONSE} | xargs`"

        if [ "${ANSWER_REQUESTION_RESPONSE}" != "" ]
        then
            if [ "${ANSWER_CONDITION}" != "" ]
            then
                meet_confition="false"

                for condition in ${ANSWER_CONDITION}
                do
                    if [ "${condition}" = "skip" ] ||
                       [ "${condition}" = "${ANSWER_REQUESTION_RESPONSE}" ]
                    then
                        meet_confition="true"
                        break
                    fi
                done

                if [ "${meet_confition}" = "false" ]
                then
                    continue
                fi
            fi

            return
        elif [ "${ANSWER_REQUESTION_RESPONSE}" = "" ]
        then
            for condition in ${ANSWER_CONDITION}
            do
                if [ "${condition}" = "skip" ]
                then
                    ANSWER_REQUESTION_RESPONSE=""
                    return
                fi
            done
        fi
    done
}



#
# test from here
#

case $1 in
'test')
    questionAndResponse "this is test1 (y/n)" "y n"
    echo "response: ${ANSWER_REQUESTION_RESPONSE}"

    questionAndResponse "press enter to continue" "skip"

    questionAndResponse "free typing"
    echo "response: ${ANSWER_REQUESTION_RESPONSE}"
    ;;
esac

