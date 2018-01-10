#!/bin/bash
set -e

if [ $# -lt 2 ];then
    echo "MSSH version 1.0.0"
    echo "Usage:  mssh-cmds <configure file> <command>"
    echo "        mssh-cmds test-hosts.txt 'echo abc'"
    exit 1
fi

# change all password to new
for line in $(cat $1); do
    IFS=',' read -r -a host_conf <<< "$line"
    host_user="${host_conf[0]}"
    host_pass="${host_conf[1]}"
    host_addr="${host_conf[2]}"
    host_port="${host_conf[3]}"
    script=$2
    echo "=>run command on "$host_addr
    if [ "$host_port" == "" ];then
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no $host_user@$host_addr "bash -c $'$script'"
    else
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no -p $host_port $host_user@$host_addr "bash -c $'$script'"
    fi
done
echo "all done..."