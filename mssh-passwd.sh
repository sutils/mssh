#!/bin/bash
set -e

if [ $# -lt 2 ];then
    echo "MSSH version 1.0.0"
    echo "Usage:  mssh-passwd <configure file> <new password>"
    echo "        mssh-passwd test-hosts.txt xxx"
    exit 1
fi

# change all password to new
for line in $(cat $1); do
    IFS='#' read -r -a real_line <<< "$line"
    line="${real_line[0]}"
    line="$(set -f; echo $line)"
    if [ "$line" == "" ];then
        continue
    fi
    IFS=',' read -r -a host_conf <<< "$line"
    host_user="${host_conf[0]}"
    host_pass="${host_conf[1]}"
    host_addr="${host_conf[2]}"
    host_port="${host_conf[3]}"
    echo "=>change password for "$host_addr
    if [ "$host_port" == "" ];then
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no $host_user@$host_addr "bash -c $'passwd <<EOF\n$2\n$2\nEOF\n'"
    else
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no -p $host_port $host_user@$host_addr "bash -c $'passwd <<EOF\n$2\n$2\nEOF\n'"
    fi
done
echo "all done..."