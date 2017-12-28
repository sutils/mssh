#!/bin/bash
set -e
if [ $# -lt 3 ];then
    echo "MSSH version 1.0.0"
    echo "Usage:  mssh-useradd <group> <username> <password>"
    echo "        mssh-useradd mssh xxx 123"
    exit 1
fi
pass=`openssl passwd -1 $3`
sudo useradd -p $pass -g $1 $2