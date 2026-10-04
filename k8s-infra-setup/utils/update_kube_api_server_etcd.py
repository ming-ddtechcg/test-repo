#!/usr/bin/env python3

import sys


ETCD_ENTRY_KEYWORD = "- --etcd-servers="


#
# parse input etcd ips
#
def parseEtcdIps( etcd_ips ):
    etcd_ip_list = list()

    if etcd_ips is None or len( etcd_ips ) == 0:
        return etcd_ip_list

    etcd_ip = ""
    stringChars = list( etcd_ips )
    for char in stringChars:
        if char == "," or char == " ":
            if etcd_ip is not None and len( etcd_ip ) > 0:
                etcd_ip_list.append( etcd_ip )
            
            etcd_ip = ""
            continue

        etcd_ip = etcd_ip + char

    if etcd_ip is not None and len( etcd_ip ) > 0:
        etcd_ip_list.append( etcd_ip )

    return etcd_ip_list



#
# update the etcd entry
#
def updateEtcdEntry( line, etcd_ips ):
    if line is None or len( line ) == 0:
        return ""

    if etcd_ips is None or len( etcd_ips ) == 0:
        return line

    etcd_ip_list = parseEtcdIps( etcd_ips )
    if etcd_ip_list is None or len( etcd_ip_list ) == 0:
        return line

    PREFIX = line[ 0: line.rfind( ETCD_ENTRY_KEYWORD ) ]
    element_line = ""

    for etcd_ip in etcd_ip_list:
        if len( element_line ) > 0:
            element_line = element_line + ","

        element_line = element_line + "https://" + etcd_ip + ":2379"

    return str( PREFIX + ETCD_ENTRY_KEYWORD + element_line + "\n" )



#
# start from here
#

etcd_ips = sys.argv[ 1 ]
stdin_data_list = sys.stdin.readlines()

if etcd_ips is None or len( etcd_ips ) == 0:
    sys.exit( -1 )

for line in stdin_data_list:
    if line is not None and len( line ) > 0 and line.find( ETCD_ENTRY_KEYWORD ) > 0:
        new_line = updateEtcdEntry( line, etcd_ips )
        sys.stdout.write( new_line )
        continue

    sys.stdout.write( line )

sys.exit( 0 )

