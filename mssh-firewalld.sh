#!/bin/bash
set -e

if [ $# -lt 1 ];then
    echo "MSSH version 1.0.0"
    echo "Usage:  mssh-firewalld <configure file> <port file> <clear>"
    echo "        mssh-firewalld test-hosts.txt test-ports/"
    exit 1
fi

# change all password to new
for line in $(cat $1); do
    IFS=',' read -r -a host_conf <<< "$line"
    host_user="${host_conf[0]}"
    host_pass="${host_conf[1]}"
    host_addr="${host_conf[2]}"
    host_port="${host_conf[3]}"
    if [ "$3" == "clear" ];then
        if [ "$host_port" == "" ];then
            sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no $host_user@$host_addr "bash -c $'yum remove firewalld -y; rm -rf /etc/firewalld; yum install firewalld -y; chkconfig firewalld on; service firewalld start;'"
        else
            sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no -p $host_port $host_user@$host_addr "bash -c $'yum remove firewalld -y; rm -rf /etc/firewalld; yum install firewalld -y; chkconfig firewalld on; service firewalld start;'"
        fi
    fi
    script=`cat $2/$host_addr.sh`
    echo "=>change firewall for "$host_addr
    if [ "$host_port" == "" ];then
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no $host_user@$host_addr "bash -c $'$script'"
    else
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no -p $host_port $host_user@$host_addr "bash -c $'$script'"
    fi
done
echo "all done..."