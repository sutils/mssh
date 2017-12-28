#!/bin/bash
set -e

if [ $# -lt 1 ];then
    echo "MSSH version 1.0.0"
    echo "Usage:  mssh-conf <configure file>"
    echo "        mssh-conf test-hosts.txt"
    exit 1
fi

# setup
echo "=>creating all by config:"$1
tmp_dir=tmp
rm -rf $tmp_dir
mkdir -p $tmp_dir
touch $tmp_dir/ssh_conf

script="mkdir -p .ssh; chmod 700 .ssh; cat temp_rsa.pub >> .ssh/authorized_keys; chmod 640 .ssh/authorized_keys; rm -f temp_rsa.pub"
if [ "$2" == "overwrite" ];then
    script="mkdir -p .ssh; chmod 700 .ssh; cat temp_rsa.pub > .ssh/authorized_keys; chmod 640 .ssh/authorized_keys; rm -f temp_rsa.pub"
fi

# create rsa key and upload to remote server
for line in $(cat $1); do
    IFS=',' read -r -a host_conf <<< "$line"
    host_user="${host_conf[0]}"
    host_pass="${host_conf[1]}"
    host_addr="${host_conf[2]}"
    host_port="${host_conf[3]}"
    echo "=>creating auto login key for "$host_addr
    ssh-keygen -t rsa  -P '' -f $tmp_dir/$host_addr"_rsa"
    if [ "$host_port" == "" ];then
        sshpass -p "$host_pass" scp -o StrictHostKeyChecking=no $tmp_dir/$host_addr"_rsa.pub" $host_user@$host_addr:~/temp_rsa.pub
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no $host_user@$host_addr "$script"
    else
        sshpass -p "$host_pass" scp -o StrictHostKeyChecking=no -P $host_port $tmp_dir/$host_addr"_rsa.pub" $host_user@$host_addr:~/temp_rsa.pub
        sshpass -p "$host_pass" ssh -o StrictHostKeyChecking=no -p $host_port $host_user@$host_addr "$script"
    fi
    cp -f $tmp_dir/$host_addr"_rsa" ~/.ssh/
    cp -f $tmp_dir/$host_addr"_rsa.pub" ~/.ssh/
    echo "Host "$host_addr >> $tmp_dir/ssh_conf
    echo "  IdentityFile ~/.ssh/"$host_addr"_rsa" >> $tmp_dir/ssh_conf
    echo "  User root" >> $tmp_dir/ssh_conf
    echo ""
    echo ""
done

#copy the ssh config file to user .ssh/config
echo "=>append ssh config to ~/.ssh/config"
cat $tmp_dir/ssh_conf >> ~/.ssh/config
chmod 600 ~/.ssh/*
chmod 700 ~/.ssh

#clearup
echo "=>clear temp file..."
rm -rf $tmp_dir
