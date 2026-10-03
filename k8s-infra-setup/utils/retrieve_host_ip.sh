#!/bin/sh


#
# start from here
#

ip r | grep "/24" | awk '{ print $NF }'

