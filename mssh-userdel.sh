#!/bin/bash
set -e
if [ $# -lt 1 ];then
    echo "MSSH version 1.0.0"
    echo "Usage:  mssh-userdel <username>"
    echo "        mssh-userdel xxx"
    exit 1
fi
sudo userdel -R $1