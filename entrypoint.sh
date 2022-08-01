#!/bin/bash

function start()
{
    unset gid
    # accept "-G gid" option
    while getopts "G:" opt; do
        case ${opt} in
            G) gid=${OPTARG};;
        esac
    done
    shift $(($OPTIND - 1))

    # prepare /etc/exports
    for i in "$@"; do
        # fsid=0: needed for NFSv4
        echo "$i *(rw,fsid=0,sync,no_subtree_check,no_root_squash)" >> /etc/exports
        if [ -v gid ] ; then
            chmod 770 $i
            chgrp $gid $i
            chown 33:33 $i
        fi
        echo "Serving $i"
    done
    
    # start rpcbind if it is not started yet
    /usr/sbin/rpcinfo 127.0.0.1 > /dev/null; s=$?
    if [ $s -ne 0 ]; then
       echo "Starting rpcbind"
       /sbin/rpcbind -w
    fi

    mount -t nfsd nfds /proc/fs/nfsd

    # -V 3: enable NFSv3
    /usr/sbin/rpc.mountd -N 2 -V 3

    /usr/sbin/exportfs -r
    # -G 10 to reduce grace time to 10 seconds (the lowest allowed)
    /usr/sbin/rpc.nfsd -G 10 -N 2 -V 3
    /sbin/rpc.statd --no-notify
    echo "NFS started"

    #Change permitions of /exports
    chown -R 33:33 /exports
}

function stop()
{
    echo "Stopping NFS"

    /usr/sbin/rpc.nfsd 0
    /usr/sbin/exportfs -au
    /usr/sbin/exportfs -f

    kill $( pidof rpc.mountd )
    umount /proc/fs/nfsd
    echo > /etc/exports
    exit 0
}

trap stop TERM

start "$@"

# Ugly hack to do nothing and wait for SIGTERM
while true; do
    sleep 5
done
