#!/usr/bin/env python3

import sys


INITIAL_CLUSTER_ENTRY_KEYWORD = "- --initial-cluster="
INITIAL_CLUSTER_STATE_ENTRY_KEYWORD = "- --initial-cluster-state="



#
# start from here
#

stdin_data_list = sys.stdin.readlines()

for line in stdin_data_list:
    if line is not None and len( line ) > 0:
        if line.find( INITIAL_CLUSTER_ENTRY_KEYWORD ) > 0:
            sys.stdout.write( line )
            PREFIX = line[ 0: line.rfind( INITIAL_CLUSTER_ENTRY_KEYWORD ) ]
            sys.stdout.write( PREFIX + INITIAL_CLUSTER_STATE_ENTRY_KEYWORD + "existing\n" )
            continue

    sys.stdout.write( line )

sys.exit( 0 )

