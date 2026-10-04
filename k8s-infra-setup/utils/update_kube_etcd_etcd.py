#!/usr/bin/env python3

import sys


INITIAL_CLUSTER_ENTRY_KEYWORD = "- --initial-cluster="
INITIAL_CLUSTER_STATE_ENTRY_KEYWORD = "- --initial-cluster-state="
INITIAL_ADVERTISE_PEER_URLS_ENTRY_KEYWORD = "- --initial-advertise-peer-urls="



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
# update initial cluster entry
#
def updateInitialCluster( line, etcd_ips ):
    if line is None or len( line ) == 0:
        return ""

    if etcd_ips is None or len( etcd_ips ) == 0:
        return line

    etcd_ip_list = parseEtcdIps( etcd_ips )
    if etcd_ip_list is None or len( etcd_ip_list ) == 0:
        return line

    PREFIX = line[ 0: line.rfind( INITIAL_CLUSTER_ENTRY_KEYWORD ) ]
    element_line = ""

    for etcd_ip in etcd_ip_list:
        if len( element_line ) > 0:
            element_line = element_line + ","

        etcd_elements = etcd_ip.split( ":" )

        element_line = element_line + etcd_elements[ 0 ] + "=https://" + etcd_elements[ 1 ] + ":2379"

    return str( PREFIX + INITIAL_CLUSTER_ENTRY_KEYWORD + element_line + "\n" )



#
# update initial advertise peer urls
#
def updateInitialAdvertisePeerUrls( line, etcd_ips ):
    if line is None or len( line ) == 0:
        return ""

    if etcd_ips is None or len( etcd_ips ) == 0:
        return line

    etcd_ip_list = parseEtcdIps( etcd_ips )
    if etcd_ip_list is None or len( etcd_ip_list ) == 0:
        return line

    PREFIX = line[ 0: line.rfind( INITIAL_ADVERTISE_PEER_URLS_ENTRY_KEYWORD ) ]
    element_line = ""

    for etcd_ip in etcd_ip_list:
        if len( element_line ) > 0:
            element_line = element_line + ","

        etcd_elements = etcd_ip.split( ":" )

        element_line = element_line + "https://" + etcd_elements[ 1 ] + ":2380"

    return str( PREFIX + INITIAL_ADVERTISE_PEER_URLS_ENTRY_KEYWORD + element_line + "\n" )



#
# updates listen peer urls
#
def updateListenPeerUrls( line, etcd_ips ):
    if line is None or len( line ) == 0:
        return ""

    if etcd_ips is None or len( etcd_ips ) == 0:
        return line

    etcd_ip_list = parseEtcdIps( etcd_ips )
    if etcd_ip_list is None or len( etcd_ip_list ) == 0:
        return line

    PREFIX = line[ 0: line.rfind( LISTEN_PEER_URLS_ENTRY_KEYWORD ) ]
    element_line = ""

    for etcd_ip in etcd_ip_list:
        if len( element_line ) > 0:
            element_line = element_line + ","

        etcd_elements = etcd_ip.split( ":" )

        element_line = element_line + "https://" + etcd_elements[ 1 ] + ":2380"

    return str( PREFIX + LISTEN_PEER_URLS_ENTRY_KEYWORD + element_line + "\n" )



#
# start from here
#

etcd_ips = sys.argv[ 1 ]
stdin_data_list = sys.stdin.readlines()

if etcd_ips is None or len( etcd_ips ) == 0:
    sys.exit( -1 )

for line in stdin_data_list:
    if line is not None and len( line ) > 0:
        if line.find( INITIAL_CLUSTER_ENTRY_KEYWORD ) > 0:
            new_line = updateInitialCluster( line, etcd_ips )
            sys.stdout.write( new_line )
            continue

        if line.find( INITIAL_ADVERTISE_PEER_URLS_ENTRY_KEYWORD ) > 0:
            new_line = updateInitialAdvertisePeerUrls( line, etcd_ips )
            sys.stdout.write( new_line )
            continue

        if line.find( INITIAL_CLUSTER_STATE_ENTRY_KEYWORD ) > 0:
            continue

    sys.stdout.write( line )

sys.exit( 0 )

